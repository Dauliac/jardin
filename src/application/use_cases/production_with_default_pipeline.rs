use crate::{
    application::{
        config,
        cqrs_es::{
            command::{Command, CommandBus},
            event::{Event, EventBus, EventHandlers},
        },
    },
    domain::{
        models::{
            aggregates::cluster::Cluster,
            value_objects::cluster::{
                name::{Clustername, Nodename},
                node::{Node, Role},
            },
            DomainError, DomainEvent, Response, ResponseKind,
        },
        repositories::ClusterRepository,
        services::{aggregate_declaration::NodeBuilder, default_pipeline::get_default_pipeline},
    },
};
use std::{
    collections::HashMap,
    sync::{Arc, RwLock},
};

use super::ClusterDeploymentService;

pub async fn deploy(
    config: &config::model::Config,
    repository: Arc<RwLock<dyn ClusterRepository>>,
    event_bus: Arc<RwLock<dyn EventBus>>,
    command_bus: Arc<RwLock<dyn CommandBus>>,
) {
    let _ = create_nodes(config, event_bus.clone()).map(|nodes| {
        let _cluster = create_cluster(config, nodes, command_bus, repository, event_bus);
    });
}

pub async fn dry_run_deploy(
    config: &config::model::Config,
    repository: Arc<RwLock<dyn ClusterRepository>>,
    event_bus: Arc<RwLock<dyn EventBus>>,
    command_bus: Arc<RwLock<dyn CommandBus>>,
) {
    let _ = create_nodes(config, event_bus.clone()).map(|nodes| {
        let _cluster = create_cluster(config, nodes, command_bus, repository, event_bus);
    });
}

fn create_nodes(
    config: &config::model::Config,
    event_bus: Arc<RwLock<dyn EventBus>>,
) -> Result<HashMap<Nodename, Node>, DomainError> {
    config
        .cluster
        .nodes
        .iter()
        .map(|(node_identifier, node)| {
            let builder = NodeBuilder::new(
                node.name.to_owned(),
                node.name.to_owned(),
                node.ip,
                match node.role {
                    config::model::Role::Leader => Role::Leader,
                    config::model::Role::Follower => Role::Follower,
                },
            );
            (node_identifier.to_owned(), builder.build())
        })
        .try_fold(HashMap::new(), |mut acc, (node_identifier, node)| {
            let node = node?;
            Nodename::new(node_identifier)
                .map_err(|error| {
                    let error = DomainError::name(error);
                    let event = Event::new(Response::Error(error.to_owned()));
                    event_bus.write().unwrap().publish(event);
                    error
                })
                .map(|name| {
                    acc.insert(name, node);
                    acc
                })
        })
}

fn create_cluster_name(
    config: &config::model::Config,
    event_bus: Arc<RwLock<dyn EventBus>>,
) -> Result<Clustername, DomainError> {
    Clustername::new(config.cluster.name.to_owned()).map_err(|error| {
        let domain_error = DomainError::name(error);
        let event = Event::new(Response::Error(domain_error.clone()));
        event_bus.write().unwrap().publish(event);
        domain_error
    })
}

fn create_cluster(
    config: &config::model::Config,
    nodes: HashMap<Nodename, Node>,
    command_bus: Arc<RwLock<dyn CommandBus>>,
    repository: Arc<RwLock<dyn ClusterRepository>>,
    event_bus: Arc<RwLock<dyn EventBus>>,
) -> Result<Arc<RwLock<Cluster>>, DomainError> {
    let cluster_name = create_cluster_name(config, event_bus.clone())?;
    let (event, mut cluster) = Cluster::declare(cluster_name, nodes).map_err(|error| {
        let domain_error = DomainError::Cluster(error);
        let event = Event::new(Response::Error(domain_error.clone()));
        event_bus.write().unwrap().publish(event);
        domain_error
    })?;
    let command = get_default_pipeline(&mut cluster).map_err(|err| {
        let domain_error = DomainError::Cluster(err);
        let event = Event::new(Response::Error(domain_error.clone()));
        event_bus.write().unwrap().publish(event);
        domain_error
    })?;
    let cluster = Arc::new(RwLock::new(cluster));
    repository.write().unwrap().write(cluster.to_owned());
    let event = Event::new(Response::Event(DomainEvent::Cluster(event)));
    event_bus.write().unwrap().publish(event);
    let command = Command::new(command);
    let handler = EventHandlers::Deploy(Arc::new(RwLock::new(ClusterDeploymentService::new(
        cluster.clone(),
        command_bus.clone(),
        event_bus.clone(),
    ))));
    event_bus
        .write()
        .unwrap()
        .subscribe(ResponseKind::ClusterPipelineCreatedEvent, handler);
    command_bus.write().unwrap().publish(command);
    Ok(cluster)
}
