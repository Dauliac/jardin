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

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
pub struct Output {
    stdout: String,
    stderr: String,
    return_code: ReturnCode,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
pub struct Execution {
    start_timestamp: Duration,
    end_timestamp: Duration,
    status: Status,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
pub struct JobExecution {
    job: Job,
    output: Output,
    execution: Execution,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
pub struct CheckJobExecution {
    step: CheckJob,
    retried: Retry,
    execution: Execution,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
pub struct StepExecution {
    step: Step,
    execution: Execution,
}

#[cfg(test)]
pub mod tests {

    use super::*;

    #[test]
    fn test_output() {
        let output = Output {
            stdout: "stdout".to_string(),
            stderr: "stderr".to_string(),
            return_code: 0,
        };
        assert_eq!(output, output);
    }

    // #[test]
    // fn test_execution() {
    //     let execution = Execution {
    //         start_timestamp: Duration::from_secs(0),
    //         end_timestamp: Duration::from_secs(0),
    //         status: Status::Done(FinalState::Success()),
    //     };
    //     assert_eq!(execution, execution);
    // }

    // #[test]
    // fn test_std_out() {
    //     let std_out = "stdout".to_string();
    //     assert_eq!(std_out, std_out);
    // }

    // #[test]
    // fn test_std_err() {
    //     let std_err = "stderr".to_string();
    //     assert_eq!(std_err, std_err);
    // }

    // #[test]
    // fn test_return_code() {
    //     let return_code = 0;
    //     assert_eq!(return_code, return_code);
    // }

    // #[test]
    // fn test_start_timestamp() {
    //     let start_timestamp = Duration::from_secs(0);
    //     assert_eq!(start_timestamp, start_timestamp);
    // }

    // #[test]
    // fn test_end_timestamp() {
    //     let end_timestamp = Duration::from_secs(0);
    //     assert_eq!(end_timestamp, end_timestamp);
    // }

    // #[test]
    // fn test_status() {
    //     let status = Status::Done(FinalState::Success());
    //     assert_eq!(status, status);
    // }
}
