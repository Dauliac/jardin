// SPDX-License-Identifier: AGPL-3.0-or-later

use regex::Regex;

use thiserror::Error;

static REGEX: &str = r"^[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$";

#[derive(Error, Debug, Clone, PartialEq, Hash, Eq)]
pub enum SurnameError {
    #[error("Surname {0} must respect regex `{}`", REGEX)]
    InvalidSurnameFormat(String),
}
#[derive(Clone, PartialEq, Hash, Eq)]
pub struct NodeSurname {
    pub value: String,
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

#[derive(Clone, PartialEq, Hash, Eq)]
pub struct ClusterSurname {
    pub value: String,
}

impl ClusterSurname {
    pub fn new(value: String) -> Result<Self, SurnameError> {
        check_surname_specification(value).map(|value| Self { value })
    }
}
