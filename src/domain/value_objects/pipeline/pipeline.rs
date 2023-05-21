use std::collections::{HashMap, HashSet};

use thiserror::Error;

use crate::domain::value_objects::steps::step::{Step, StepIdentifier};

pub type PipelineIdentifier = String;

#[derive(Debug, Clone, PartialEq)]
pub struct Pipeline {
    pub identifier: PipelineIdentifier,
    steps: HashMap<StepIdentifier, Step>,
}

#[derive(Error, Debug, Clone, PartialEq)]
pub enum PipelineError {
    #[error("Some next step noes not exist")]
    InvalidNextSteps(HashSet<StepIdentifier>),
    #[error("Siven sources was not loaded")]
    CyclicStepFlow(HashSet<StepIdentifier>),
}

fn detect_non_valid_next_steps(steps: &HashMap<StepIdentifier, Step>) -> Result<(), PipelineError> {
    let invalid_next_steps = steps
        .iter()
        .flat_map(|(_, step)| step.get_nexts().iter().flatten())
        .filter(|find_next_step_identifier| !steps.contains_key(find_next_step_identifier.clone()))
        .fold(HashSet::new(), |mut invalids, find_next_step_identifier| {
            invalids.insert(find_next_step_identifier.clone());
            invalids
        });
    invalid_next_steps
        .is_empty()
        .then(|| ())
        .ok_or_else(|| PipelineError::InvalidNextSteps(invalid_next_steps))
}

fn detect_non_acyclic_flow(
    steps: &Vec<Step>,
    indexed_steps: &HashMap<StepIdentifier, Step>,
) -> Result<(), PipelineError> {
    let visited: HashSet<StepIdentifier> = HashSet::new();
    let visiting: HashSet<StepIdentifier> = HashSet::new();

    steps.iter().try_for_each(|step| {
        let identifier = step.get_identifier().clone();
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
    steps: &HashMap<StepIdentifier, Step>,
    visited: &mut HashSet<StepIdentifier>,
    visiting: &mut HashSet<StepIdentifier>,
) -> Result<(), PipelineError> {
    let id = visiting_step.get_identifier().clone();
    visiting.insert(id.clone());

    let result = visiting_step
        .get_nexts()
        .clone()
        .map_or(Ok(()), |next_steps| {
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

impl Pipeline {
    pub fn new(
        identifier: PipelineIdentifier,
        steps: Vec<Step>,
    ) -> Result<Pipeline, PipelineError> {
        let _ordered_steps = steps.clone();
        let indexed_steps: HashMap<StepIdentifier, Step> = steps
            .into_iter()
            .map(|step| (step.get_identifier().clone(), step))
            .collect();
        println!("indexed_steps: {:#?}", indexed_steps);
        detect_non_valid_next_steps(&indexed_steps)
            // BUG: fix this
            // .and_then(|_| detect_non_acyclic_flow(&ordered_steps, &indexed_steps))
            .and_then(|_| {
                Ok(Pipeline {
                    identifier,
                    steps: indexed_steps,
                })
            })
    }

    pub fn get_identifier(&self) -> &PipelineIdentifier {
        &self.identifier
    }
}
