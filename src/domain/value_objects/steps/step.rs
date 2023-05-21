use std::collections::HashSet;

use super::job::{Job, PostCheckJobs, PreCheckJobs};

pub type LinkedSteps = Option<HashSet<StepIdentifier>>;
pub type NextSteps = LinkedSteps;
pub type StepIdentifier = String;

#[derive(Debug, Clone, PartialEq)]
pub struct Step {
    identifier: StepIdentifier,
    job: Job,
    pre_check: PreCheckJobs,
    post_check: PostCheckJobs,
    next: NextSteps,
}

impl Step {
    pub fn new(
        identifier: StepIdentifier,
        job: Job,
        pre_check: PreCheckJobs,
        post_check: PostCheckJobs,
        next: NextSteps,
    ) -> Step {
        Step {
            identifier,
            job,
            pre_check,
            post_check,
            next,
        }
    }
    pub fn new_starter(
        identifier: StepIdentifier,
        job: Job,
        pre_check: PreCheckJobs,
        post_check: PostCheckJobs,
        next: NextSteps,
    ) -> Step {
        Self::new(identifier, job, pre_check, post_check, next)
    }
    pub fn new_terminal(
        identifier: StepIdentifier,
        job: Job,
        pre_check: PreCheckJobs,
        post_check: PostCheckJobs,
    ) -> Step {
        Self::new(identifier, job, pre_check, post_check, None)
    }

    pub fn get_identifier(&self) -> &StepIdentifier {
        &self.identifier
    }
    pub fn get_nexts(&self) -> &NextSteps {
        &self.next
    }
}

#[derive(Clone, PartialEq)]
pub struct RevertStep {
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
pub enum StepKind {
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
