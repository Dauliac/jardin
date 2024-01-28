// SPDX-FileCopyrightText: 2023 AGPL-3.0-or-later

use serde::{Deserialize, Serialize};
use std::net::IpAddr;

use super::surname::NodeSurname;

pub type NameServer = String;

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
pub enum Role {
    Leader,
    Follower,
}
impl Role {}

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
pub struct Private {}

impl Private {
    pub fn new() -> Self {
        Self {}
    }
}

impl Default for Private {
    fn default() -> Self {
        Self::new()
    }
}

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
pub struct Sensitive {
    name_server: NameServer,
    ip_address: IpAddr,
}

impl Sensitive {
    pub fn new(name_server: NameServer, ip_address: IpAddr) -> Self {
        Self {
            name_server,
            ip_address,
        }
    }
}

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
pub struct Public {
    surname: NodeSurname,
}

impl Public {
    pub fn new(surname: NodeSurname) -> Self {
        Self { surname }
    }
}

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
pub struct Node {
    sensitive: Sensitive,
    private: Private,
    public: Public,
    role: Role,
}

impl Node {
    pub fn new(sensitive: Sensitive, private: Private, public: Public, role: Role) -> Self {
        Self {
            sensitive,
            private,
            public,
            role,
        }
    }

    pub fn is_leader(&self) -> bool {
        self.role.eq(&Role::Leader)
    }

    pub fn surname(&self) -> &NodeSurname {
        &self.public.surname
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    // use afl::fuzz;
    use crate::domain::models::value_objects::cluster::node;
    use fake::{
        faker::{internet::raw::IP, job::raw::Title, lorem::raw::Word},
        locales::EN,
        Fake,
    };
    use serde_json;

    #[test]
    fn test_role() {
        let role = Role::Leader;
        let role_follower = node::Role::Follower;
        let role_clone = role.clone();
        assert_eq!(role, role_clone);
        assert!(role == role_clone);
        assert!(role_clone == role);
        assert!(role == role_clone);
        assert!(role_clone == role);
        assert!(role != role_follower);
        assert!(role_follower != role);
        assert!(role != role_follower);
        assert!(role_follower != role);

        assert!(role == role_clone);
        assert!(role_clone == role);
        assert!(role == role_clone);
        assert!(role_clone == role);
        assert!(role != role_follower);
        assert!(role_follower != role);
        assert!(role != role_follower);
        assert!(role_follower != role);

        assert_ne!(role, role_follower);
        assert_ne!(role_follower, role);

        assert!(!format!("{:?}", role).is_empty());

        let json = serde_json::to_string(&role).unwrap();
        assert!(!json.is_empty());
        let role_serialized = serde_json::from_str::<node::Role>(&json).unwrap();
        assert_eq!(role_serialized, role);
    }

    #[test]
    fn test_private() {
        let private = Private::new();
        let private_clone = private.clone();
        assert_eq!(private, private_clone);
        assert!(private == private_clone);
        assert!(private_clone == private);
        assert!(private == private_clone);
        assert!(private_clone == private);

        assert!(private == private_clone);
        assert!(private_clone == private);
        assert!(private == private_clone);
        assert!(private_clone == private);

        assert!(!format!("{:?}", private).is_empty());

        let json = serde_json::to_string(&private).unwrap();
        assert!(!json.is_empty());
        let private_serialized = serde_json::from_str::<node::Private>(&json).unwrap();
        assert_eq!(private_serialized, private);
    }

    #[test]
    fn test_sensitive() {
        let name_server: String = Title(EN).fake();
        let ip_address: IpAddr = IP(EN).fake();

        let sensitive = Sensitive::new(name_server.clone(), ip_address);
        let sensitive_clone = sensitive.clone();
        assert_eq!(sensitive, sensitive_clone);

        assert!(sensitive == sensitive_clone);
        assert!(sensitive_clone == sensitive);
        assert!(sensitive == sensitive_clone);
        assert!(sensitive_clone == sensitive);

        assert!(sensitive == sensitive_clone);
        assert!(sensitive_clone == sensitive);
        assert!(sensitive == sensitive_clone);
        assert!(sensitive_clone == sensitive);

        assert!(!format!("{:?}", sensitive).is_empty());

        let name_server_2: String = Title(EN).fake();
        let ip_address_2 = IP(EN).fake();
        let sensitive_2 = Sensitive::new(name_server_2.clone(), ip_address_2);
        assert_ne!(sensitive, sensitive_2);

        let json = serde_json::to_string(&sensitive).unwrap();
        assert!(!json.is_empty());
        let sensitive_serialized = serde_json::from_str::<node::Sensitive>(&json).unwrap();
        assert_eq!(sensitive_serialized, sensitive);
    }

    #[test]
    fn test_public() {
        let valid_surname: String = Word(EN).fake();
        let surname = NodeSurname::new(valid_surname).unwrap();

        let public = Public::new(surname.clone());
        let public_clone = public.clone();
        assert_eq!(public, public_clone);

        assert!(public == public_clone);
        assert!(public_clone == public);
        assert!(public == public_clone);
        assert!(public_clone == public);

        assert!(public == public_clone);
        assert!(public_clone == public);
        assert!(public == public_clone);
        assert!(public_clone == public);

        assert!(!format!("{:?}", public).is_empty(),);

        let valid_surname: String = Word(EN).fake();
        let surname = NodeSurname::new(valid_surname).unwrap();
        let public_2 = Public::new(surname.clone());
        assert_ne!(public, public_2);

        assert!(public == public_clone);
        assert!(public_clone == public);
        assert!(public_clone == public);
        assert!(public != public_2);
        assert!(public_2 != public);
        assert!(public != public_2);
        assert!(public_2 != public);

        assert!(public == public_clone);
        assert!(public_clone == public);
        assert!(public == public_clone);
        assert!(public_clone == public);
        assert!(public != public_2);
        assert!(public_2 != public);
        assert!(public != public_2);
        assert!(public_2 != public);

        let json = serde_json::to_string(&public).unwrap();
        assert!(!json.is_empty());
        let public_serialized = serde_json::from_str::<node::Public>(&json).unwrap();
        assert_eq!(public_serialized, public);
    }

    #[test]
    fn test_node() {
        let name_server: String = Title(EN).fake();
        let ip_address: IpAddr = IP(EN).fake();
        let sensitive = Sensitive::new(name_server.clone(), ip_address);

        let private = Private::new();
        let valid_surname: String = Word(EN).fake();
        let surname = NodeSurname::new(valid_surname).unwrap();
        let public = Public::new(surname.clone());
        let role = Role::Leader;
        let node = Node::new(
            sensitive.clone(),
            private.clone(),
            public.clone(),
            role.clone(),
        );
        let node_clone = node.clone();
        assert_eq!(node, node_clone);
        assert!(node == node_clone);
        assert!(node_clone == node);
        assert!(node == node_clone);
        assert!(node_clone == node);
        assert!(node == node_clone);
        assert!(node_clone == node);
        assert!(node == node_clone);
        assert!(node_clone == node);
        assert!(node.is_leader());
        assert!(node.is_leader());
        assert!(!format!("{:?}", node).is_empty(),);
        let role_follower = Role::Follower;
        let node_follower = Node::new(
            sensitive.clone(),
            private.clone(),
            public.clone(),
            role_follower.clone(),
        );
        assert!(!node_follower.is_leader());
        assert_ne!(node, node_follower);
        let json = serde_json::to_string(&node).unwrap();
        assert!(!json.is_empty());
        let node_serialized = serde_json::from_str::<node::Node>(&json).unwrap();
        assert_eq!(node_serialized, node);
    }
}
