use async_trait::async_trait;
use serde::{Deserialize, Serialize};
use std::{
    fmt::Debug,
    sync::{Arc, RwLock},
    time::SystemTime,
};

use crate::{
    domain::models::{DomainResponse, DomainResponseKinds},
    user_interface::Logger,
};

#[derive(Serialize, Deserialize, Debug, PartialEq, Clone)]
pub struct Event {
    pub response: DomainResponse,
    pub timestamp: SystemTime,
}

impl Event {
    pub fn new(response: DomainResponse) -> Self {
        Self {
            response,
            timestamp: SystemTime::now(),
        }
    }
}

pub trait EventHandler {
    fn notify(&mut self, response: DomainResponse);
}

#[derive(Clone)]
pub enum EventHandlers {
    Logger(Arc<RwLock<Logger>>),
}

#[async_trait]
pub trait EventBus: Send + Sync {
    fn subscribe(&mut self, response: DomainResponseKinds, handler: EventHandlers);
    fn publish(&mut self, event: Event);
    async fn run(&mut self);
}
