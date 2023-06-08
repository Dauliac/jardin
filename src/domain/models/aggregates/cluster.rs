// SPDX-FileCopyrightText: 2023 AGPL-3.0-or-later

use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use thiserror::Error;

use crate::domain::{
    core::{Aggregate, Command, Entity, Event, ValueObject},
    models::{
        entities::pipeline::{Pipeline, PipelineError, PipelineEvent},
        value_objects::{
            cluster::{
                node::Node,
                surname::{ClusterSurname, NodeSurname},
            },
            pipeline::{steps::step::Step, PipelineIdentifier},
        },
        DomainResponseKinds,
    },
};

#[derive(Error, Serialize, Deserialize, Debug, Clone, PartialEq)]
pub enum ClusterError {
    #[error("Duplicated node surname {} in cluster {}", .1.join(", "), .0.get_value())]
    NodeSurnameAlreadyExists(ClusterSurname, Vec<String>),
    #[error("No leader declared in cluster {}", .0.get_value())]
    NoLeaderDeclared(ClusterSurname),
    #[error("No node in cluster {}", .0.get_value())]
    NoNodeInCluster(ClusterSurname),
    #[error("Pipeline error {} in cluster {}", .error, .identifier.get_value())]
    Pipeline {
        identifier: ClusterSurname,
        error: PipelineError,
    },
}
impl ValueObject<ClusterError> for ClusterError {}
impl Event<ClusterError> for ClusterError {}
impl From<ClusterError> for Vec<DomainResponseKinds> {
    fn from(value: ClusterError) -> Self {
        match value {
            ClusterError::NodeSurnameAlreadyExists(..) => From::from(value),
            ClusterError::NoLeaderDeclared(_) => From::from(value),
            ClusterError::NoNodeInCluster(_) => From::from(value),
            ClusterError::Pipeline {
                identifier: _,
                error,
            } => {
                let mut kind = vec![DomainResponseKinds::ClusterError];
                let mut kind_pipeline: Vec<DomainResponseKinds> = From::from(error);
                kind.append(kind_pipeline.as_mut());
                kind
            }
        }
    }
}

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
pub enum ClusterCommand {
    CreatePipeline {
        identifier: ClusterSurname,
        pipeline_identifier: PipelineIdentifier,
        steps: Vec<Step>,
    },
}
impl ValueObject<ClusterCommand> for ClusterCommand {}
impl Command<ClusterCommand> for ClusterCommand {}

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
pub enum ClusterEvent {
    ClusterDeclared(ClusterSurname),
    Pipeline {
        identifier: ClusterSurname,
        event: PipelineEvent,
    },
}
impl ValueObject<ClusterEvent> for ClusterEvent {}
impl Event<ClusterEvent> for ClusterEvent {}
impl From<ClusterEvent> for Vec<DomainResponseKinds> {
    fn from(value: ClusterEvent) -> Self {
        match value {
            ClusterEvent::ClusterDeclared(_) => From::from(value),
            ClusterEvent::Pipeline {
                identifier: _,
                event,
            } => {
                let mut kind = vec![DomainResponseKinds::ClusterEvent];
                let mut kind_pipeline: Vec<DomainResponseKinds> = From::from(event);
                kind.append(kind_pipeline.as_mut());
                kind
            }
        }
    }
}

pub type ClusterResult = Result<ClusterEvent, ClusterError>;

pub type Nodes = HashMap<NodeSurname, Node>;

fn check_node_surname_uniqueness(
    nodes: &Nodes,
    cluster_surname: ClusterSurname,
) -> Result<(), ClusterError> {
    let mut surnames: Vec<String> = nodes
        .iter()
        .map(|(surname, _)| surname.value.clone())
        .collect();
    surnames.sort();
    surnames.dedup();
    if surnames.len() == nodes.len() {
        Ok(())
    } else {
        Err(ClusterError::NodeSurnameAlreadyExists(
            cluster_surname,
            surnames,
        ))
    }
}

fn check_the_presence_of_at_least_one_node(
    nodes: &Nodes,
    cluster_surname: ClusterSurname,
) -> Result<(), ClusterError> {
    let no_node_in_cluster = nodes.is_empty();
    match no_node_in_cluster {
        true => Err(ClusterError::NoNodeInCluster(cluster_surname)),
        false => Ok(()),
    }
}

fn check_leader_declaration(
    nodes: &HashMap<NodeSurname, Node>,
    cluster_surname: ClusterSurname,
) -> Result<(), ClusterError> {
    let leader = nodes.iter().find(|(_, node)| node.is_leader());
    match leader {
        Some(_) => Ok(()),
        None => Err(ClusterError::NoLeaderDeclared(cluster_surname)),
    }
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct Cluster {
    surname: ClusterSurname,
    targets: HashMap<NodeSurname, Node>,
    pipeline: Option<Pipeline>,
}

impl PartialEq for Cluster {
    fn eq(&self, other: &Self) -> bool {
        self.surname.eq(&other.surname)
    }
}

impl Entity<Cluster> for Cluster {
    type Identifier = ClusterSurname;

    fn get_identifier(&self) -> ClusterSurname {
        self.surname.clone()
    }
}

impl Aggregate<Cluster> for Cluster {
    type Error = ClusterError;
    type Event = ClusterEvent;
    type Command = ClusterCommand;
    type Result = ClusterResult;

    fn handle(&self, command: Self::Command) -> Self::Result {
        match command {
            ClusterCommand::CreatePipeline {
                identifier: _,
                pipeline_identifier,
                steps,
            } => self.create_pipeline(pipeline_identifier, steps),
        }
    }

    fn apply(&mut self, event: Self::Event) {
        match event {
            ClusterEvent::ClusterDeclared(_) => (),
            ClusterEvent::Pipeline {
                identifier: _,
                event,
            } => match event {
                PipelineEvent::PipelineCreated { identifier, steps } => {
                    self.signal_pipeline_created(Pipeline::new(identifier, steps))
                }
            },
        }
    }
}

impl Cluster {
    pub fn declare(
        surname: ClusterSurname,
        targets: HashMap<NodeSurname, Node>,
    ) -> Result<(ClusterEvent, Self), ClusterError> {
        Self::new(surname, targets).map(|cluster| {
            (
                ClusterEvent::ClusterDeclared(cluster.get_identifier()),
                cluster,
            )
        })
    }

    pub fn new(
        surname: ClusterSurname,
        targets: HashMap<NodeSurname, Node>,
    ) -> Result<Self, ClusterError> {
        check_the_presence_of_at_least_one_node(&targets, surname.to_owned())?;
        check_node_surname_uniqueness(&targets, surname.to_owned())?;
        check_leader_declaration(&targets, surname.to_owned())?;
        Ok(Self {
            surname,
            targets,
            pipeline: None,
        })
    }

    pub fn get_surname(&self) -> &ClusterSurname {
        &self.surname
    }

    pub fn formulate_pipeline_creation(
        &self,
        identifier: PipelineIdentifier,
        steps: Vec<Step>,
    ) -> ClusterCommand {
        ClusterCommand::CreatePipeline {
            identifier: self.get_identifier(),
            pipeline_identifier: identifier,
            steps,
        }
    }

    fn create_pipeline(
        &self,
        identifier: PipelineIdentifier,
        steps: Vec<Step>,
    ) -> Result<ClusterEvent, ClusterError> {
        Pipeline::create(identifier, steps)
            .map_err(|error| ClusterError::Pipeline {
                identifier: self.get_identifier(),
                error,
            })
            .map(|event| ClusterEvent::Pipeline {
                identifier: self.get_identifier(),
                event,
            })
    }

    fn signal_pipeline_created(&mut self, pipeline: Pipeline) {
        self.pipeline = Some(pipeline);
    }
}
