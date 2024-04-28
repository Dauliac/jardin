use serde::{Deserialize, Serialize};
use thiserror::Error;

use self::{
    aggregates::cluster::{ClusterError, ClusterEvent},
    value_objects::cluster::name::nameError,
};

use super::core::{Event, ValueObject};

pub mod aggregates;
pub mod entities;
pub mod value_objects;

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub enum ResponseKind {
    Event,
    Error,
    ClusternameError,
    ClusternameInvalidnameFormatError,
    ClusterEvent,
    ClusterDeclaredEvent,
    ClusterPipelineEvent,
    ClusterPipelineCreatedEvent,
    ClusterPipelineStartedEvent,
    ClusterPipelineJobUpdatedEvent,
    ClusterError,
    ClusterNodenameAlreadyExistsError,
    ClusterNoLeaderDeclaredError,
    ClusterNoNodeInClusterError,
    ClusterPipelineAlreadyExistsError,
    ClusterPipelineError,
    ClusterPipelineNotFoundError,
    ClusterPipelineInvalidNextStepsError,
    ClusterPipelineCyclicStepFlowError,
}

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
pub enum DomainEvent {
    Cluster(ClusterEvent),
}
impl ValueObject<DomainEvent> for DomainEvent {}
impl Event<DomainEvent> for DomainEvent {}
impl From<DomainEvent> for Vec<ResponseKind> {
    fn from(value: DomainEvent) -> Self {
        let mut kind = vec![ResponseKind::Event];
        let mut specific_kind: Vec<ResponseKind> = match value {
            DomainEvent::Cluster(event) => From::from(event),
        };
        kind.append(&mut specific_kind);
        kind
    }
}

#[derive(Error, Serialize, Deserialize, Debug, Clone, PartialEq)]
pub enum DomainError {
    #[error("{0}")]
    name(nameError),
    #[error("{0}")]
    Cluster(ClusterError),
}
impl ValueObject<DomainError> for DomainError {}
impl Event<DomainError> for DomainError {}
impl From<DomainError> for Vec<ResponseKind> {
    fn from(value: DomainError) -> Self {
        let mut kind = vec![ResponseKind::Error];
        let mut specific_kind: Vec<ResponseKind> = match value {
            DomainError::name(error) => From::from(error),
            DomainError::Cluster(error) => From::from(error),
        };
        kind.append(&mut specific_kind);
        kind
    }
}

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
pub enum Response {
    Event(DomainEvent),
    Error(DomainError),
}
impl ValueObject<Response> for Response {}
impl Event<Response> for Response {}
impl From<Response> for Vec<ResponseKind> {
    fn from(value: Response) -> Self {
        match value {
            Response::Event(event) => From::from(event),
            Response::Error(error) => From::from(error),
        }
    }
}
