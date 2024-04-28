use serde::{Deserialize, Serialize};

pub mod adapters;

#[derive(Serialize, Deserialize, Debug, PartialEq, Clone)]
pub enum Response {
    Left(),
    Right(),
}

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub enum ResponseKind {}
