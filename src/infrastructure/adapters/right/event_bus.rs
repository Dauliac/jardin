use crate::{
    application::cqrs_es::event::{
        Event, EventBus, EventHandler, EventHandlers, Response, ResponseKind,
    },
    domain::{
        core::Aggregate,
        models::{
            aggregates::cluster::ClusterEvent, value_objects::cluster::name::Clustername,
            DomainEvent, Response as DomainResponse,
        },
        repositories::ClusterRepository,
    },
};
use async_trait::async_trait;
use multimap::MultiMap;
use std::{
    collections::VecDeque,
    sync::{Arc, RwLock},
};

pub struct MemoryEventBus<R: ClusterRepository> {
    listeners: MultiMap<ResponseKind, Box<EventHandlers>>,
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

    fn get_kind(response: &Response) -> Vec<ResponseKind> {
        From::from(response.to_owned())
    }

    fn notify(handlers: &mut [Box<EventHandlers>], response: Response) {
        handlers
            .iter_mut()
            .for_each(|handler| match handler.as_mut() {
                EventHandlers::Logger(logger) => {
                    logger.write().unwrap().notify(response.to_owned());
                }
                EventHandlers::Deploy(handler) => {
                    handler.write().unwrap().notify(response.to_owned());
                }
            });
    }

    fn find_and_notify(&mut self, response: Response) {
        Self::get_kind(&response).iter().for_each(|event_kind| {
            self.listeners.get_vec_mut(event_kind).map(|handlers| {
                Self::notify(handlers, response.clone());
            });
        });
    }

    fn write(&self, event: &DomainEvent, identifier: Clustername) {
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
    fn subscribe(&mut self, event: ResponseKind, handler: EventHandlers) {
        self.listeners.insert(event, Box::new(handler));
    }

    fn unsubscribe(&mut self, event: ResponseKind, handler: &EventHandlers) {
        let handlers = self.listeners.remove(&event);
        match handlers {
            Some(handlers) => {
                let iter = handlers.iter().filter(|subscribed_handler| {
                    let subscribed_handler = subscribed_handler.as_ref();
                    match (subscribed_handler, handler.to_owned()) {
                        (EventHandlers::Logger(_), EventHandlers::Logger(_)) => true,
                        (EventHandlers::Deploy(_), EventHandlers::Deploy(_)) => true,
                        _ => false,
                    }
                });
                assert_eq!(iter.clone().count(), 0, "No handlers found");
                iter.for_each(|handler| {
                    self.listeners.insert(event.to_owned(), handler.to_owned());
                });
            }
            None => {
                panic!("No handlers found");
            }
        };
    }

    fn publish(&mut self, event: Event) {
        self.queue.push_back(event);
    }

    async fn run(&mut self) {
        self.queue.pop_front().map(|event| {
            match &event.response {
                Response::Domain(domain_response) => {
                    match domain_response {
                        DomainResponse::Event(event) => {
                            self.write(
                                event,
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
                }
                Response::Infra(..) => {
                    panic!("Impossible to have an infrastructure");
                }
            }
            self.find_and_notify(event.response);
        });
    }
}
