use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use thiserror::Error;

use crate::domain::{
    core::{Aggregate, Command, Entity, Event, ValueObject},
    models::{
        entities::{
            pipeline::{Pipeline, PipelineError, PipelineEvent},
            step::Step,
        },
        value_objects::{
            cluster::{
                node::Node,
                surname::{ClusterSurname, NodeSurname},
            },
            pipeline::{steps::step::StepPreview, PipelineIdentifier},
        },
        DomainResponseKinds,
    },
};

#[derive(Error, Serialize, Deserialize, Debug, Clone, PartialEq)]
pub enum ClusterError {
    #[error("Duplicated node surname {} in the cluster {}", .1.join(", "), .0.get_value())]
    NodeSurnameAlreadyExists(ClusterSurname, Vec<String>),
    #[error("No leader declared in cluster {}", .0.get_value())]
    NoLeaderDeclared(ClusterSurname),
    #[error("No node in cluster {}", .0.get_value())]
    NoNodeInCluster(ClusterSurname),
    #[error("Pipeline {} already exists in cluster {}", .pipeline_identifier.get_value(), .identifier.get_value())]
    PipelineAlreadyExists {
        identifier: ClusterSurname,
        pipeline_identifier: PipelineIdentifier,
    },
    #[error("Pipeline error {} in cluster {}", .error, .identifier.get_value())]
    Pipeline {
        identifier: ClusterSurname,
        error: PipelineError,
    },
    #[error("Pipeline not found in cluster {}", .identifier.get_value())]
    PipelineNotFound { identifier: ClusterSurname },
}
impl ValueObject<ClusterError> for ClusterError {}
impl Event<ClusterError> for ClusterError {}
impl From<ClusterError> for Vec<DomainResponseKinds> {
    fn from(value: ClusterError) -> Self {
        let mut kind = vec![DomainResponseKinds::ClusterError];
        let mut specific_kind: Vec<DomainResponseKinds> = match value {
            ClusterError::NodeSurnameAlreadyExists(..) => {
                vec![DomainResponseKinds::ClusterNodeSurnameAlreadyExistsError]
            }
            ClusterError::NoLeaderDeclared(..) => {
                vec![DomainResponseKinds::ClusterNoLeaderDeclaredError]
            }
            ClusterError::NoNodeInCluster(..) => {
                vec![DomainResponseKinds::ClusterNoNodeInClusterError]
            }
            ClusterError::PipelineAlreadyExists {
                identifier: _,
                pipeline_identifier: _,
            } => {
                vec![DomainResponseKinds::ClusterPipelineAlreadyExistsError]
            }
            ClusterError::Pipeline {
                identifier: _,
                error,
            } => From::from(error),
            ClusterError::PipelineNotFound { identifier: _ } => {
                vec![DomainResponseKinds::ClusterPipelineNotFoundError]
            }
        };
        kind.append(&mut specific_kind);
        kind
    }
}

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
pub enum ClusterCommand {
    CreatePipeline {
        identifier: ClusterSurname,
        pipeline_identifier: PipelineIdentifier,
        steps: Vec<StepPreview>,
    },
    RunPipeline {
        identifier: ClusterSurname,
        dry_run: bool,
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
        let mut kind = vec![DomainResponseKinds::ClusterEvent];
        let mut specific_kind: Vec<DomainResponseKinds> = match value {
            ClusterEvent::ClusterDeclared(_) => vec![DomainResponseKinds::ClusterDeclaredEvent],
            ClusterEvent::Pipeline {
                identifier: _,
                event,
            } => From::from(event),
        };
        kind.append(&mut specific_kind);
        kind
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

    fn identifier(&self) -> ClusterSurname {
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
            } => self.create_pipeline(
                pipeline_identifier,
                steps.iter().map(|step| step.clone().into()).collect(),
            ),
            ClusterCommand::RunPipeline {
                identifier: _,
                dry_run,
            } => self.run_pipeline(dry_run),
        }
    }

    fn apply(&mut self, event: Self::Event) {
        match event {
            ClusterEvent::ClusterDeclared(_) => (),
            ClusterEvent::Pipeline {
                identifier: _,
                event,
            } => match event {
                PipelineEvent::PipelineCreated {
                    identifier,
                    steps,
                    jobs: _,
                } => {
                    self.signal_pipeline_created(Pipeline::new(
                        identifier,
                        steps.iter().map(|step| step.clone().into()).collect(),
                    ));
                }
                PipelineEvent::PipelineStarted {
                    identifier: _,
                    dry_run,
                    step_started: _,
                    job_started: _,
                } => {
                    self.signal_run_pipeline(dry_run);
                }
                PipelineEvent::JobUpdated {
                    identifier: _,
                    dry_run: _,
                    output: _,
                } => todo!(),
            },
        }
    }
}

impl Cluster {
    pub fn declare(
        surname: ClusterSurname,
        targets: HashMap<NodeSurname, Node>,
    ) -> Result<(ClusterEvent, Self), ClusterError> {
        Self::new(surname, targets)
            .map(|cluster| (ClusterEvent::ClusterDeclared(cluster.identifier()), cluster))
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

    pub fn order_pipeline_creation(
        &self,
        pipeline_identifier: PipelineIdentifier,
        steps: Vec<StepPreview>,
    ) -> Result<ClusterCommand, ClusterError> {
        match &self.pipeline {
            Some(pipeline) => Err(ClusterError::PipelineAlreadyExists {
                identifier: self.identifier(),
                pipeline_identifier: pipeline.identifier(),
            }),
            None => Ok(ClusterCommand::CreatePipeline {
                identifier: self.identifier(),
                pipeline_identifier,
                steps,
            }),
        }
    }

    pub fn order_to_run_pipeline(&self, dry_run: bool) -> ClusterCommand {
        ClusterCommand::RunPipeline {
            identifier: self.identifier(),
            dry_run,
        }
    }

    pub fn pipeline_identifier(&self) -> Option<PipelineIdentifier> {
        self.pipeline.as_ref().map(|pipeline| pipeline.identifier())
    }

    fn create_pipeline(
        &self,
        identifier: PipelineIdentifier,
        steps: Vec<Step>,
    ) -> Result<ClusterEvent, ClusterError> {
        Pipeline::create(identifier, steps)
            .map_err(|error| ClusterError::Pipeline {
                identifier: self.identifier(),
                error,
            })
            .map(|event| ClusterEvent::Pipeline {
                identifier: self.identifier(),
                event,
            })
    }

    fn signal_pipeline_created(&mut self, pipeline: Pipeline) {
        self.pipeline = Some(pipeline);
    }

    fn run_pipeline(&self, dry_run: bool) -> <Cluster as Aggregate<Cluster>>::Result {
        let identifier = self.identifier();
        match &self.pipeline {
            Some(pipeline) => Ok(ClusterEvent::Pipeline {
                identifier: self.surname.clone(),
                event: PipelineEvent::PipelineStarted {
                    identifier: pipeline.identifier(),
                    dry_run,
                    step_started: pipeline.get_steps_to_run(),
                    job_started: pipeline.get_job_to_run(),
                },
            }),
            None => Err(ClusterError::PipelineNotFound { identifier }),
        }
    }

    fn signal_run_pipeline(&mut self, dry_run: bool) {
        match &mut self.pipeline {
            Some(pipeline) => pipeline.run(dry_run),
            None => (),
        }
    }
}
