// SPDX-FileCopyrightText: 2023 AGPL-3.0-or-later

use async_trait::async_trait;
use serde::{de::DeserializeOwned, Serialize};
use std::hash::Hash;

pub trait Entity<T> {
    type Identifier;

    fn get_identifier(&self) -> Self::Identifier;
    fn equals(&self, entity: Box<T>) -> bool;
}

pub trait ValueObject<T>: Clone + PartialEq {
    fn equals(&self, value: &T) -> bool;
}

pub trait Event: Hash + Eq {}

#[async_trait]
pub trait Aggregate<T>: Entity<T> + Serialize + DeserializeOwned + Sync + Send {
    type Error;
    type Event;
    type Command;
    // type Result = Result<Vec<Self::Event>, Self::Error>;
    type Result;
    fn handle(&self, command: Self::Command) -> Self::Result;
    fn apply(&mut self, event: Self::Event);
}
