// SPDX-FileCopyrightText: 2023 AGPL-3.0-or-later

use super::job::{Executable, Job, JobIdentifier, PostCheckJobs, PreCheckJobs};
use crate::domain::{
    core::{Entity, Identifier, ValueObject},
    models::value_objects::pipeline::steps::{executions::Output, status::Status},
};
use serde::{Deserialize, Serialize};
use std::{collections::HashSet, time::SystemTime};
use thiserror::Error;

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq, Eq, Hash)]
pub struct StepIdentifier {
    pub(crate) value: String,
}
impl StepIdentifier {
    pub fn value(&self) -> &str {
        &self.value
    }
}

impl ValueObject<StepIdentifier> for StepIdentifier {}

impl Identifier<StepIdentifier> for StepIdentifier {}

pub type LinkedSteps = Option<HashSet<StepIdentifier>>;
pub type NextSteps = LinkedSteps;

#[derive(Error, Serialize, Deserialize, Debug, Clone, PartialEq)]
pub enum StepError {
    #[error("No job {} found for step {}", .job.value(), .step.value())]
    JobNotFound {
        step: StepIdentifier,
        job: JobIdentifier,
    },
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub(in crate::domain) struct Step {
    identifier: StepIdentifier,
    job: Job,
    status: Status,
    dry_run: bool,
    start_at: Option<SystemTime>,
    end_at: Option<SystemTime>,
    pre_checks: PreCheckJobs,
    post_checks: PostCheckJobs,
    nexts: NextSteps,
}

impl PartialEq for Step {
    fn eq(&self, other: &Self) -> bool {
        self.identifier.eq(&other.identifier)
    }
}

impl Entity<Step> for Step {
    type Identifier = StepIdentifier;
    fn identifier(&self) -> Self::Identifier {
        self.identifier.clone()
    }
}

impl Step {
    pub fn default(
        identifier: StepIdentifier,
        job: Job,
        pre_check: PreCheckJobs,
        post_check: PostCheckJobs,
        next: NextSteps,
    ) -> Step {
        Step {
            identifier,
            job,
            pre_checks: pre_check,
            post_checks: post_check,
            nexts: next,
            start_at: None,
            end_at: None,
            status: Status::ToDo,
            dry_run: false,
        }
    }
    pub fn new(
        identifier: StepIdentifier,
        job: Job,
        status: Status,
        dry_run: bool,
        start_at: Option<SystemTime>,
        end_at: Option<SystemTime>,
        pre_checks: PreCheckJobs,
        post_checks: PostCheckJobs,
        nexts: NextSteps,
    ) -> Step {
        Step {
            identifier,
            job,
            pre_checks,
            post_checks,
            nexts,
            start_at,
            end_at,
            status,
            dry_run,
        }
    }

    pub fn new_starter(
        identifier: StepIdentifier,
        job: Job,
        pre_check: PreCheckJobs,
        post_check: PostCheckJobs,
        next: NextSteps,
    ) -> Step {
        Self::default(identifier, job, pre_check, post_check, next)
    }
    pub fn new_terminal(
        identifier: StepIdentifier,
        job: Job,
        pre_check: PreCheckJobs,
        post_check: PostCheckJobs,
    ) -> Step {
        Self::default(identifier, job, pre_check, post_check, None)
    }

    pub fn identifier(&self) -> &StepIdentifier {
        &self.identifier
    }
    pub fn nexts(&self) -> &NextSteps {
        &self.nexts
    }

    pub fn is_starter(&self) -> bool {
        !self.nexts.is_some()
    }
    pub fn job(&self) -> &Job {
        &self.job
    }
    pub fn pre_checks(&self) -> &PreCheckJobs {
        &self.pre_checks
    }
    pub fn status(&self) -> &Status {
        &self.status
    }
    pub fn is_dry_run(&self) -> bool {
        self.dry_run
    }
    pub fn start_at(&self) -> &Option<SystemTime> {
        &self.start_at
    }
    pub fn end_at(&self) -> &Option<SystemTime> {
        &self.end_at
    }
    pub fn pre_checks_mut(&mut self) -> &mut PreCheckJobs {
        &mut self.pre_checks
    }
    pub fn post_checks(&self) -> &PostCheckJobs {
        &self.post_checks
    }

    pub fn update_job(&mut self, job: JobIdentifier, output: Output) -> Result<(), StepError> {
        match self
            .pre_checks
            .as_mut()
            .map(|pre_check| {
                pre_check
                    .get_mut(&job)
                    .map(|job| job.update(output.to_owned()))
            })
            .flatten()
            .map(|_| {
                self.post_checks.as_mut().and_then(|post_checks| {
                    post_checks
                        .get_mut(&job)
                        .and_then(|job| Some(job.update(output.to_owned())))
                })
            })
            .map_or(None, |_| {
                self.job
                    .identifier()
                    .eq(&job)
                    .then(|| {
                        match self.start_at {
                            Some(_start_at) => {
                                self.status = Status::Doing;
                                self.job.update(output.to_owned());
                            }
                            None => {
                                self.status = Status::ToDo;
                                self.job.update(output.to_owned());
                            }
                        }
                        self.job.update(output)
                    })
                    .map_or(None, |_| {
                        Some(StepError::JobNotFound {
                            step: self.identifier().clone(),
                            job: self.job.identifier().clone(),
                        })
                    })
            }) {
            Some(error) => Err(error),
            None => Ok(()),
        }
    }
}

impl Executable for Step {
    fn run(&mut self, dry_run: bool) {
        self.dry_run = dry_run;
        self.status = Status::Doing;
        self.start_at = Some(SystemTime::now());
        self.pre_checks.as_mut().and_then(|pre_checks| {
            pre_checks.iter_mut().for_each(|(_, pre_check)| {
                pre_check.run(dry_run);
            });
            Some(pre_checks)
        });
    }
}

#[derive(Clone, PartialEq)]
pub(in crate::domain) struct RevertStep {
    identifier: StepIdentifier,
    job: Job,
    post_check: PostCheckJobs,
}

impl RevertStep {
    pub fn new(identifier: StepIdentifier, job: Job, post_check: PostCheckJobs) -> RevertStep {
        RevertStep {
            identifier,
            job,
            post_check,
        }
    }
}

#[derive(Clone, PartialEq)]
pub(in crate::domain) enum StepKind {
    Destructive { step: Step, revert: RevertStep },
    Safe { step: Step },
}

impl StepKind {
    pub fn new_safe(step: Step) -> StepKind {
        StepKind::Safe { step }
    }
    pub fn new_destructive(step: Step, revert: RevertStep) -> StepKind {
        StepKind::Destructive { step, revert }
    }
}
