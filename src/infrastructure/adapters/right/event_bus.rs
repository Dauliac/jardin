use async_trait::async_trait;
use multimap::MultiMap;
use std::{
    collections::VecDeque,
    sync::{Arc, RwLock},
};

use crate::{
    application::services::cqrs_es::event::{Event, EventBus, EventHandler, EventHandlers},
    domain::{
        core::Aggregate,
        models::{
            aggregates::cluster::ClusterEvent, value_objects::cluster::surname::ClusterSurname,
            DomainEvent, DomainResponse, DomainResponseKinds,
        },
        repositories::ClusterRepository,
    },
};

pub struct MemoryEventBus<R: ClusterRepository> {
    listeners: MultiMap<DomainResponseKinds, Box<EventHandlers>>,
    queue: VecDeque<Event>,
    repository: Arc<RwLock<R>>,
}

impl<R: ClusterRepository> MemoryEventBus<R> {
    pub fn new(repository: Arc<RwLock<R>>) -> Self {
        Self {
            listeners: MultiMap::new(),
            queue: VecDeque::new(),
            repository,
        }
    }

    fn get_kind(event: &DomainResponse) -> Vec<DomainResponseKinds> {
        From::from(event.to_owned())
    }

    fn notify(handlers: &mut [Box<EventHandlers>], response: DomainResponse) {
        handlers
            .iter_mut()
            .for_each(|handler| match handler.as_mut() {
                EventHandlers::Logger(logger) => {
                    logger.write().unwrap().notify(response.to_owned());
                }
            });
    }

    fn find_and_notify(&mut self, response: DomainResponse) {
        Self::get_kind(&response).iter().for_each(|event_kind| {
            self.listeners.get_vec_mut(event_kind).map(|handlers| {
                Self::notify(handlers, response.clone());
            });
        });
    }

    fn write(&self, event: &DomainEvent, identifier: ClusterSurname) {
        let cluster = self.repository.read().unwrap().read(identifier).unwrap();
        match event {
            DomainEvent::Cluster(event) => {
                cluster.write().unwrap().apply(event.to_owned());
                self.repository.write().unwrap().write(cluster);
            }
        }
    }
}

#[async_trait]
impl<R: ClusterRepository + Send + Sync> EventBus for MemoryEventBus<R> {
    fn subscribe(&mut self, event: DomainResponseKinds, handler: EventHandlers) {
        self.listeners.insert(event, Box::new(handler));
    }

    fn publish(&mut self, event: Event) {
        self.queue.push_back(event);
    }

    async fn run(&mut self) {
        self.queue.pop_front().map(|event| {
            // println!("Event {:?}", event);
            match event.response.to_owned() {
                DomainResponse::Event(event) => {
                    self.write(
                        &event,
                        match event.to_owned() {
                            DomainEvent::Cluster(event) => match event {
                                ClusterEvent::ClusterDeclared(identifier) => identifier,
                                ClusterEvent::Pipeline {
                                    identifier,
                                    event: _,
                                } => identifier,
                            },
                        },
                    );
                }
                DomainResponse::Error(_error) => {}
            };
            self.find_and_notify(event.response);
        });
    }
}
