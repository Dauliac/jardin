// SPDX-FileCopyrightText: 2023 AGPL-3.0-or-later

use serde::{Deserialize, Serialize};
use std::{net::IpAddr, path::PathBuf};

use super::surname::NodeSurname;

pub type NameServer = String;

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
pub enum Role {
    Leader,
    Follower,
}

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
pub struct Private {}

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
pub struct Sensitive {
    name_server: NameServer,
    ip_address: IpAddr,
    ssh_key_path: PathBuf,
}

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
pub struct Public {
    surname: NodeSurname,
}

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
pub struct Node {
    sensitive: Sensitive,
    private: Private,
    public: Public,
    role: Role,
}

impl Node {
    pub fn is_leader(&self) -> bool {
        self.role.eq(&Role::Leader)
    }
}
