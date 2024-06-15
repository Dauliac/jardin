use crate::{
    application::cqrs_es::{
        command::{Command, CommandBus},
        event::{Event, EventBus, Response},
    },
    domain::{
        core::{Aggregate, Entity},
        models::{
            aggregates::cluster::{Cluster, ClusterCommand, ClusterResult},
            value_objects::cluster::name::Clustername,
            DomainError, DomainEvent, Response as DomainResponse,
        },
        repositories::ClusterRepository,
    },
};
use async_trait::async_trait;
use std::sync::{Arc, RwLock};

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

    fn extract_and_publish_event(
        &self,
        command: &ClusterCommand,
        identifier: <Cluster as Entity<Cluster>>::Identifier,
    ) -> Response {
        let cluster = self.repository.read().unwrap().read(identifier).unwrap();
        match Self::handle(command, cluster) {
            Ok(event) => From::from(DomainResponse::Event(DomainEvent::Cluster(event))),
            Err(error) => From::from(DomainResponse::Error(DomainError::Cluster(error))),
        }
    }

    fn handle(command: &ClusterCommand, cluster: Arc<RwLock<Cluster>>) -> ClusterResult {
        println!("handle {:?}", &command);
        cluster.read().unwrap().handle(command.to_owned())
    }

    fn extract_identifier(command: &Command) -> Clustername {
        match command.get_command() {
            ClusterCommand::CreatePipeline {
                identifier,
                pipeline_identifier: _,
                steps: _,
            } => identifier.to_owned(),
            ClusterCommand::RunPipeline {
                identifier,
                dry_run: _,
            } => identifier.to_owned(),
        }
    }

    fn publish_to_event_store(&mut self, event: Response) {
        self.event_bus.write().unwrap().publish(Event::new(event));
    }
}

#[async_trait]
impl<R: ClusterRepository + Sync + Send> CommandBus for MemoryCommandBus<R> {
    fn publish(&mut self, command: Command) {
        println!("{:?}", &command.get_command());
        self.queue.push(command);
    }

    async fn run(&mut self) {
        self.queue
            .pop()
            .map(|command| (command.to_owned(), Self::extract_identifier(&command)))
            .map(|(command, identifier)| {
                let response = self.extract_and_publish_event(command.get_command(), identifier);
                self.publish_to_event_store(response);
            });
    }
}
