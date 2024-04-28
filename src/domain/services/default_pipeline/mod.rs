pub mod bootstrap_operating_system;
pub mod default_identifier;
pub mod platformize;

use std::collections::HashSet;

use crate::domain::{
    core::Aggregate,
    models::{aggregates::cluster::Cluster, value_objects::pipeline::PipelineIdentifier},
};

use self::{
    bootstrap_operating_system::get_bootstrap_operating_systems_step,
    default_identifier::DefaultIdentifier, platformize::get_platformize_step,
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

pub fn get_default_pipeline(
    cluster: &mut Cluster,
) -> Result<<Cluster as Aggregate<Cluster>>::Command, <Cluster as Aggregate<Cluster>>::Error> {
    let identifier = DefaultPipelineIdentifier::create();
    let platformize_step = get_platformize_step(|| None);
    let bootstrap_next = Some(HashSet::from([platformize_step.identifier().clone()]));
    let bootstrap_step = get_bootstrap_operating_systems_step(bootstrap_next);
    let steps = Vec::from([From::from(bootstrap_step), From::from(platformize_step)]);
    cluster.order_pipeline_creation(identifier, steps)
}
