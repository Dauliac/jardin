mod production_with_default_pipeline;

use super::{
    config::model::Config,
    cqrs_es::{
        command::{Command, CommandBus},
        event::{EventBus, EventHandler, EventHandlers},
    },
};
use crate::{
    domain::{
        models::{aggregates::cluster::Cluster, Response, ResponseKind},
        repositories::ClusterRepository,
        use_cases::{deploy_use_case::UserStory as DeployUserStory, UseCases},
    },
    user_interface::Logger,
};
use std::sync::{Arc, RwLock};

#[derive(Clone)]
pub struct ClusterDeploymentService {
    cluster: Arc<RwLock<Cluster>>,
    command_bus: Arc<RwLock<dyn CommandBus>>,
    event_bus: Arc<RwLock<dyn EventBus>>,
}

impl ClusterDeploymentService {
    pub fn new(
        cluster: Arc<RwLock<Cluster>>,
        command_bus: Arc<RwLock<dyn CommandBus>>,
        event_bus: Arc<RwLock<dyn EventBus>>,
    ) -> Self {
        Self {
            cluster,
            command_bus,
            event_bus,
        }
    }
    fn unsubscribe(&self) {
        let handler = EventHandlers::Deploy(Arc::new(RwLock::new(self.clone())));
        self.event_bus
            .write()
            .unwrap()
            .unsubscribe(ResponseKind::ClusterPipelineCreatedEvent, &handler);
    }
}

impl EventHandler for ClusterDeploymentService {
    fn notify(&mut self, _response: Response) {
        let command = Command::new(self.cluster.write().unwrap().order_to_run_pipeline(true));
        self.command_bus.write().unwrap().publish(command);
        self.unsubscribe();
    }
}

async fn handle_deploy_user_story(
    user_story: DeployUserStory,
    config: &Config,
    repository: Arc<RwLock<dyn ClusterRepository>>,
    event_bus: Arc<RwLock<dyn EventBus>>,
    command_bus: Arc<RwLock<dyn CommandBus>>,
) {
    match user_story {
        DeployUserStory::DeployClusterToProductionWithDefaultPipeline => {
            production_with_default_pipeline::deploy(config, repository, event_bus, command_bus)
                .await
        }
        DeployUserStory::DeployClusterToProductionWithDefaultPipelineInDryRunMode => {
            production_with_default_pipeline::dry_run_deploy(
                config,
                repository,
                event_bus,
                command_bus,
            )
            .await
        }
    };
}

pub async fn start_domain_service(
    use_case: UseCases,
    config: &Config,
    repository: Arc<RwLock<dyn ClusterRepository>>,
    event_bus: Arc<RwLock<dyn EventBus>>,
    command_bus: Arc<RwLock<dyn CommandBus>>,
    logger: Arc<RwLock<Logger>>,
) {
    // TODO: check if debug mode is enabled
    let logger = EventHandlers::Logger(logger);
    let response = ResponseKind::Error;
    event_bus
        .write()
        .unwrap()
        .subscribe(response, logger.clone());
    let response = ResponseKind::Event;
    event_bus.write().unwrap().subscribe(response, logger);

    match use_case {
        UseCases::Deploy(deploy) => {
            handle_deploy_user_story(deploy, config, repository, event_bus, command_bus).await
        }
    }
}
