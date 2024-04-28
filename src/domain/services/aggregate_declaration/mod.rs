use std::net::IpAddr;

use crate::domain::models::{
    value_objects::cluster::{
        node::{Node, Private, Public, Role, Sensitive},
        name::{Nodename, nameError},
    },
    DomainError,
};

pub struct NodeBuilder {
    name: Result<Nodename, nameError>,
    name_server: String,
    ip: IpAddr,
    role: Role,
}

impl NodeBuilder {
    pub fn new(name: String, name_server: String, ip: IpAddr, role: Role) -> Self {
        let name: Result<Nodename, nameError> = Nodename::new(name);
        Self {
            name,
            name_server,
            ip,
            role,
        }
    }

    pub fn build(&self) -> Result<Node, DomainError> {
        self.name
            .as_ref()
            .map_err(|error| DomainError::name(error.to_owned()))
            .map(|name| {
                let sensitive = Sensitive::new(self.name_server.to_owned(), self.ip.to_owned());
                let private = Private::new();
                let public = Public::new(name.to_owned());
                Node::new(sensitive, private, public, self.role.to_owned())
            })
    }
}

// TODO: use this in use case
// pub fn declare_cluster(
//     cluster_name: String,
//     nodes: HashMap<Nodename, Node>,
//     callback: impl Fn(Result<(Vec<DomainEvent>, Cluster), DomainError>),
// ) {
//     Clustername::new(cluster_name)
//         .map_err(|error| {
//             callback(Err(DomainError::name(error)));
//         })
//         .map(|name| {
//             Cluster::declare(name, nodes)
//                 .map_err(|error| callback(Err(DomainError::Cluster(error))))
//                 .map(|(event, cluster)| {
//                     let cluster = &mut cluster;
//                     let _pipeline = get_default_pipeline(cluster);
//                     let events = vec![DomainEvent::Cluster(event)];
//                     callback(Ok((events, cluster)));
//                 })
//                 .ok();
//         })
//         .ok();
// }
