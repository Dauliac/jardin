use async_trait::async_trait;
use std::sync::{Arc, RwLock};

use crate::{
    application::services::cqrs_es::{
        command::{Command, CommandBus},
        event::{Event, EventBus},
    },
    domain::{
        core::{Aggregate, Entity},
        models::{
            aggregates::cluster::{Cluster, ClusterCommand, ClusterResult},
            value_objects::cluster::surname::ClusterSurname,
            DomainError, DomainEvent, DomainResponse,
        },
        repositories::ClusterRepository,
    },
};

pub struct MemoryCommandBus<R: ClusterRepository> {
    queue: Vec<Command>,
    repository: Arc<RwLock<R>>,
    event_bus: Arc<RwLock<dyn EventBus>>,
}

impl<R: ClusterRepository> MemoryCommandBus<R> {
    pub fn new(repository: Arc<RwLock<R>>, event_bus: Arc<RwLock<dyn EventBus>>) -> Self {
        Self {
            queue: Vec::new(),
            repository,
            event_bus,
        }
    }

    fn read(
        &self,
        command: &ClusterCommand,
        identifier: <Cluster as Entity<Cluster>>::Identifier,
    ) -> DomainResponse {
        let cluster = self.repository.read().unwrap().read(identifier).unwrap();
        match Self::handle(command, cluster) {
            Ok(event) => DomainResponse::Event(DomainEvent::Cluster(event)),
            Err(error) => DomainResponse::Error(DomainError::Cluster(error)),
        }
    }

    fn handle(command: &ClusterCommand, cluster: Arc<RwLock<Cluster>>) -> ClusterResult {
        cluster.read().unwrap().handle(command.to_owned())
    }

    fn extract_identifier(command: &Command) -> ClusterSurname {
        match command.get_command() {
            ClusterCommand::CreatePipeline {
                identifier,
                pipeline_identifier: _,
                steps: _,
            } => identifier.to_owned(),
            ClusterCommand::RunPipeline {
                identifier: _,
                dry_run: _,
            } => todo!(),
        }
    }

    fn publish_to_event_store(&mut self, event: DomainResponse) {
        self.event_bus.write().unwrap().publish(Event::new(event));
    }
}

#[async_trait]
impl<R: ClusterRepository + Sync + Send> CommandBus for MemoryCommandBus<R> {
    fn publish(&mut self, command: Command) {
        self.queue.push(command);
    }

    async fn run(&mut self) {
        self.queue
            .pop()
            .map(|command| (command.to_owned(), Self::extract_identifier(&command)))
            .map(|(command, identifier)| {
                let response = self.read(command.get_command(), identifier);
                self.publish_to_event_store(response);
            });
    }
}
