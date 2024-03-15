use serde::{Deserialize, Serialize};

use self::nix::Nix;

pub mod nix;

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq, Eq, Hash)]
pub enum Backend {
    Nix(Nix),
}

impl Backend {
    pub fn get_nix() -> Backend {
        Backend::Nix(Nix {})
    }
}

#[cfg(test)]
pub mod tests {
    use super::*;

    #[test]
    fn test_backend() {
        let backend = Backend::get_nix();
        assert_eq!(backend, backend);
    }
}
