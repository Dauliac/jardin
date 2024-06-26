use serde::{Deserialize, Serialize};

use crate::domain::core::{Identifier, ValueObject};

pub mod steps;

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq, Eq, Hash)]
pub struct PipelineIdentifier {
    value: String,
}

impl PipelineIdentifier {
    pub fn new(value: String) -> Self {
        Self { value }
    }

    pub fn get_value(&self) -> &String {
        &self.value
    }
}

impl ValueObject<PipelineIdentifier> for PipelineIdentifier {}
impl Identifier<PipelineIdentifier> for PipelineIdentifier {}
