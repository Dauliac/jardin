use regex::Regex;

use serde::{Deserialize, Serialize};
use thiserror::Error;

use crate::domain::{
    core::{Event, Identifier, ValueObject},
    models::ResponseKind,
};
use arbitrary::Arbitrary;

static REGEX: &str = r"^[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$";

#[derive(Error, Serialize, Deserialize, Debug, Clone, PartialEq, Hash, Eq)]
pub enum nameError {
    #[error("name {0} must respect regex `{}`", REGEX)]
    InvalidnameFormat(String),
}
impl ValueObject<nameError> for nameError {}
impl Event<nameError> for nameError {}
impl From<nameError> for Vec<ResponseKind> {
    fn from(value: nameError) -> Self {
        match value {
            nameError::InvalidnameFormat(_) => {
                vec![
                    ResponseKind::ClusternameError,
                    ResponseKind::ClusternameInvalidnameFormatError,
                ]
            }
        }
    }
}

#[derive(Arbitrary, Serialize, Deserialize, Debug, Clone, PartialEq, Eq, Hash)]
pub struct Nodename {
    pub value: String,
}
impl ValueObject<Nodename> for Nodename {}
impl Identifier<Nodename> for Nodename {}

fn check_name_specification(name: String) -> Result<String, nameError> {
    Regex::new(REGEX)
        .unwrap()
        .is_match(name.as_str())
        .then(|| Ok(name.clone()))
        .unwrap_or(Err(nameError::InvalidnameFormat(name)))
}

impl Nodename {
    pub fn new(value: String) -> Result<Self, nameError> {
        check_name_specification(value).map(|value| Self { value })
    }
}

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq, Eq, Hash)]
pub struct Clustername {
    value: String,
}

impl Clustername {
    pub fn new(value: String) -> Result<Self, nameError> {
        check_name_specification(value).map(|value| Self { value })
    }

    pub fn get_value(&self) -> &String {
        &self.value
    }
}
impl ValueObject<Clustername> for Clustername {}
impl Identifier<Clustername> for Clustername {}

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
    fn test_node_name() {
        let valid_name: String = Word(EN).fake();
        let name = Nodename::new(valid_name.clone()).unwrap();
        let name_clone = name.clone();
        let name_2 = Nodename::new(valid_name.clone()).unwrap();
        assert_eq!(name, name_clone);
        let mut hasher = DefaultHasher::new();
        assert_eq!(name.hash(&mut hasher), name_2.hash(&mut hasher));
        assert!(!format!("{:?}", name).is_empty());
        let json = serde_json::to_string(&name).unwrap();
        assert!(!json.is_empty());
        let private_serialized = serde_json::from_str::<Nodename>(json.as_str()).unwrap();
        assert_eq!(private_serialized, name);

        let invalids_names: Vec<String> = vec![
            Sentence(EN, 2..4).fake(),
            FreeEmail(EN).fake(),
            Title(EN).fake::<String>().to_lowercase(),
            "1&é&'(-è_çà)=^$ù*!:;,?./§%µ£".to_string(),
        ];
        invalids_names.iter().for_each(|name| {
            let result = Nodename::new(name.to_owned());
            assert!(result.is_err());
            let _ = result
                .map_err(|error| {
                    assert_eq!(error, nameError::InvalidnameFormat(name.to_owned()));
                })
                .map(|_| assert!(true));
        });
    }

    #[test]
    fn test_cluster_name() {
        let name = Clustername::new("test".to_string()).unwrap();
        let name_clone = name.clone();
        assert_eq!(name, name_clone);
        assert_eq!(name.get_value(), "test");
    }
}

// #[cfg(fuzzing)]
// mod fuzzing {
//     use super::*;
//     use afl::fuzz;

//     fuzz!(|name: Nodename| {
//         let is_alphanumeric = name
//             .get_value()
//             .chars()
//             .all(|char| char == '-' || char.is_ascii_alphanumeric() && char.is_ascii_lowercase());
//         let is_lower_that_61 = name.get_value().len() <= 61;
//         let is_valid = is_alphanumeric && is_lower_that_61;
//         is_valid.then(|| {
//             let name =
//                 Nodename::new(name.get_value().to_owned()).map_err(|_| assert!(false));
//             assert_eq!(name.is_ok(), true);
//         });
//     });
// }
