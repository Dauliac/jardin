// SPDX-FileCopyrightText: 2023 AGPL-3.0-or-later

use std::collections::HashMap;

use crate::domain::{
    models::{
        aggregates::cluster::Cluster,
        value_objects::cluster::{
            node::Role,
            surname::{ClusterSurname, NodeSurname},
        },
        DomainError, DomainEvent,
    },
    services::aggregate_declaration::NodeBuilder,
    use_cases::{deploy_use_case::UserStory as DeployUserStory, UseCases},
};

use super::config::model::Config;

pub fn deploy_cluster_to_production_with_default_pipeline(config: &Config) {
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
                .map(|surname| {
                    acc.insert(surname, node);
                    acc
                })
                .map_err(DomainError::Surname)
        })
        .map(|targets| {
            ClusterSurname::new(config.cluster.surname.to_owned())
                .map_err(|error| {
                    let _ = DomainError::Surname(error);
                    todo!("Crash the program here");
                })
                .map(|cluster_surname| {
                    Cluster::declare(cluster_surname, targets)
                        .map_err(|error| {
                            let _error = DomainError::Cluster(error);
                            todo!("Crash the program here and push it to event store");
                        })
                        .map(|(event, _cluster)| {
                            let _event = DomainEvent::Cluster(event);
                            todo!("Finish the use case here");
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

pub fn handle_deploy_user_story(user_story: DeployUserStory, config: &Config) {
    match user_story {
        DeployUserStory::DeployClusterToProductionWithDefaultPipeline => {
            deploy_cluster_to_production_with_default_pipeline(config)
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

pub fn start_domain_service(use_case: UseCases, config: &Config) {
    match use_case {
        UseCases::Deploy(deploy) => handle_deploy_user_story(deploy, config),
    }
}
