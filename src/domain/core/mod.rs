// SPDX-FileCopyrightText: 2023 AGPL-3.0-or-later

use async_trait::async_trait;
use serde::{de::DeserializeOwned, Serialize};
use std::{fmt::Debug, hash::Hash};

pub trait Entity<T>: Serialize + DeserializeOwned + Debug + Clone + PartialEq {
    type Identifier;

    fn get_identifier(&self) -> Self::Identifier;
}

pub trait ValueObject<T>: Serialize + DeserializeOwned + Debug + Clone + PartialEq {}

pub trait Identifier<T>: ValueObject<T> + Eq + Hash {}

pub trait Event: Hash + Eq {}

#[async_trait]
pub trait Aggregate<T>:
    Entity<T> + Serialize + DeserializeOwned + Sync + Send + PartialEq + Debug
{
    type Error;
    type Event;
    type Command;
    // type Result = Result<Vec<Self::Event>, Self::Error>;
    type Result;
    fn handle(&self, command: Self::Command) -> Self::Result;
    fn apply(&mut self, event: Self::Event);
}

#[cfg(test)]
pub mod tests {

    use super::*;
    use serde::Deserialize;

    #[test]
    fn test_entity() {
        #[derive(Clone, PartialEq, Debug, Serialize, Deserialize)]
        struct User {
            id: u32,
        }

        impl Entity<User> for User {
            type Identifier = u32;

            fn get_identifier(&self) -> Self::Identifier {
                self.id
            }
        }

        let id = 1;
        let user1 = User { id: 1 };
        let user2 = User { id: 2 };
        let user1_bis = User { id: 1 };

        assert!(!user1.eq(&user2));
        assert!(user1.eq(&user1_bis));
        assert!(user1.get_identifier().eq(&id));
    }

    #[test]
    fn test_value_object() {
        use serde_json;

        #[derive(Clone, PartialEq, Debug, Serialize, Deserialize)]
        struct Name(String);

        impl ValueObject<Name> for Name {}

        let name1 = Name("John".to_string());
        let name2 = Name("Jane".to_string());
        let name3 = Name("John".to_string());

        assert!(!name1.eq(&name2));
        assert!(name1.eq(&name3));
        assert_eq!(format!("{:?}", name1), "Name(\"John\")");

        let name1_clone = name1.clone();
        assert!(name1_clone.eq(&name1));

        // Serialization
        let serialized = serde_json::to_string(&name1).unwrap();
        assert_eq!(serialized, r#""John""#);

        // Deserialization
        let deserialized: Name = serde_json::from_str(&serialized).unwrap();
        assert_eq!(deserialized, name1);
    }

    #[test]
    fn test_aggregate() {
        #[derive(Clone, Serialize, Deserialize, PartialEq, Debug)]
        struct User {
            id: u32,
            name: String,
        }

        #[derive(Clone, Serialize, Deserialize, PartialEq, Debug)]
        struct UserCreated {
            id: u32,
            name: String,
        }

        #[derive(Clone, Serialize, Deserialize, PartialEq, Debug)]
        struct UserRenamed {
            id: u32,
            name: String,
        }

        #[derive(Clone, Serialize, Deserialize, PartialEq, Debug)]
        enum UserEvent {
            UserCreated(UserCreated),
            UserRenamed(UserRenamed),
        }

        #[derive(Clone, Serialize, Deserialize, PartialEq, Debug)]
        enum UserCommand {
            CreateUser(User),
            RenameUser(User),
        }

        #[derive(Clone, Serialize, Deserialize, Debug)]
        struct UserAggregate {
            id: u32,
            name: String,
            events: Vec<UserEvent>,
        }

        impl PartialEq for UserAggregate {
            fn eq(&self, other: &Self) -> bool {
                self.id.eq(&other.id)
            }
        }

        impl Entity<UserAggregate> for UserAggregate {
            type Identifier = u32;

            fn get_identifier(&self) -> Self::Identifier {
                self.id
            }
        }

        impl Aggregate<UserAggregate> for UserAggregate {
            type Error = String;
            type Event = UserEvent;
            type Command = UserCommand;
            type Result = Result<Vec<Self::Event>, Self::Error>;

            fn handle(&self, command: Self::Command) -> Self::Result {
                match command {
                    UserCommand::CreateUser(user) => {
                        let event = UserEvent::UserCreated(UserCreated {
                            id: user.id,
                            name: user.name,
                        });
                        Ok(vec![event])
                    }
                    UserCommand::RenameUser(user) => {
                        let event = UserEvent::UserRenamed(UserRenamed {
                            id: user.id,
                            name: user.name,
                        });
                        Ok(vec![event])
                    }
                }
            }

            fn apply(&mut self, event: Self::Event) {
                match event {
                    UserEvent::UserCreated(event) => {
                        self.id = event.id;
                        self.name = event.name;
                    }
                    UserEvent::UserRenamed(event) => {
                        self.name = event.name;
                    }
                }
            }
        }

        let user = UserAggregate {
            id: 1,
            name: "John".to_string(),
            events: vec![],
        };

        let same_user = UserAggregate {
            id: 1,
            name: "Johnny".to_string(),
            events: vec![],
        };
        let different_user = UserAggregate {
            id: 2,
            name: "Johnny".to_string(),
            events: vec![],
        };

        assert!(user.eq(&same_user));
        assert!(!user.eq(&different_user));

        let command = UserCommand::CreateUser(User {
            id: 1,
            name: "John".to_string(),
        });

        // Act
        let result = user.handle(command);

        // Assert
        assert!(result.is_ok());
        let events = result.unwrap();
        assert_eq!(events.len(), 1);
        let event = &events[0];
        assert_eq!(
            *event,
            UserEvent::UserCreated(UserCreated {
                id: 1,
                name: "John".to_string()
            })
        );

        let mut user = UserAggregate {
            id: 0,
            name: "".to_string(),
            events: vec![UserEvent::UserCreated(UserCreated {
                id: 1,
                name: "John".to_string(),
            })],
        };
        let event = UserEvent::UserCreated(UserCreated {
            id: 1,
            name: "John".to_string(),
        });

        user.apply(event);

        assert_eq!(user.id, 1);
        assert_eq!(user.name, "John".to_string());

        let mut user = UserAggregate {
            id: 1,
            name: "John".to_string(),
            events: vec![UserEvent::UserRenamed(UserRenamed {
                id: 1,
                name: "Jane".to_string(),
            })],
        };
        let event = UserEvent::UserRenamed(UserRenamed {
            id: 1,
            name: "Jane".to_string(),
        });

        user.apply(event);

        assert_eq!(user.id, 1);
        assert_eq!(user.name, "Jane".to_string());

        let user_clone = user.clone();
        assert!(user_clone.eq(&user));

        assert_eq!(
            format!("{:?}", user),
            r#"UserAggregate { id: 1, name: "Jane", events: [UserRenamed(UserRenamed { id: 1, name: "Jane" })] }"#
        );

        // Serialization
        let serialized = serde_json::to_string(&user_clone).unwrap();
        assert_eq!(
            serialized,
            r#"{"id":1,"name":"Jane","events":[{"UserRenamed":{"id":1,"name":"Jane"}}]}"#
        );

        // Deserialization
        let deserialized: UserAggregate = serde_json::from_str(&serialized).unwrap();
        assert_eq!(deserialized, user);
    }
}
