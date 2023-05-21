use std::collections::HashSet;

use super::backend::Backend;

pub type JobIdentifier = String;
pub type Retry = u8;

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct NodeExecution {
    pub per_node_execution: bool,
    pub parrallisable: bool,
}

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct Job {
    identifier: JobIdentifier,
    backend: Backend,
    node_execution: Option<NodeExecution>,
    // TODO: find way to make this generic
    // action: Fn<T>,
}

pub trait Executable {
    fn get_identifier(&self) -> JobIdentifier;
    fn get_backend(&self) -> Backend;
}

impl Job {
    pub fn new(identifier: JobIdentifier, backend: Backend) -> Job {
        Job {
            backend,
            identifier,
            // TODO: make this configurable
            node_execution: None,
        }
    }
}

impl Executable for Job {
    fn get_identifier(&self) -> JobIdentifier {
        self.identifier.clone()
    }
    fn get_backend(&self) -> Backend {
        self.backend.clone()
    }
}

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct CheckJob {
    retry: Option<Retry>,
    job: Job,
}

impl CheckJob {
    pub fn new(retry: Option<Retry>, job: Job) -> CheckJob {
        CheckJob { retry, job }
    }

    pub fn get_retry(&self) -> Option<Retry> {
        self.retry
    }
}

impl Executable for CheckJob {
    fn get_identifier(&self) -> JobIdentifier {
        self.job.identifier.clone()
    }
    fn get_backend(&self) -> Backend {
        self.job.backend.clone()
    }
}

pub type LinkedCheckJobs = Option<HashSet<CheckJob>>;
pub type PreCheckJobs = LinkedCheckJobs;
pub type PostCheckJobs = LinkedCheckJobs;

pub fn get_none_pre_check_jobs() -> PreCheckJobs {
    None
}

pub fn get_none_post_check_jobs() -> PreCheckJobs {
    None
}
