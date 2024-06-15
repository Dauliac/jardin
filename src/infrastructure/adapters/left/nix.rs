use super::{super::super::Response as InfraResponse, Response as LeftResponse};
use crate::{
    application::cqrs_es::{
        command::CommandBus,
        event::{Event, EventBus},
    },
    domain::repositories::ClusterRepository,
};
use serde::{Deserialize, Serialize};
use std::{
    process::Stdio,
    sync::{Arc, RwLock},
};
use tokio::{
    io::{AsyncBufReadExt, BufReader},
    process::Command,
};

#[derive(Serialize, Deserialize, Debug, PartialEq, Clone)]
pub enum Response {
    Log(String),
}

impl From<Response> for LeftResponse {
    fn from(response: Response) -> Self {
        LeftResponse::Nix(response)
    }
}

impl From<Response> for InfraResponse {
    fn from(response: Response) -> Self {
        let response: LeftResponse = From::from(response);
        InfraResponse::Left(response)
    }
}

pub async fn run(
    _repository: Arc<RwLock<dyn ClusterRepository>>,
    event_bus: Arc<RwLock<dyn EventBus>>,
    _command_bus: Arc<RwLock<dyn CommandBus>>,
    _application: &str,
) {
    let command = "nix";
    let argument = "run";
    let address = ".#application";

    let mut child_process = Command::new(command)
        .arg(argument)
        .arg(address)
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .expect("Failed to start command");
    let stdout = child_process
        .stdout
        .take()
        .expect("Failed to capture stdout");
    let stderr = child_process
        .stderr
        .take()
        .expect("Failed to capture stderr");
    let stdout_reader = BufReader::new(stdout);
    let stderr_reader = BufReader::new(stderr);
    let event_bus_clone = event_bus.clone();
    let stdout_task = tokio::spawn(process_output_and_send_events(
        stdout_reader,
        event_bus_clone,
    ));
    let stderr_task = tokio::spawn(process_output_and_send_events(stderr_reader, event_bus));
    tokio::try_join!(stdout_task, stderr_task).expect("Failed to join tasks");
}

pub async fn process_output_and_send_events(
    mut reader: impl tokio::io::AsyncBufRead + Unpin,
    event_bus: Arc<RwLock<dyn EventBus>>,
) {
    let mut line = String::new();
    loop {
        match reader.read_line(&mut line).await {
            Ok(bytes_read) => {
                if bytes_read == 0 {
                    break;
                }
                let response: InfraResponse = From::from(Response::Log(line.clone()));
                let event: Event = From::from(response);
                event_bus.write().unwrap().publish(event);
                line.clear();
            }
            Err(e) => {
                eprintln!("Error reading line: {}", e);
                break;
            }
        }
    }
}
