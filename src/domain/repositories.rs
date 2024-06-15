use std::sync::{Arc, RwLock};

use super::models::{aggregates::cluster::Cluster, value_objects::cluster::name::Clustername};

pub trait Repository<I, T>: Sync + Send {
    fn read(&self, identifier: I) -> Option<Arc<RwLock<T>>>;
    fn write(&mut self, aggregate: Arc<RwLock<T>>);
}

pub trait ClusterRepository: Repository<Clustername, Cluster> {}
