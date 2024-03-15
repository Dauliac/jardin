// use std::collections::HashSet;

// use serde::{Deserialize, Serialize};
// use thiserror::Error;

// use crate::{domain::{models::entities::job::{PreCheckJobs, Job, PostCheckJobs, Executable, JobIdentifier}, core::{ValueObject, Identifier, Entity}}, application::services::config::error};

// use super::executions::Output;

// #[derive(Clone, PartialEq)]
// pub struct RevertStep {
//     identifier: StepIdentifier,
//     job: Job,
//     post_check: PostCheckJobs,
// }

// impl RevertStep {
//     pub fn new(identifier: StepIdentifier, job: Job, post_check: PostCheckJobs) -> RevertStep {
//         RevertStep {
//             identifier,
//             job,
//             post_check,
//         }
//     }
// }

// #[derive(Clone, PartialEq)]
// pub enum StepKind {
//     Destructive { step: Step, revert: RevertStep },
//     Safe { step: Step },
// }

// impl StepKind {
//     pub fn new_safe(step: Step) -> StepKind {
//         StepKind::Safe { step }
//     }
//     pub fn new_destructive(step: Step, revert: RevertStep) -> StepKind {
//         StepKind::Destructive { step, revert }
//     }
// }

use super::{backend::Backend, executions::Output, status::Status};
use crate::domain::{
    core::Entity,
    models::entities::{
        job::{CheckJob, Job, JobIdentifier, NodeExecution, Retry},
        step::{Step, StepIdentifier},
    },
};
use serde::{Deserialize, Serialize};
use std::time::SystemTime;

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq, Eq, Hash)]
pub struct JobPreview {
    pub identifier: JobIdentifier,
    pub backend: Backend,
    pub status: Status,
    pub dry_run: bool,
    pub node_execution: Option<NodeExecution>,
    pub output: Option<Output>,
    pub start_at: Option<SystemTime>,
    pub end_at: Option<SystemTime>,
}

impl From<Job> for JobPreview {
    fn from(job: Job) -> Self {
        JobPreview {
            identifier: job.identifier(),
            backend: job.backend(),
            status: job.status(),
            dry_run: job.is_dry_run(),
            node_execution: job.node_execution(),
            output: job.output(),
            start_at: job.start_at(),
            end_at: job.end_at(),
        }
    }
}

impl From<JobPreview> for Job {
    fn from(val: JobPreview) -> Self {
        Job::new(
            val.identifier,
            val.backend,
            val.status,
            val.dry_run,
            val.node_execution,
            val.output,
            val.start_at,
            val.start_at,
        )
    }
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq, Eq, Hash)]
pub struct CheckJobPreview {
    pub retry: Option<Retry>,
    pub retried: Option<Retry>,
    pub job: JobPreview,
}

impl From<CheckJob> for CheckJobPreview {
    fn from(job: CheckJob) -> Self {
        CheckJobPreview {
            retry: job.retry(),
            retried: job.retried(),
            job: job.job().clone().into(),
        }
    }
}

impl From<CheckJobPreview> for CheckJob {
    fn from(val: CheckJobPreview) -> Self {
        CheckJob::new(val.retry, val.retried, val.job.into())
    }
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq, Eq, Hash)]
pub struct StepPreview {
    pub identifier: StepIdentifier,
    pub job: JobPreview,
    pub status: Status,
    pub dry_run: bool,
    pub start_at: Option<SystemTime>,
    pub end_at: Option<SystemTime>,
    pub pre_checks: Option<Vec<CheckJobPreview>>,
    pub post_checks: Option<Vec<CheckJobPreview>>,
    pub nexts: Option<Vec<StepIdentifier>>,
}

impl From<Step> for StepPreview {
    fn from(step: Step) -> Self {
        StepPreview {
            identifier: step.identifier().clone(),
            job: step.job().clone().into(),
            status: step.status().clone(),
            dry_run: step.is_dry_run(),
            start_at: *step.start_at(),
            end_at: *step.end_at(),
            pre_checks: step.pre_checks().clone().map(|pre_check| {
                pre_check
                    .values()
                    .map(|check_job| From::from(check_job.clone()))
                    .collect()
            }),
            post_checks: step.post_checks().clone().map(|pre_check| {
                pre_check
                    .values()
                    .map(|check_job| From::from(check_job.clone()))
                    .collect()
            }),
            nexts: step
                .nexts()
                .clone()
                .map(|nexts| nexts.into_iter().collect()),
        }
    }
}

impl From<StepPreview> for Step {
    fn from(val: StepPreview) -> Self {
        Step::new(
            val.identifier,
            val.job.into(),
            val.status,
            val.dry_run,
            val.start_at,
            val.end_at,
            val.pre_checks.map(|pre_checks| {
                pre_checks
                    .into_iter()
                    .map(|check_job| (check_job.job.identifier.clone(), check_job.into()))
                    .collect()
            }),
            val.post_checks.map(|post_checks| {
                post_checks
                    .into_iter()
                    .map(|check_job| (check_job.job.identifier.clone(), check_job.into()))
                    .collect()
            }),
            val.nexts.map(|nexts| nexts.into_iter().collect()),
        )
    }
}
