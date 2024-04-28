use crate::{
    application::cqrs_es::{command::CommandBus, event::EventBus},
    domain::repositories::ClusterRepository,
};
use std::{
    process::Stdio,
    sync::{Arc, RwLock},
};
use tokio::{
    io::{AsyncBufReadExt, BufReader},
    process::Command,
};

pub fn run(
    repository: Arc<RwLock<dyn ClusterRepository>>,
    event_bus: Arc<RwLock<dyn EventBus>>,
    command_bus: Arc<RwLock<dyn CommandBus>>,
    application: &str,
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
                let event = YourEventStruct::new(line.clone());
                event_bus.write().unwrap().send(event);
                line.clear();
            }
            Err(e) => {
                eprintln!("Error reading line: {}", e);
                break;
            }
        }
    }
}
