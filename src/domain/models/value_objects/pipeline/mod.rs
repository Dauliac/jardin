// SPDX-FileCopyrightText: 2023 AGPL-3.0-or-later

use serde::{Deserialize, Serialize};

use crate::domain::core::ValueObject;

pub mod steps;

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
pub struct PipelineIdentifier {
    pub value: String,
}

impl PipelineIdentifier {
    pub fn new(value: String) -> Self {
        Self { value }
    }

    pub(crate) fn get_value(&self) -> &String {
        &self.value
    }
}

impl ValueObject<PipelineIdentifier> for PipelineIdentifier {
    fn equals(&self, value: &PipelineIdentifier) -> bool {
        self.value.eq(value.get_value())
    }
}
