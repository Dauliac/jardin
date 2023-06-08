use log::{error, info};

use crate::{
    application::services::{
        cqrs_es::event::EventHandler,
        logger::{
            init_logger,
            types::{DomainLoggerType, LoggerType},
        },
    },
    domain::models::{DomainError, DomainEvent, DomainResponse},
};

pub struct Logger {
    debug: bool,
}

impl Logger {
    pub fn new(debug: bool) -> Self {
        Self { debug }
    }

    fn info(&self, event: &DomainEvent) {
        init_logger(
            self.debug,
            match event.to_owned() {
                DomainEvent::Cluster(_) => &LoggerType::Domain(DomainLoggerType::Cluster),
            },
        )
        .unwrap();
        info!("{:?}", event);
    }

    fn error(&self, error: &DomainError) {
        init_logger(
            self.debug,
            match error {
                DomainError::Surname(_) => &LoggerType::Domain(DomainLoggerType::Cluster),
                DomainError::Cluster(_) => &LoggerType::Domain(DomainLoggerType::Cluster),
            },
        )
        .unwrap();
        error!("{}", error);
    }
}
impl EventHandler for Logger {
    fn notify(&mut self, response: DomainResponse) {
        match response {
            DomainResponse::Event(event) => {
                self.info(&event);
            }
            DomainResponse::Error(error) => {
                self.error(&error);
            }
        }
    }
}
