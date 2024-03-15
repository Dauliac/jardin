 

use std::fmt::{self, Display};

pub enum DomainLoggerType {
    Cluster,
    Step,
    Job,
    PreCheck,
    PostCheck,
}

impl Display for DomainLoggerType {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let printable = match *self {
            DomainLoggerType::Step => "step",
            DomainLoggerType::Job => "job",
            DomainLoggerType::PreCheck => "pre-check",
            DomainLoggerType::PostCheck => "post-check",
            DomainLoggerType::Cluster => "cluster",
        };
        write!(f, "{}", printable)
    }
}

pub enum ApplicationLoggerType {
    Config,
    Completion,
    CommandLineInterface,
    Deployment,
}

impl Display for ApplicationLoggerType {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let printable = match *self {
            ApplicationLoggerType::Config => "config",
            ApplicationLoggerType::Completion => "completion",
            ApplicationLoggerType::CommandLineInterface => "cli",
            ApplicationLoggerType::Deployment => "deployment",
        };
        write!(f, "{}", printable)
    }
}

pub enum LoggerType {
    Domain(DomainLoggerType),
    Application(ApplicationLoggerType),
}

impl Display for LoggerType {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            LoggerType::Application(logger) => logger.fmt(f),
            LoggerType::Domain(logger) => logger.fmt(f),
        }
    }
}
