use crate::{
    application::use_cases::ClusterDeploymentService,
    domain::models::{Response as DomainResponse, ResponseKind as DomainResponseKind},
    infrastructure::{
        Response as InfrastructureResponse, ResponseKind as InfrastructureResponseKind,
    },
    user_interface::Logger,
};
use async_trait::async_trait;
use serde::{Deserialize, Serialize};
use std::{
    fmt::Debug,
    sync::{Arc, RwLock},
    time::SystemTime,
};

#[derive(Serialize, Deserialize, Debug, PartialEq, Clone)]
pub enum Response {
    Domain(DomainResponse),
    Infra(InfrastructureResponse),
}

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub enum ResponseKind {
    Domain(DomainResponseKind),
    Infra(InfrastructureResponseKind),
}

impl From<Response> for Vec<ResponseKind> {
    fn from(value: Response) -> Self {
        let mut kind = vec![];
        let kind = match value {
            Response::Domain(response) => From::from(response),
            Response::Infra(response) => From::from(response),
        };
        vec![kind]
    }
}

#[derive(Serialize, Deserialize, Debug, PartialEq, Clone)]
pub struct Event {
    pub response: Response,
    pub timestamp: SystemTime,
}

impl Event {
    pub fn new(response: DomainResponse) -> Self {
        let response = Response::Domain(response);
        Self {
            response,
            timestamp: SystemTime::now(),
        }
    }
}

pub trait EventHandler {
    fn notify(&mut self, response: Response);
}

#[derive(Clone)]
pub enum EventHandlers {
    Logger(Arc<RwLock<Logger>>),
    Deploy(Arc<RwLock<ClusterDeploymentService>>),
}

#[async_trait]
pub trait EventBus: Send + Sync {
    fn subscribe(&mut self, response: ResponseKind, handler: EventHandlers);
    fn unsubscribe(&mut self, response: ResponseKind, handler: &EventHandlers);
    fn publish(&mut self, event: Event);
    async fn run(&mut self);
}
