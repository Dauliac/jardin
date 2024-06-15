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

impl From<DomainResponse> for Response {
    fn from(value: DomainResponse) -> Self {
        Response::Domain(value)
    }
}

impl From<InfrastructureResponse> for Response {
    fn from(value: InfrastructureResponse) -> Self {
        Response::Infra(value)
    }
}

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub enum ResponseKind {
    Domain(DomainResponseKind),
    Infra(InfrastructureResponseKind),
}

impl From<DomainResponseKind> for ResponseKind {
    fn from(value: DomainResponseKind) -> Self {
        ResponseKind::Domain(value)
    }
}

impl From<InfrastructureResponseKind> for ResponseKind {
    fn from(value: InfrastructureResponseKind) -> Self {
        ResponseKind::Infra(value)
    }
}

impl From<Response> for Vec<ResponseKind> {
    fn from(value: Response) -> Self {
        match value {
            Response::Domain(response) => {
                let response: Vec<DomainResponseKind> = From::from(response);
                response.into_iter().map(ResponseKind::Domain).collect()
            }
            Response::Infra(response) => {
                let response: Vec<InfrastructureResponseKind> = From::from(response);
                response.into_iter().map(ResponseKind::Infra).collect()
            }
        }
    }
}

#[derive(Serialize, Deserialize, Debug, PartialEq, Clone)]
pub struct Event {
    pub response: Response,
    pub timestamp: SystemTime,
}

impl Event {
    pub fn new(response: Response) -> Self {
        Self {
            response,
            timestamp: SystemTime::now(),
        }
    }
}

impl From<DomainResponse> for Event {
    fn from(response: DomainResponse) -> Self {
        Self::new(Response::Domain(response))
    }
}

impl From<InfrastructureResponse> for Event {
    fn from(response: InfrastructureResponse) -> Self {
        Self::new(Response::Infra(response))
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
