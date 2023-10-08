use std::{net::IpAddr, path::PathBuf};

use crate::domain::models::{
    value_objects::cluster::{
        node::{Node, Private, Public, Role, Sensitive},
        surname::{NodeSurname, SurnameError},
    },
    DomainError,
};

pub struct NodeBuilder {
    surname: Result<NodeSurname, SurnameError>,
    name_server: String,
    ip: IpAddr,
    ssh_key_path: PathBuf,
    role: Role,
}

impl NodeBuilder {
    pub fn new(
        surname: String,
        name_server: String,
        ip: IpAddr,
        ssh_key_path: PathBuf,
        role: Role,
    ) -> Self {
        let surname: Result<NodeSurname, SurnameError> = NodeSurname::new(surname);
        Self {
            surname,
            name_server,
            ip,
            ssh_key_path,
            role,
        }
    }

    pub fn build(&self) -> Result<Node, DomainError> {
        self.surname
            .as_ref()
            .map_err(|error| DomainError::Surname(error.to_owned()))
            .map(|surname| {
                let sensitive = Sensitive::new(
                    self.name_server.to_owned(),
                    self.ip.to_owned(),
                    self.ssh_key_path.to_owned(),
                );
                let private = Private::new();
                let public = Public::new(surname.to_owned());
                Node::new(sensitive, private, public, self.role.to_owned())
            })
    }
}

// TODO: use this in use case
// pub fn declare_cluster(
//     cluster_surname: String,
//     targets: HashMap<NodeSurname, Node>,
//     callback: impl Fn(Result<(Vec<DomainEvent>, Cluster), DomainError>),
// ) {
//     ClusterSurname::new(cluster_surname)
//         .map_err(|error| {
//             callback(Err(DomainError::Surname(error)));
//         })
//         .map(|surname| {
//             Cluster::declare(surname, targets)
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
