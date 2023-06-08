// SPDX-FileCopyrightText: 2023 AGPL-3.0-or-later

use std::sync::{Arc, RwLock};

use crate::infrastructure::adapters::right::{
    cqrs::MemoryCommandBus, event_bus::MemoryEventBus,
    repository_in_memory::ClusterRepositoryInMemory,
};

use self::services::{
    command_line_interface::start_cli, config::parser::parse_config, cqrs_es::command::CommandBus,
};

pub mod services;

pub const VERSION: &str = env!("CARGO_PKG_VERSION");
pub const NAME: &str = env!("CARGO_PKG_NAME");
pub const AUTHOR: &str = env!("CARGO_PKG_AUTHORS");

pub async fn start() {
    start_cli(parse_config, |_config| {
        let repository = Arc::new(RwLock::new(ClusterRepositoryInMemory::new()));
        let event_bus = Arc::new(RwLock::new(MemoryEventBus::new(repository.clone())));
        let mut command_bus = MemoryCommandBus::new(repository, event_bus);

        #[allow(unused_must_use)]
        {
            command_bus.run();
        }
    });
}
