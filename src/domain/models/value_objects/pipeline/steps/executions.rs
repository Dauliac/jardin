use serde::{Deserialize, Serialize};

pub type StdOut = String;
pub type StdErr = String;
pub type ReturnCode = u8;

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq, Eq, Hash)]
pub struct Output {
    stdout: String,
    stderr: String,
    return_code: ReturnCode,
}
