// SPDX-License-Identifier: AGPL-3.0-or-later

use std::{net::IpAddr, path::PathBuf};

use super::surname::NodeSurname;

pub type NameServer = String;

#[derive(Clone, PartialEq, Hash, Eq)]
pub enum Role {
    Leader,
    Follower,
}

#[derive(Clone, PartialEq, Hash, Eq)]
pub struct Private {}

#[derive(Clone, PartialEq, Hash, Eq)]
pub struct Sensitive {
    name_server: NameServer,
    ip_address: IpAddr,
    ssh_key_path: PathBuf,
}

#[derive(Clone, PartialEq, Hash, Eq)]
pub struct Public {
    surname: NodeSurname,
}

#[derive(Clone, PartialEq, Hash, Eq)]
pub struct Node {
    pub sensitive: Sensitive,
    pub private: Private,
    pub public: Public,
    pub role: Role,
}

impl Node {
    pub fn is_leader(&self) -> bool {
        self.role == Role::Leader
    }
}
