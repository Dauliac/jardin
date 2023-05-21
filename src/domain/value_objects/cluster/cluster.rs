use std::collections::HashMap;

use thiserror::Error;

use super::{node::Node, surname::ClusterSurname, surname::NodeSurname};

#[derive(Error, Debug, Clone, PartialEq, Hash, Eq)]
pub enum ClusterError {
    #[error("Duplicated node surname {0}")]
    NodeSurnameAlreadyExists(String),
    #[error("No leader declared")]
    NoLeaderDeclared,
    #[error("No node in cluster")]
    NoNodeInCluster,
}

pub type Nodes = HashMap<NodeSurname, Node>;

pub fn check_node_surname_uniqueness(nodes: &Nodes) -> Result<(), ClusterError> {
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

pub fn check_leader_declaration(nodes: &HashMap<NodeSurname, Node>) -> Result<(), ClusterError> {
    let leader = nodes.iter().find(|(_, node)| node.is_leader());
    match leader {
        Some(_) => Ok(()),
        None => Err(ClusterError::NoLeaderDeclared),
    }
}

pub struct Cluster {
    surname: ClusterSurname,
    targets: HashMap<NodeSurname, Node>,
}

impl Cluster {
    pub fn new(
        surname: ClusterSurname,
        targets: HashMap<NodeSurname, Node>,
    ) -> Result<Self, ClusterError> {
        // TODO: rewrite check chain as functional pipeline
        check_the_presence_of_at_least_one_node(&targets)?;
        check_node_surname_uniqueness(&targets)?;
        check_leader_declaration(&targets)?;
        Ok(Self { surname, targets })
    }

    pub fn get_surname(&self) -> &ClusterSurname {
        &self.surname
    }
}
