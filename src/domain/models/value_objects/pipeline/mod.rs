// SPDX-FileCopyrightText: 2023 AGPL-3.0-or-later

use serde::{Deserialize, Serialize};

use crate::domain::core::{Identifier, ValueObject};

pub mod steps;

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq, Eq, Hash)]
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

impl ValueObject<PipelineIdentifier> for PipelineIdentifier {}
impl Identifier<PipelineIdentifier> for PipelineIdentifier {}
