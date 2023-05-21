use application::start;
use tokio::main;

pub mod application;
pub mod domain;
pub mod infrastructure;

#[main]
async fn main() {
    start();
}
