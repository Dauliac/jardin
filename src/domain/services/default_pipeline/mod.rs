// SPDX-License-Identifier: AGPL-3.0-or-later

pub mod bootstrap_operating_system;
pub mod default_identifier;
pub mod platformize;

use std::collections::HashSet;

use crate::domain::value_objects::pipeline::{Pipeline, PipelineError};

use self::{
    bootstrap_operating_system::step::get_bootstrap_operating_systems_step,
    default_identifier::DefaultIdentifier, platformize::step::get_platformize_step,
};

pub struct DefaultPipelineIdentifier {}

impl DefaultIdentifier for DefaultPipelineIdentifier {
    const VALUE: &'static str = "default";
}

pub fn get_default_pipeline() -> Result<Pipeline, PipelineError> {
    let platformize = get_platformize_step(|| None);
    let bootstrap_next = Some(HashSet::from([platformize.get_identifier().clone()]));
    let bootstrap = get_bootstrap_operating_systems_step(bootstrap_next);
    let steps = Vec::from([bootstrap, platformize]);

    Pipeline::new(DefaultPipelineIdentifier::VALUE.to_string(), steps)
}
