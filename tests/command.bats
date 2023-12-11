#!/usr/bin/env bats

setup() {
  load "$BATS_PLUGIN_PATH/load.bash"

  export LW_API_KEY='API_KEY'
  export MY_VAR='SECRET_VALUE'
  export BUILDKITE_PLUGIN_LACEWORK_API_KEY_ENV_VAR=MY_VAR
  export BUILDKITE_PLUGIN_LACEWORK_API_KEY_SECRET_ENV_VAR=MY_VAR
  export BUILDKITE_PLUGIN_LACEWORK_ACCOUNT_NAME='mycompany'
}

@test 'Default API key environment variable is used' {
  unset BUILDKITE_PLUGIN_LACEWORK_API_KEY_ENV_VAR
  stub lacework "echo called with params \$@"
  run "${PWD}"/hooks/command

  assert_success
  assert_output --partial '--api_key API_KEY'
  
  unstub lacework
}

@test 'Missing custom API key environment variable' {
  unset MY_VAR

  run "${PWD}"/hooks/command

  assert_failure
  assert_output --partial 'unbound variable'
}

@test 'Missing default API key environment variable' {
  unset LW_API_KEY
  unset BUILDKITE_PLUGIN_LACEWORK_API_KEY_ENV_VAR

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

@test 'Missing API key secret environment variable' {
  unset BUILDKITE_PLUGIN_LACEWORK_API_KEY_SECRET_ENV_VAR
  export LW_API_SECRET='API_KEY_SECRET'
  stub lacework "echo called with params \$@"
  run "${PWD}"/hooks/command

  assert_success
  assert_output --partial '--api_secret API_KEY_SECRET'
  
  unstub lacework
}
