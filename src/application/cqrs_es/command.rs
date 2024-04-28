use async_trait::async_trait;

use std::time::SystemTime;

use crate::domain::models::aggregates::cluster::ClusterCommand;

#[derive(Clone, PartialEq)]
pub struct Command {
    command: ClusterCommand,
    timestamp: Option<SystemTime>,
}

impl Command {
    pub fn new(command: ClusterCommand) -> Self {
        Self {
            command,
            timestamp: None,
        }
    }

    pub fn run(&mut self) {
        self.timestamp = Some(SystemTime::now());
    }

    pub fn get_timestamp(&self) -> Option<SystemTime> {
        self.timestamp
    }
    pub fn get_command(&self) -> &ClusterCommand {
        &self.command
    }
}

#[async_trait]
pub trait CommandBus: Sync + Send {
    fn publish(&mut self, command: Command);
    async fn run(&mut self);
}
