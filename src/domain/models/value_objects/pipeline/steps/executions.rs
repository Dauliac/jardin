// SPDX-FileCopyrightText: 2023 AGPL-3.0-or-later

use serde::{Deserialize, Serialize};

use super::{
    job::{CheckJob, Job, Retry},
    status::Status,
    step::Step,
};
use std::time::Duration;

pub type StdOut = String;
pub type StdErr = String;
pub type ReturnCode = u8;

#[derive(Serialize, Deserialize, Clone, PartialEq)]
pub struct Output {
    stdout: String,
    stderr: String,
    return_code: ReturnCode,
}

#[derive(Serialize, Deserialize, Clone, PartialEq)]
pub struct Execution {
    start_timestamp: Duration,
    end_timestamp: Duration,
    status: Status,
}

#[derive(Serialize, Deserialize, Clone, PartialEq)]
pub struct JobExecution {
    job: Job,
    output: Output,
    execution: Execution,
}

#[derive(Serialize, Deserialize, Clone, PartialEq)]
pub struct CheckJobExecution {
    step: CheckJob,
    retried: Retry,
    execution: Execution,
}

#[derive(Serialize, Deserialize, Clone, PartialEq)]
pub struct StepExecution {
    step: Step,
    execution: Execution,
}
