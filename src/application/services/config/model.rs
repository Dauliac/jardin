// SPDX-FileCopyrightText: 2023 AGPL-3.0-or-later

use serde::{Deserialize, Serialize};

use std::{collections::HashMap, net::IpAddr, path::PathBuf};

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum Role {
    Leader,
    Follower,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Node {
    pub surname: String,
    pub name_server: String,
    pub role: Role,
    pub ip: IpAddr,
}

#[derive(Default, Debug, Serialize, Deserialize)]
pub struct NixBackend {
    path: PathBuf,
}

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum Backend {
    Nix(NixBackend),
}
impl Default for Backend {
    fn default() -> Self {
        Backend::Nix(NixBackend::default())
    }
}

#[derive(Default, Debug, Serialize, Deserialize)]
pub struct Job {
    pub backend: Backend,
}

#[derive(Default, Debug, Serialize, Deserialize)]
pub struct PreCheck {
    pub name: String,
    pub job: Job,
    pub retry: u8,
}

#[derive(Default, Debug, Serialize, Deserialize)]
pub struct PostCheck {
    pub name: String,
    pub job: Job,
    pub retry: u8,
}

#[derive(Default, Debug, Serialize, Deserialize)]
pub struct Step {
    pub name: String,
    pub pre_check: Option<Vec<PreCheck>>,
    pub job: Job,
    pub post_check: Option<Vec<PostCheck>>,
    pub next: Option<Vec<String>>,
    pub is_destructive: bool,
    pub revert: Option<Job>,
}

#[derive(Default, Debug, Serialize, Deserialize)]
pub struct Pipeline {
    pub identifier: Option<String>,
    pub backend: Option<Backend>,
    pub steps: Option<Vec<Step>>,
}

#[derive(Default, Debug, Serialize, Deserialize)]
pub struct Cluster {
    pub surname: String,
    pub targets: HashMap<String, Node>,
}

#[derive(Default, Debug, Serialize, Deserialize)]
pub struct Config {
    pub version: u8,
    pub pipeline: Pipeline,
    pub cluster: Cluster,
}
