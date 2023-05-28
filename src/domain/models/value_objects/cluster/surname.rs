// SPDX-FileCopyrightText: 2023 AGPL-3.0-or-later

use regex::Regex;

use serde::{Deserialize, Serialize};
use thiserror::Error;

use crate::domain::core::ValueObject;

static REGEX: &str = r"^[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$";

#[derive(Error, Debug, Clone, PartialEq, Hash, Eq)]
pub enum SurnameError {
    #[error("Surname {0} must respect regex `{}`", REGEX)]
    InvalidSurnameFormat(String),
}

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq, Eq, Hash)]
pub struct NodeSurname {
    pub value: String,
}

impl NodeSurname {
    pub(crate) fn get_value(&self) -> &String {
        &self.value
    }
}

impl ValueObject<NodeSurname> for NodeSurname {
    fn equals(&self, value: &NodeSurname) -> bool {
        self.value.eq(value.get_value())
    }
}

fn check_surname_specification(surname: String) -> Result<String, SurnameError> {
    Regex::new(REGEX)
        .unwrap()
        .is_match(surname.as_str())
        .then(|| Ok(surname.clone()))
        .unwrap_or(Err(SurnameError::InvalidSurnameFormat(surname)))
}

impl NodeSurname {
    pub fn new(value: String) -> Result<Self, SurnameError> {
        check_surname_specification(value).map(|value| Self { value })
    }
}

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq, Eq, Hash)]
pub struct ClusterSurname {
    value: String,
}

impl ClusterSurname {
    pub fn new(value: String) -> Result<Self, SurnameError> {
        check_surname_specification(value).map(|value| Self { value })
    }

    pub fn get_value(&self) -> &String {
        &self.value
    }
}

impl ValueObject<ClusterSurname> for ClusterSurname {
    fn equals(&self, value: &ClusterSurname) -> bool {
        self.value.eq(value.get_value())
    }
}
