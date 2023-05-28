// SPDX-FileCopyrightText: 2023 AGPL-3.0-or-later

use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use thiserror::Error;

use crate::domain::{
    core::{Aggregate, Entity},
    models::{
        entities::pipeline::{Pipeline, PipelineError, PipelineEvent},
        value_objects::{
            cluster::{
                node::Node,
                surname::{ClusterSurname, NodeSurname},
            },
            pipeline::{steps::step::Step, PipelineIdentifier},
        },
    },
};

#[derive(Error, Debug, Clone, PartialEq)]
pub enum ClusterError {
    #[error("Duplicated node surname {0}")]
    NodeSurnameAlreadyExists(String),
    #[error("No leader declared")]
    NoLeaderDeclared,
    #[error("No node in cluster")]
    NoNodeInCluster,
    #[error("Pipeline error {0}")]
    Pipeline(PipelineError),
}

#[derive(Debug, Clone, PartialEq)]
pub enum ClusterCommand {
    CreatePipeline {
        identifier: PipelineIdentifier,
        steps: Vec<Step>,
    },
}

#[derive(Debug, Clone, PartialEq)]
pub enum ClusterEvent {
    ClusterDeclared(ClusterSurname),
    Pipeline(PipelineEvent),
}

pub type Nodes = HashMap<NodeSurname, Node>;

fn check_node_surname_uniqueness(nodes: &Nodes) -> Result<(), ClusterError> {
    let mut surnames: Vec<String> = nodes
        .iter()
        .map(|(surname, _)| surname.value.clone())
        .collect();
    surnames.sort();
    surnames.dedup();
    if surnames.len() == nodes.len() {
        Ok(())
    } else {
        Err(ClusterError::NodeSurnameAlreadyExists(surnames.join(", ")))
    }
}

fn check_the_presence_of_at_least_one_node(nodes: &Nodes) -> Result<(), ClusterError> {
    let no_node_in_cluster = nodes.is_empty();
    match no_node_in_cluster {
        true => Err(ClusterError::NoNodeInCluster),
        false => Ok(()),
    }
}

fn check_leader_declaration(nodes: &HashMap<NodeSurname, Node>) -> Result<(), ClusterError> {
    let leader = nodes.iter().find(|(_, node)| node.is_leader());
    match leader {
        Some(_) => Ok(()),
        None => Err(ClusterError::NoLeaderDeclared),
    }
}

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
pub struct Cluster {
    surname: ClusterSurname,
    targets: HashMap<NodeSurname, Node>,
    pipeline: Option<Pipeline>,
}

impl Entity<Cluster> for Cluster {
    type Identifier = ClusterSurname;

    fn get_identifier(&self) -> ClusterSurname {
        self.surname.clone()
    }

    fn equals(&self, entity: Box<Cluster>) -> bool {
        self.surname.eq(&entity.surname)
    }
}

impl Aggregate<Cluster> for Cluster {
    type Error = ClusterError;
    type Event = ClusterEvent;
    type Command = ClusterCommand;
    type Result = Result<Self::Event, Self::Error>;

    fn handle(&self, command: Self::Command) -> Self::Result {
        match command {
            ClusterCommand::CreatePipeline { identifier, steps } => {
                self.create_pipeline(identifier, steps)
            }
        }
    }

    fn apply(&mut self, event: Self::Event) {
        match event {
            ClusterEvent::ClusterDeclared(_) => (),
            ClusterEvent::Pipeline(pipeline_event) => match pipeline_event {
                PipelineEvent::PipelineCreated { identifier, steps } => {
                    self.pipeline_created(Pipeline::new(identifier, steps))
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
        check_the_presence_of_at_least_one_node(&targets)?;
        check_node_surname_uniqueness(&targets)?;
        check_leader_declaration(&targets)?;
        Ok(Self {
            surname,
            targets,
            pipeline: None,
        })
    }

    pub fn get_surname(&self) -> &ClusterSurname {
        &self.surname
    }

    pub fn create_pipeline(
        &self,
        identifier: PipelineIdentifier,
        steps: Vec<Step>,
    ) -> Result<ClusterEvent, ClusterError> {
        Pipeline::create(identifier, steps)
            .map_err(|error| ClusterError::Pipeline(error))
            .map(|event| ClusterEvent::Pipeline(event))
    }

    fn pipeline_created(&mut self, pipeline: Pipeline) {
        self.pipeline = Some(pipeline);
    }
}
