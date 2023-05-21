use std::collections::HashMap;

use std::sync::{Arc, RwLock};

use crate::domain::value_objects::cluster::cluster::Cluster;
use crate::domain::value_objects::cluster::surname::ClusterSurname;
use crate::domain::{
    repositories::Repository,
    value_objects::pipeline::pipeline::{Pipeline, PipelineIdentifier},
};

pub struct PipelineRepositoryInMemory {
    pipelines: HashMap<PipelineIdentifier, Arc<RwLock<Pipeline>>>,
}

impl Repository<PipelineIdentifier, Pipeline> for PipelineRepositoryInMemory {
    fn read(&self, identifier: PipelineIdentifier) -> Option<Arc<RwLock<Pipeline>>> {
        let pipeline = self.pipelines.get(&identifier);
        match pipeline {
            Some(pipeline) => Some(pipeline.clone()),
            None => None,
        }
    }
    fn write(&mut self, aggregate: Arc<RwLock<Pipeline>>) {
        let identifier = aggregate.read().unwrap().get_identifier().clone();
        self.pipelines.insert(identifier, aggregate);
    }
}

pub struct ClusterRepositoryInMemory {
    clusters: HashMap<ClusterSurname, Arc<RwLock<Cluster>>>,
}

impl Repository<ClusterSurname, Cluster> for ClusterRepositoryInMemory {
    fn read(&self, identifier: ClusterSurname) -> Option<Arc<RwLock<Cluster>>> {
        let cluster = self.clusters.get(&identifier);
        match cluster {
            Some(cluster) => Some(cluster.clone()),
            None => None,
        }
    }
    fn write(&mut self, aggregate: Arc<RwLock<Cluster>>) {
        let identifier = aggregate.read().unwrap().get_surname().clone();
        self.clusters.insert(identifier, aggregate);
    }
}
