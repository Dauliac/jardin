// SPDX-FileCopyrightText: 2023 AGPL-3.0-or-later

use std::{collections::HashMap, time::SystemTime};

use serde::{Deserialize, Serialize};

use crate::domain::{
    core::{Entity, Identifier, ValueObject},
    models::value_objects::pipeline::steps::{
        backend::Backend,
        executions::Output,
        status::{FinalState, Status},
    },
};

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq, Eq, Hash)]
pub struct JobIdentifier {
    pub(crate) value: String,
}

impl JobIdentifier {
    pub fn value(&self) -> &str {
        &self.value
    }
}

impl ValueObject<JobIdentifier> for JobIdentifier {}

impl Identifier<JobIdentifier> for JobIdentifier {}

pub type Retry = u8;

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq, Eq, Hash)]
pub struct NodeExecution {
    pub per_node_execution: bool,
    pub parrallisable: bool,
}

#[derive(Serialize, Deserialize, Debug, Clone, Eq, Hash)]
pub(in crate::domain) struct Job {
    identifier: JobIdentifier,
    backend: Backend,
    status: Status,
    dry_run: bool,
    node_execution: Option<NodeExecution>,
    output: Option<Output>,
    start_at: Option<SystemTime>,
    end_at: Option<SystemTime>,
    // TODO: find way to make this generic
    // action: Fn<T>,
}

pub trait Executable {
    fn run(&mut self, dry_run: bool);
}

impl PartialEq for Job {
    fn eq(&self, other: &Self) -> bool {
        self.identifier.eq(&other.identifier)
    }
}

impl Entity<Job> for Job {
    type Identifier = JobIdentifier;
    fn identifier(&self) -> Self::Identifier {
        self.identifier.clone()
    }
}

impl Job {
    pub fn default(identifier: JobIdentifier, backend: Backend) -> Job {
        Job {
            backend,
            identifier,
            dry_run: false,
            status: Status::ToDo,
            node_execution: None,
            output: None,
            start_at: None,
            end_at: None,
        }
    }

    pub fn new(
        identifier: JobIdentifier,
        backend: Backend,
        status: Status,
        dry_run: bool,
        node_execution: Option<NodeExecution>,
        output: Option<Output>,
        start_at: Option<SystemTime>,
        end_at: Option<SystemTime>,
    ) -> Job {
        Job {
            identifier,
            backend,
            status,
            dry_run,
            node_execution,
            output,
            start_at,
            end_at,
        }
    }

    pub fn update(&mut self, output: Output) {
        self.output = Some(output);
    }

    pub fn success(&mut self) {
        self.status = Status::Done(FinalState::Success);
        self.end_at = Some(SystemTime::now());
    }

    pub fn fail(&mut self) {
        self.status = Status::Done(FinalState::Failure);
        self.end_at = Some(SystemTime::now());
    }

    pub fn skip(&mut self) {
        self.status = Status::Done(FinalState::Skipped);
        self.end_at = None;
    }

    pub fn backend(&self) -> Backend {
        self.backend.clone()
    }
    pub fn status(&self) -> Status {
        self.status.clone()
    }
    pub fn is_dry_run(&self) -> bool {
        self.dry_run
    }
    pub fn node_execution(&self) -> Option<NodeExecution> {
        self.node_execution.clone()
    }
    pub fn output(&self) -> Option<Output> {
        self.output.clone()
    }
    pub fn start_at(&self) -> Option<SystemTime> {
        self.start_at
    }
    pub fn end_at(&self) -> Option<SystemTime> {
        self.end_at
    }
}

impl Executable for Job {
    fn run(&mut self, dry_run: bool) {
        self.dry_run = dry_run;
        self.start_at = Some(SystemTime::now());
        self.status = Status::Doing;
    }
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub(in crate::domain) struct CheckJob {
    retry: Option<Retry>,
    retried: Option<Retry>,
    job: Job,
}

impl PartialEq for CheckJob {
    fn eq(&self, other: &Self) -> bool {
        self.job.eq(&other.job())
    }
}

impl Entity<Job> for CheckJob {
    type Identifier = JobIdentifier;
    fn identifier(&self) -> Self::Identifier {
        Entity::identifier(&self.job)
    }
}

impl CheckJob {
    pub fn default(retry: Option<Retry>, job: Job) -> CheckJob {
        CheckJob {
            retry,
            job,
            retried: None,
        }
    }
    pub fn new(retry: Option<Retry>, retried: Option<Retry>, job: Job) -> CheckJob {
        CheckJob {
            retry,
            retried,
            job,
        }
    }
    pub fn retry(&self) -> Option<Retry> {
        self.retry
    }
    pub fn job(&self) -> &Job {
        &self.job
    }
    pub fn job_mut(&mut self) -> &mut Job {
        &mut self.job
    }
    pub fn update(&mut self, output: Output) {
        self.job.update(output)
    }
    pub fn retried(&self) -> Option<Retry> {
        self.retried
    }
    pub fn fail(&mut self) -> Option<Retry> {
        self.retried
            .map(|retried| {
                self.retry
                    .map(|retry| {
                        let remains = retry - retried;
                        retry
                            .eq(&retried)
                            .then(|| {
                                self.job.fail();
                                remains
                            })
                            .or_else(|| {
                                self.retried = Some(retried + 1);
                                Some(remains)
                            })
                    })
                    .flatten()
            })
            .flatten()
    }
    pub fn success(&mut self) {
        self.job.success()
    }
    pub fn skip(&mut self) {
        self.job.skip()
    }
    fn get_backend(&self) -> Backend {
        self.job.backend.clone()
    }
}

impl Executable for CheckJob {
    fn run(&mut self, dry_run: bool) {
        self.retried = self.retry.is_some().then(|| 0);
        self.job_mut().run(dry_run);
    }
}

pub(in crate::domain) type LinkedCheckJobs = Option<HashMap<JobIdentifier, CheckJob>>;

pub(in crate::domain) type PreCheckJobs = LinkedCheckJobs;
pub(in crate::domain) type PostCheckJobs = LinkedCheckJobs;

pub(in crate::domain) fn get_none_pre_check_jobs() -> PreCheckJobs {
    None
}

pub(in crate::domain) fn get_none_post_check_jobs() -> PreCheckJobs {
    None
}
