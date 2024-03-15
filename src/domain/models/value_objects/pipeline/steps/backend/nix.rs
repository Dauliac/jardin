use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq, Eq, Hash)]
pub struct Nix {}

#[cfg(test)]
pub mod tests {
    use super::*;

    #[test]
    fn test_nix() {
        let nix = Nix {};
        assert_eq!(nix, nix);
    }
}
