// SPDX-License-Identifier: AGPL-3.0-or-later

use std::collections::HashMap;

use std::sync::{Arc, RwLock};

use crate::domain::value_objects::cluster::cluster::Cluster;
use crate::domain::value_objects::cluster::surname::ClusterSurname;
use crate::domain::{
    repositories::Repository,
    value_objects::pipeline::{Pipeline, PipelineIdentifier},
};

pub struct PipelineRepositoryInMemory {
    pipelines: HashMap<PipelineIdentifier, Arc<RwLock<Pipeline>>>,
}

impl Repository<PipelineIdentifier, Pipeline> for PipelineRepositoryInMemory {
    fn read(&self, identifier: PipelineIdentifier) -> Option<Arc<RwLock<Pipeline>>> {
        let pipeline = self.pipelines.get(&identifier);
        pipeline.cloned()
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
        cluster.cloned()
    }
    fn write(&mut self, aggregate: Arc<RwLock<Cluster>>) {
        let identifier = aggregate.read().unwrap().get_surname().clone();
        self.clusters.insert(identifier, aggregate);
    }
}
