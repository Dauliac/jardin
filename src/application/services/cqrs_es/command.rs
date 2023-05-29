use async_trait::async_trait;

use std::{
    sync::{Arc, RwLock},
    time::SystemTime,
};

use crate::domain::{
    core::{Aggregate, Entity},
    models::aggregates::cluster::{Cluster, ClusterCommand, ClusterResult},
    repositories::ClusterRepository,
};

pub enum CommandPriority {
    Low = 30,
    Normal = 60,
    High = 90,
}

pub struct Command<R: ClusterRepository> {
    repository: Arc<RwLock<R>>,
    command: ClusterCommand,
    timestamp: Option<SystemTime>,
    priority: CommandPriority,
}

impl<R: ClusterRepository> Command<R> {
    pub fn new(command: ClusterCommand, repository: Arc<RwLock<R>>) -> Self {
        let priority = match command {
            ClusterCommand::CreatePipeline {
                identifier: _,
                pipeline_identifier: _,
                steps: _,
            } => CommandPriority::High,
            // _ => {
            //     CommandPriority::Normal
            // },
        };

        Self {
            repository,
            command,
            timestamp: None,
            priority,
        }
    }

    pub async fn run(&mut self) -> ClusterResult {
        self.timestamp = Some(SystemTime::now());
        match self.command.clone() {
            ClusterCommand::CreatePipeline {
                identifier,
                pipeline_identifier: _,
                steps: _,
            } => {
                self.read(identifier, |cluster| self.write(cluster))
                // TODO: publish events in bus
                // TODO: notify commandBus listeners
            }
        }
    }

    fn read(
        &self,
        identifier: <Cluster as Entity<Cluster>>::Identifier,
        f: impl FnOnce(Arc<RwLock<Cluster>>) -> ClusterResult,
    ) -> ClusterResult {
        let repository = self.repository.read().unwrap();
        repository.read(identifier).map(f).unwrap_or_else(|| {
            // TODO: find way to define error here, is it a domain error?
            panic!("Error: cluster not found");
        })
    }

    fn write(&self, cluster: Arc<RwLock<Cluster>>) -> ClusterResult {
        cluster
            .write()
            .unwrap()
            .handle(self.command.clone())
            .map(|event| {
                let mut repository = self.repository.write().unwrap();
                repository.write(cluster.to_owned());
                event
            })
    }
}

#[async_trait]
pub trait CommandBus<R: ClusterRepository> {
    async fn publish(&self, command: Command<R>);
    async fn run(&mut self);
}
