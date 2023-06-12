// SPDX-FileCopyrightText: 2023 AGPL-3.0-or-later

use std::collections::{HashMap, HashSet};

use serde::{Deserialize, Serialize};
use thiserror::Error;

use crate::domain::{
    core::{Entity, Event, ValueObject},
    models::{
        value_objects::pipeline::{
            steps::{executions::Output, step::StepPreview},
            PipelineIdentifier,
        },
        DomainResponseKinds,
    },
};

use super::{
    job::{Executable, JobIdentifier},
    step::{Step, StepIdentifier},
};

pub(in crate::domain) type Steps = HashMap<StepIdentifier, Step>;

#[derive(Error, Serialize, Deserialize, Debug, Clone, PartialEq)]
pub enum PipelineError {
    #[error("Some next step noes not exist")]
    InvalidNextSteps(HashSet<StepIdentifier>),
    #[error("Siven sources was not loaded")]
    CyclicStepFlow(HashSet<StepIdentifier>),
}
impl ValueObject<PipelineError> for PipelineError {}
impl Event<PipelineError> for PipelineError {}
impl From<PipelineError> for Vec<DomainResponseKinds> {
    fn from(value: PipelineError) -> Self {
        let mut kind = vec![DomainResponseKinds::ClusterPipelineError];
        let mut specific_kind: Vec<DomainResponseKinds> = match value {
            PipelineError::InvalidNextSteps(_) => {
                vec![DomainResponseKinds::ClusterPipelineInvalidNextStepsError]
            }
            PipelineError::CyclicStepFlow(_) => {
                vec![DomainResponseKinds::ClusterPipelineCyclicStepFlowError]
            }
        };
        kind.append(&mut specific_kind);
        kind
    }
}

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
pub enum PipelineEvent {
    PipelineCreated {
        identifier: PipelineIdentifier,
        steps: Vec<StepPreview>,
        jobs: Vec<JobIdentifier>,
    },
    PipelineStarted {
        identifier: PipelineIdentifier,
        dry_run: bool,
        step_started: Vec<StepIdentifier>,
        job_started: Vec<JobIdentifier>,
    },
    JobUpdated {
        identifier: JobIdentifier,
        dry_run: bool,
        output: Output,
    },
}
impl ValueObject<PipelineEvent> for PipelineEvent {}
impl Event<PipelineEvent> for PipelineEvent {}
impl From<PipelineEvent> for Vec<DomainResponseKinds> {
    fn from(event: PipelineEvent) -> Self {
        let mut kind = vec![DomainResponseKinds::ClusterPipelineEvent];
        let mut specific_kind: Vec<DomainResponseKinds> = match event {
            PipelineEvent::PipelineCreated { .. } => {
                vec![DomainResponseKinds::ClusterPipelineCreatedEvent]
            }
            PipelineEvent::PipelineStarted {
                identifier: _,
                dry_run: _,
                step_started: _,
                job_started: _,
            } => vec![DomainResponseKinds::ClusterPipelineStartedEvent],
            PipelineEvent::JobUpdated {
                identifier: _,
                dry_run: _,
                output: _,
            } => vec![DomainResponseKinds::ClusterPipelineJobUpdatedEvent],
        };
        kind.append(&mut specific_kind);
        kind
    }
}

fn detect_non_valid_next_steps(steps: &Steps) -> Result<(), PipelineError> {
    let invalid_next_steps = steps
        .iter()
        .flat_map(|(_, step)| step.nexts().iter().flatten())
        .filter(|find_next_step_identifier| !steps.contains_key(*find_next_step_identifier))
        .fold(HashSet::new(), |mut invalids, find_next_step_identifier| {
            invalids.insert(find_next_step_identifier.clone());
            invalids
        });
    invalid_next_steps
        .is_empty()
        .then_some(())
        .ok_or_else(|| PipelineError::InvalidNextSteps(invalid_next_steps))
}

fn detect_non_acyclic_flow(steps: &[Step], indexed_steps: &Steps) -> Result<(), PipelineError> {
    let visited: HashSet<StepIdentifier> = HashSet::new();
    let visiting: HashSet<StepIdentifier> = HashSet::new();

    steps.iter().try_for_each(|step| {
        let identifier = step.identifier().clone();
        visited
            .contains(&identifier)
            .then(|| Ok(()))
            .unwrap_or_else(|| {
                visit_step(
                    step,
                    indexed_steps,
                    &mut visited.clone(),
                    &mut visiting.clone(),
                )
            })
    })
}

fn visit_step(
    visiting_step: &Step,
    steps: &Steps,
    visited: &mut HashSet<StepIdentifier>,
    visiting: &mut HashSet<StepIdentifier>,
) -> Result<(), PipelineError> {
    let id = visiting_step.identifier().clone();
    visiting.insert(id.clone());

    let result = visiting_step.nexts().clone().map_or(Ok(()), |next_steps| {
        next_steps.iter().try_for_each(|next_step_id| {
            visited
                .contains(next_step_id)
                .then(|| {
                    let next_step = steps.get(next_step_id).unwrap();
                    visit_step(next_step, steps, visited, visiting)
                })
                .or_else(|| Some(Err(PipelineError::CyclicStepFlow(visiting.clone()))))
                .or_else(|| Some(Ok(())))
                .unwrap()
        })
    });

    visiting.remove(&id).then(|| visited.insert(id));

    result
}

fn index_steps(steps: &[Step]) -> HashMap<StepIdentifier, Step> {
    steps
        .iter()
        .map(|step| (step.identifier().clone(), step.clone()))
        .collect()
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub(in crate::domain) struct Pipeline {
    identifier: PipelineIdentifier,
    dry_run: bool,
    steps: HashMap<StepIdentifier, Step>,
    jobs: HashMap<JobIdentifier, StepIdentifier>,
}

impl PartialEq for Pipeline {
    fn eq(&self, other: &Self) -> bool {
        self.identifier.eq(&other.identifier)
    }
}

impl Entity<Pipeline> for Pipeline {
    type Identifier = PipelineIdentifier;
    fn identifier(&self) -> Self::Identifier {
        self.identifier.clone()
    }
}

fn get_jobs(steps: &Steps) -> HashMap<JobIdentifier, StepIdentifier> {
    steps
        .iter()
        .fold(HashMap::new(), |mut jobs, (_step_identifier, &ref step)| {
            jobs.insert(step.job().identifier().clone(), step.identifier().clone());
            step.is_starter().then(|| {
                step.pre_checks().clone().and_then(|pre_checks| {
                    pre_checks.iter().for_each(|(_, pre_check)| {
                        jobs.insert(
                            pre_check.job().identifier().clone(),
                            step.identifier().clone(),
                        );
                    });
                    Some(())
                });
            });
            jobs
        })
}

impl Pipeline {
    pub fn create(
        identifier: PipelineIdentifier,
        steps: Vec<Step>,
    ) -> Result<PipelineEvent, PipelineError> {
        let ordered_steps = steps.clone();
        let indexed_steps: HashMap<StepIdentifier, Step> = steps
            .into_iter()
            .map(|step| (step.identifier().clone(), step))
            .collect();
        let jobs = get_jobs(&indexed_steps).keys().cloned().collect();
        let _ = detect_non_acyclic_flow(&ordered_steps, &indexed_steps);
        detect_non_valid_next_steps(&indexed_steps).map(|_| PipelineEvent::PipelineCreated {
            identifier,
            steps: ordered_steps
                .iter()
                .map(|step| From::from(step.clone()))
                .collect(),
            jobs,
        })
    }

    pub fn new(identifier: PipelineIdentifier, steps: Vec<Step>) -> Self {
        let steps = index_steps(&steps);
        let jobs = get_jobs(&steps);
        Self {
            identifier,
            dry_run: false,
            steps,
            jobs,
        }
    }

    pub fn get_steps_to_run(&self) -> Vec<StepIdentifier> {
        self.steps
            .values()
            .filter(|step| step.is_starter())
            .map(|step| step.identifier().clone())
            .collect()
    }

    pub fn get_job_to_run(&self) -> Vec<JobIdentifier> {
        self.jobs.keys().cloned().collect()
    }

    pub fn run(&mut self, dry_run: bool) {
        self.dry_run = dry_run;
        self.get_steps_to_run().iter().for_each(|step_identifier| {
            match self.steps.get_mut(step_identifier) {
                Some(step) => {
                    step.run(dry_run);
                }
                None => {}
            }
        });
    }

    pub fn update_job(
        &mut self,
        job: JobIdentifier,
        output: Output,
    ) -> Result<PipelineEvent, PipelineError> {
        self.jobs.get(&job).map(|step| {
            let _step = self.steps.get_mut(step).map(|step| {
                step.update_job(job.to_owned(), output.to_owned());
                Some(step)
            });
        });
        Ok(PipelineEvent::JobUpdated {
            identifier: job,
            dry_run: self.dry_run,
            output,
        })
    }
}
