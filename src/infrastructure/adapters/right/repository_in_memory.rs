use crate::domain::{
    models::{aggregates::cluster::Cluster, value_objects::cluster::name::Clustername},
    repositories::{ClusterRepository, Repository},
};
use std::collections::HashMap;
use std::sync::{Arc, RwLock};

pub struct ClusterRepositoryInMemory {
    clusters: HashMap<Clustername, Arc<RwLock<Cluster>>>,
}

impl ClusterRepositoryInMemory {
    pub fn new() -> Self {
        Self {
            clusters: HashMap::new(),
        }
    }
}
impl ClusterRepository for ClusterRepositoryInMemory {}

impl Repository<Clustername, Cluster> for ClusterRepositoryInMemory {
    fn read(&self, identifier: Clustername) -> Option<Arc<RwLock<Cluster>>> {
        let cluster = self.clusters.get(&identifier);
        cluster.cloned()
    }
    fn write(&mut self, aggregate: Arc<RwLock<Cluster>>) {
        let identifier = aggregate.read().unwrap().get_name().clone();
        println!("identifier: {:?}", &identifier);
        self.clusters.insert(identifier, aggregate);
    }
}

impl Default for ClusterRepositoryInMemory {
    fn default() -> Self {
        Self::new()
    }
}
