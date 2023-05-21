use super::{
    job::{CheckJob, Job, Retry},
    status::Status,
    step::Step,
};
use std::time::Duration;

pub type StdOut = String;
pub type StdErr = String;
pub type ReturnCode = u8;

pub struct Output {
    stdout: String,
    stderr: String,
    return_code: ReturnCode,
}

pub struct Execution {
    start_timestamp: Duration,
    end_timestamp: Duration,
    status: Status,
}

pub struct JobExecution {
    job: Job,
    output: Output,
    execution: Execution,
}

pub struct CheckJobExecution {
    step: CheckJob,
    retried: Retry,
    execution: Execution,
}

pub struct StepExecution {
    step: Step,
    execution: Execution,
}
