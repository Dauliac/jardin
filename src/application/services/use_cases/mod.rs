// SPDX-FileCopyrightText: 2023 AGPL-3.0-or-later

use std::{
    collections::HashMap,
    sync::{Arc, RwLock},
};

use crate::{
    application::services::cqrs_es::{command::Command, event::Event},
    domain::{
        models::{
            aggregates::cluster::Cluster,
            value_objects::cluster::{
                node::Role,
                surname::{ClusterSurname, NodeSurname},
            },
            DomainError, DomainEvent, DomainResponse, DomainResponseKinds,
        },
        repositories::ClusterRepository,
        services::{aggregate_declaration::NodeBuilder, default_pipeline::get_default_pipeline},
        use_cases::{deploy_use_case::UserStory as DeployUserStory, UseCases},
    },
    user_interface::Logger,
};

use super::{
    config::model::Config,
    cqrs_es::{
        command::CommandBus,
        event::{EventBus, EventHandlers},
    },
};

pub fn deploy_cluster_to_production_with_default_pipeline(
    config: &Config,
    repository: Arc<RwLock<dyn ClusterRepository>>,
    event_bus: Arc<RwLock<dyn EventBus>>,
    command_bus: Arc<RwLock<dyn CommandBus>>,
) {
    let _targets = config
        .cluster
        .targets
        .iter()
        .map(|(node_identifier, node)| {
            let builder = NodeBuilder::new(
                node.surname.to_owned(),
                node.name_server.to_owned(),
                node.ip,
                node.ssh_key_path.to_owned(),
                match node.role {
                    super::config::model::Role::Leader => Role::Leader,
                    super::config::model::Role::Follower => Role::Follower,
                },
            );
            (node_identifier.to_owned(), builder.build())
        })
        .try_fold(HashMap::new(), |mut acc, (node_identifier, node)| {
            let node = node?;
            NodeSurname::new(node_identifier)
                .map_err(|error| {
                    let error = DomainError::Surname(error.to_owned());
                    let event = Event::new(DomainResponse::Error(error.to_owned()));
                    event_bus.write().unwrap().publish(event);
                    error
                })
                .map(|surname| {
                    acc.insert(surname, node);
                    acc
                })
        })
        .map(|targets| {
            ClusterSurname::new(config.cluster.surname.to_owned())
                .map_err(|error| {
                    let event = Event::new(DomainResponse::Error(DomainError::Surname(error)));
                    event_bus.write().unwrap().publish(event);
                })
                .map(|cluster_surname| {
                    Cluster::declare(cluster_surname, targets)
                        .map_err(|error| {
                            let event =
                                Event::new(DomainResponse::Error(DomainError::Cluster(error)));
                            event_bus.write().unwrap().publish(event);
                        })
                        .map(|(event, cluster)| {
                            let event =
                                Event::new(DomainResponse::Event(DomainEvent::Cluster(event)));
                            event_bus.write().unwrap().publish(event);
                            get_default_pipeline(cluster.to_owned())
                                .map_err(|pipeline_error| {
                                    let event = Event::new(DomainResponse::Error(
                                        DomainError::Cluster(pipeline_error),
                                    ));
                                    event_bus.write().unwrap().publish(event);
                                })
                                .map(|command| {
                                    let command = Command::new(command);
                                    command_bus.write().unwrap().publish(command);
                                    let cluster = Arc::new(RwLock::new(cluster));
                                    // TODO: add dry_run option from config
                                    let command = Command::new(
                                        cluster.write().unwrap().order_to_run_pipeline(true),
                                    );
                                    command_bus.write().unwrap().publish(command);

                                    repository.write().unwrap().write(cluster);
                                })
                                .ok();
                        })
                        .ok();
                })
        });
}

pub fn deploy_cluster_to_production_with_default_pipeline_in_dry_run_mode(_config: &Config) {
    println!("BBBB")
}

pub fn deploy_cluster_to_develop_with_default_pipeline_in_dry_run_mode(_config: &Config) {
    println!("CCCC")
}

pub fn deploy_cluster_to_develop_with_default_pipeline(_config: &Config) {
    println!("DDDD")
}

pub fn handle_deploy_user_story(
    user_story: DeployUserStory,
    config: &Config,
    repository: Arc<RwLock<dyn ClusterRepository>>,
    event_bus: Arc<RwLock<dyn EventBus>>,
    command_bus: Arc<RwLock<dyn CommandBus>>,
) {
    match user_story {
        DeployUserStory::DeployClusterToProductionWithDefaultPipeline => {
            deploy_cluster_to_production_with_default_pipeline(
                config,
                repository,
                event_bus,
                command_bus,
            )
        }
        DeployUserStory::DeployClusterToProductionWithDefaultPipelineInDryRunMode => {
            deploy_cluster_to_production_with_default_pipeline_in_dry_run_mode(config)
        }
        DeployUserStory::DeployClusterToDevelopWithDefaultPipelineInDryRunMode => {
            deploy_cluster_to_develop_with_default_pipeline(config)
        }
        DeployUserStory::DeployClusterToDevelopWithDefaultPipeline => {
            deploy_cluster_to_develop_with_default_pipeline_in_dry_run_mode(config)
        }
    };
}

pub fn start_domain_service(
    use_case: UseCases,
    config: &Config,
    repository: Arc<RwLock<dyn ClusterRepository>>,
    event_bus: Arc<RwLock<dyn EventBus>>,
    command_bus: Arc<RwLock<dyn CommandBus>>,
    logger: Arc<RwLock<Logger>>,
) {
    // TODO: check if debug mode is enabled
    let logger = EventHandlers::Logger(logger);
    let response = DomainResponseKinds::Error;
    event_bus
        .write()
        .unwrap()
        .subscribe(response, logger.clone());
    let response = DomainResponseKinds::Event;
    event_bus.write().unwrap().subscribe(response, logger);

    match use_case {
        UseCases::Deploy(deploy) => {
            handle_deploy_user_story(deploy, config, repository, event_bus, command_bus)
        }
    }
}
