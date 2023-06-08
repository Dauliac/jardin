use async_trait::async_trait;
use serde::{Deserialize, Serialize};
use std::{fmt::Debug, hash::Hash, time::SystemTime};

use crate::{
    domain::models::{DomainResponse, DomainResponseKinds},
    user_interface::Logger,
};

#[derive(Serialize, Deserialize, Debug, PartialEq, Eq, Hash, Clone)]
pub enum EventPriority {
    Low = 30,
    Normal = 60,
    High = 90,
}

#[derive(Serialize, Deserialize, Debug, PartialEq, Clone)]
pub struct Event {
    pub response: DomainResponse,
    pub timestamp: SystemTime,
    pub priority: EventPriority,
}

impl Event {
    pub fn new(response: DomainResponse, priority: Option<EventPriority>) -> Self {
        let priority = match priority {
            Some(priority) => priority,
            None => EventPriority::Normal,
        };
        Self {
            response,
            timestamp: SystemTime::now(),
            priority,
        }
    }
}

pub trait EventHandler {
    fn notify(&mut self, response: DomainResponse);
}

pub enum EventHandlers {
    Logger(Box<Logger>),
}

#[async_trait]
pub trait EventBus: Send + Sync {
    fn subscribe(&mut self, response: DomainResponseKinds, handler: EventHandlers);
    fn publish(&mut self, response: Event);
    fn run(&mut self);
}
