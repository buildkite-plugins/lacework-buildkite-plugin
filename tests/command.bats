#!/usr/bin/env bats

setup() {
  load "$BATS_PLUGIN_PATH/load.bash"

  export LW_API_KEY='SECRET_VALUE'
  export MY_VAR='SECRET_VALUE'
  export BUILDKITE_PLUGIN_LACEWORK_API_KEY_ENV_VAR=MY_VAR
  export BUILDKITE_PLUGIN_LACEWORK_API_KEY_SECRET_ENV_VAR=MY_VAR
  export BUILDKITE_PLUGIN_LACEWORK_ACCOUNT_NAME='mycompany'
}

@test 'Missing default API key environment variable' {
  unset BUILDKITE_PLUGIN_LACEWORK_API_KEY_ENV_VAR
  stub lacework 'exit 2'
  run "${PWD}"/hooks/command

  assert_failure
  refute_output --partial 'unbound variable'
  unstub lacework
}

@test 'Missing custom API key environment variable' {
  unset MY_VAR

  run "${PWD}"/hooks/command

  assert_failure
  assert_output --partial 'unbound variable'
}

@test "Error if no account name was set" {
  unset BUILDKITE_PLUGIN_LACEWORK_ACCOUNT_NAME
  run "$PWD/hooks/command"

  assert_failure
  assert_output --partial "ERROR: Missing required config 'account_name'"
}
