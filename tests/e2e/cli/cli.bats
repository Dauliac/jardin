@test "As client I want to run script without arguments" {
    run targets/debug/jardin
}

@test "As client I want to run script to get help" {
    run targets/debug/jardin -h
    run targets/debug/jardin --help
}

@test "As client I want to run script to generate completion" {
  run bash -c eval $(./target/debug/jardin --complete bash)
  run zsh -c eval $(./target/debug/jardin --complete zsh)
  run fish -c eval $(./target/debug/jardin --complete fish)
}
