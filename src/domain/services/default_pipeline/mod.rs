// SPDX-FileCopyrightText: 2023 AGPL-3.0-or-later

pub mod bootstrap_operating_system;
pub mod default_identifier;
pub mod platformize;

use std::collections::HashSet;

use crate::domain::{
    core::Aggregate,
    models::{aggregates::cluster::Cluster, value_objects::pipeline::PipelineIdentifier},
};

use self::{
    bootstrap_operating_system::step::get_bootstrap_operating_systems_step,
    default_identifier::DefaultIdentifier, platformize::step::get_platformize_step,
};

pub struct DefaultPipelineIdentifier {}

impl DefaultIdentifier for DefaultPipelineIdentifier {
    const VALUE: &'static str = "default";
}

impl DefaultPipelineIdentifier {
    fn create() -> PipelineIdentifier {
        PipelineIdentifier::new(Self::VALUE.to_string())
    }
}

fn get_default_pipeline(
    cluster: Cluster,
) -> Result<<Cluster as Aggregate<Cluster>>::Event, <Cluster as Aggregate<Cluster>>::Error> {
    let platformize = get_platformize_step(|| None);
    let bootstrap_next = Some(HashSet::from([platformize.get_identifier().clone()]));
    let bootstrap = get_bootstrap_operating_systems_step(bootstrap_next);
    let steps = Vec::from([bootstrap, platformize]);
    let pipeline_identifier = DefaultPipelineIdentifier::create();

    cluster.create_pipeline(pipeline_identifier, steps)
}
