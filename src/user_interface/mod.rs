use colored::*;
use log::{error, info};
use pretty_env_logger::formatted_builder;
extern crate pretty_env_logger;
use std::io::Write;

use crate::{
    application::services::cqrs_es::event::EventHandler,
    domain::models::{
        aggregates::cluster::ClusterEvent, entities::pipeline::PipelineEvent, DomainError,
        DomainEvent, DomainResponse,
    },
};

pub struct Logger {
    debug: bool,
}

impl Logger {
    pub fn new(debug: bool) -> Self {
        //pretty_env_logger::init();
        //TODO: set formatter
        formatted_builder()
            .format(|buf, record| writeln!(buf, "{}", record.args()))
            .init();
        Self { debug }
    }

    fn info(&self, event: &DomainEvent) {
        match event {
            DomainEvent::Cluster(event) => match event {
                ClusterEvent::ClusterDeclared(surname) => {
                    info!(
                        "Cluster `{}` is declared",
                        surname.get_value().bold().green()
                    );
                }
                ClusterEvent::Pipeline {
                    identifier: _,
                    event,
                } => match event {
                    PipelineEvent::PipelineCreated {
                        identifier,
                        steps,
                        jobs: _,
                    } => {
                        let names = steps.iter().fold(String::new(), |acc, step| {
                            format!("{}`{}`, ", acc, step.identifier.value().green())
                        });
                        info!(
                            "Pipeline `{}` is created with steps {}",
                            identifier.get_value().bold().green(),
                            names
                        );
                    }
                    PipelineEvent::PipelineStarted {
                        identifier: _,
                        dry_run: _,
                        step_started: _,
                        job_started: _,
                    } => todo!(),
                    PipelineEvent::JobUpdated {
                        identifier: _,
                        dry_run: _,
                        output: _,
                    } => todo!(),
                },
            },
        }
    }

    fn error(&self, error: &DomainError) {
        //println!("Error {:?}", error);
        let error_prefix = format!("{}{} ", "Error".bold().red(), ":".bold());
        let error = match error {
            DomainError::Surname(error) => error.to_string(),
            DomainError::Cluster(error) => error.to_string(),
        };
        let message = format!("{}{}", error_prefix, error);
        error!("{}", message.bold());
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
