// SPDX-FileCopyrightText: 2023 AGPL-3.0-or-later

use regex::Regex;

use serde::{Deserialize, Serialize};
use thiserror::Error;

use crate::domain::{
    core::{Event, Identifier, ValueObject},
    models::DomainResponseKinds,
};
use arbitrary::Arbitrary;

static REGEX: &str = r"^[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$";

#[derive(Error, Serialize, Deserialize, Debug, Clone, PartialEq, Hash, Eq)]
pub enum SurnameError {
    #[error("Surname {0} must respect regex `{}`", REGEX)]
    InvalidSurnameFormat(String),
}
impl ValueObject<SurnameError> for SurnameError {}
impl Event<SurnameError> for SurnameError {}
impl From<SurnameError> for Vec<DomainResponseKinds> {
    fn from(value: SurnameError) -> Self {
        match value {
            SurnameError::InvalidSurnameFormat(_) => {
                vec![
                    DomainResponseKinds::ClusterSurnameError,
                    DomainResponseKinds::ClusterSurnameInvalidSurnameFormatError,
                ]
            }
        }
    }
}

#[derive(Arbitrary, Serialize, Deserialize, Debug, Clone, PartialEq, Eq, Hash)]
pub struct NodeSurname {
    pub value: String,
}
impl ValueObject<NodeSurname> for NodeSurname {}
impl Identifier<NodeSurname> for NodeSurname {}

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
impl ValueObject<ClusterSurname> for ClusterSurname {}
impl Identifier<ClusterSurname> for ClusterSurname {}

#[cfg(test)]
mod tests {
    use fake::{
        faker::{
            internet::raw::FreeEmail,
            job::raw::Title,
            lorem::raw::{Sentence, Word},
        },
        locales::EN,
        Fake,
    };
    use serde_json;
    use std::{collections::hash_map::DefaultHasher, hash::Hash};

    use super::*;

    #[test]
    fn test_node_surname() {
        let valid_surname: String = Word(EN).fake();
        let surname = NodeSurname::new(valid_surname.clone()).unwrap();
        let surname_clone = surname.clone();
        let surname_2 = NodeSurname::new(valid_surname.clone()).unwrap();
        assert_eq!(surname, surname_clone);
        let mut hasher = DefaultHasher::new();
        assert_eq!(surname.hash(&mut hasher), surname_2.hash(&mut hasher));
        assert!(!format!("{:?}", surname).is_empty());
        let json = serde_json::to_string(&surname).unwrap();
        assert!(!json.is_empty());
        let private_serialized = serde_json::from_str::<NodeSurname>(json.as_str()).unwrap();
        assert_eq!(private_serialized, surname);

        let invalids_surnames: Vec<String> = vec![
            Sentence(EN, 2..4).fake(),
            FreeEmail(EN).fake(),
            Title(EN).fake::<String>().to_lowercase(),
            "1&é&'(-è_çà)=^$ù*!:;,?./§%µ£".to_string(),
        ];
        invalids_surnames.iter().for_each(|surname| {
            let result = NodeSurname::new(surname.to_owned());
            assert!(result.is_err());
            let _ = result
                .map_err(|error| {
                    assert_eq!(
                        error,
                        SurnameError::InvalidSurnameFormat(surname.to_owned())
                    );
                })
                .map(|_| assert!(true));
        });
    }

    #[test]
    fn test_cluster_surname() {
        let surname = ClusterSurname::new("test".to_string()).unwrap();
        let surname_clone = surname.clone();
        assert_eq!(surname, surname_clone);
        assert_eq!(surname.get_value(), "test");
    }
}

// #[cfg(fuzzing)]
// mod fuzzing {
//     use super::*;
//     use afl::fuzz;

//     fuzz!(|surname: NodeSurname| {
//         let is_alphanumeric = surname
//             .get_value()
//             .chars()
//             .all(|char| char == '-' || char.is_ascii_alphanumeric() && char.is_ascii_lowercase());
//         let is_lower_that_61 = surname.get_value().len() <= 61;
//         let is_valid = is_alphanumeric && is_lower_that_61;
//         is_valid.then(|| {
//             let surname =
//                 NodeSurname::new(surname.get_value().to_owned()).map_err(|_| assert!(false));
//             assert_eq!(surname.is_ok(), true);
//         });
//     });
// }
