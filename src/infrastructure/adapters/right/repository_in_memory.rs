// SPDX-FileCopyrightText: 2023 AGPL-3.0-or-later

use std::collections::HashMap;

use std::sync::{Arc, RwLock};

use crate::domain::{
    models::{aggregates::cluster::Cluster, value_objects::cluster::surname::ClusterSurname},
    repositories::{ClusterRepository, Repository},
};

pub struct ClusterRepositoryInMemory {
    clusters: HashMap<ClusterSurname, Arc<RwLock<Cluster>>>,
}

impl ClusterRepositoryInMemory {
    pub fn new() -> Self {
        Self {
            clusters: HashMap::new(),
        }
    }
}
impl ClusterRepository for ClusterRepositoryInMemory {}

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

impl Default for ClusterRepositoryInMemory {
    fn default() -> Self {
        Self::new()
    }
}
