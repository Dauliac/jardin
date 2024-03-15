use std::sync::{Arc, RwLock};

use crate::{
    application::services::use_cases::start_domain_service,
    infrastructure::adapters::right::{
        cqrs::MemoryCommandBus, event_bus::MemoryEventBus,
        repository_in_memory::ClusterRepositoryInMemory,
    },
    user_interface::Logger,
};

use self::services::{
    command_line_interface::start_cli,
    config::parser::parse_config,
    cqrs_es::{command::CommandBus, event::EventBus},
};

pub mod services;

pub const VERSION: &str = env!("CARGO_PKG_VERSION");
pub const NAME: &str = env!("CARGO_PKG_NAME");
pub const AUTHOR: &str = env!("CARGO_PKG_AUTHORS");

pub async fn start() {
    let logger = Arc::new(RwLock::new(Logger::new(false)));

    let config = start_cli(parse_config);
    match config {
        Ok((config, use_case)) => {
            let repository = Arc::new(RwLock::new(ClusterRepositoryInMemory::new()));
            let event_bus = Arc::new(RwLock::new(MemoryEventBus::new(repository.to_owned())));
            let command_bus = Arc::new(RwLock::new(MemoryCommandBus::new(
                repository.to_owned(),
                event_bus.to_owned(),
            )));

            start_domain_service(
                use_case,
                &config,
                repository.to_owned(),
                event_bus.to_owned(),
                command_bus.to_owned(),
                logger,
            )
            .await;

            loop {
                event_bus.write().unwrap().run().await;
                command_bus.write().unwrap().run().await;
            }
        }
        Err(error) => {
            println!("Error: {:?}", error);
        }
    };
}
