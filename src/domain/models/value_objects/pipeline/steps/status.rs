use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq, Eq, Hash)]
pub enum FinalState {
    Success,
    Failure,
    Skipped,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq, Eq, Hash)]
pub enum Status {
    ToDo,
    Doing,
    Done(FinalState),
}
