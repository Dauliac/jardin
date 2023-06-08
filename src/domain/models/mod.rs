// SPDX-FileCopyrightText: 2023 AGPL-3.0-or-later

use serde::{Deserialize, Serialize};
use thiserror::Error;

use self::{
    aggregates::cluster::{ClusterError, ClusterEvent},
    value_objects::cluster::surname::SurnameError,
};

use super::core::{Event, ValueObject};

pub mod aggregates;
pub mod entities;
pub mod value_objects;

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub enum DomainResponseKinds {
    Event,
    Error,
    ClusterSurnameError,
    ClusterSurnameInvalidSurnameFormatError,
    ClusterEvent,
    ClusterDeclaredEvent,
    ClusterPipelineEvent,
    ClusterPipelineCreatedEvent,
    ClusterError,
    ClusterNodeSurnameAlreadyExistsError,
    ClusterNoLeaderDeclaredError,
    ClusterNoNodeInClusterError,
    ClusterPipelineError,
    ClusterPipelineInvalidNextStepsError,
    ClusterPipelineCyclicStepFlowError,
}

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
pub enum DomainEvent {
    Cluster(ClusterEvent),
}
impl ValueObject<DomainEvent> for DomainEvent {}
impl Event<DomainEvent> for DomainEvent {}
impl From<DomainEvent> for Vec<DomainResponseKinds> {
    fn from(value: DomainEvent) -> Self {
        match value {
            DomainEvent::Cluster(event) => From::from(event),
        }
    }
}

#[derive(Error, Serialize, Deserialize, Debug, Clone, PartialEq)]
pub enum DomainError {
    #[error("{0}")]
    Surname(SurnameError),
    #[error("{0}")]
    Cluster(ClusterError),
}
impl ValueObject<DomainError> for DomainError {}
impl Event<DomainError> for DomainError {}
impl From<DomainError> for Vec<DomainResponseKinds> {
    fn from(value: DomainError) -> Self {
        match value {
            DomainError::Surname(error) => From::from(error),
            DomainError::Cluster(error) => From::from(error),
        }
    }
}

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
pub enum DomainResponse {
    Event(DomainEvent),
    Error(DomainError),
}
impl ValueObject<DomainResponse> for DomainResponse {}
impl Event<DomainResponse> for DomainResponse {}
impl From<DomainResponse> for Vec<DomainResponseKinds> {
    fn from(value: DomainResponse) -> Self {
        match value {
            DomainResponse::Event(event) => From::from(event),
            DomainResponse::Error(error) => From::from(error),
        }
    }
}
