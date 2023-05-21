use std::sync::{Arc, RwLock};

use super::value_objects::{
    cluster::{cluster::Cluster, surname::ClusterSurname},
    pipeline::pipeline::{Pipeline, PipelineIdentifier},
};

pub trait Repository<I, T> {
    fn read(&self, identifier: I) -> Option<Arc<RwLock<T>>>;
    fn write(&mut self, aggregate: Arc<RwLock<T>>);
}

pub trait PipelineRepository: Repository<PipelineIdentifier, Pipeline> {}
pub trait ClusterRepository: Repository<ClusterSurname, Cluster> {}
