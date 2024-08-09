#!/usr/bin/env bats

# export LACEWORK_STUB_DEBUG=/dev/tty
# export BUILDKITE_AGENT_STUB_DEBUG=/dev/tty

setup() {
  load "$BATS_PLUGIN_PATH/load.bash"

  export BUILDKITE_PLUGIN_LACEWORK_API_KEY_ENV_VAR=key1234
  export BUILDKITE_PLUGIN_LACEWORK_API_KEY_SECRET_ENV_VAR=secret1234
  export BUILDKITE_PLUGIN_LACEWORK_ACCOUNT_NAME='myaccount'
  export BUILDKITE_PLUGIN_LACEWORK_SCAN_TYPE='sca'
  export BUILDKITE_PIPELINE_SLUG='pipeline-slug'
  export BUILDKITE_BUILD_NUMBER=3
}

@test 'Missing  API key environment variable' {
  unset BUILDKITE_PLUGIN_LACEWORK_API_KEY_ENV_VAR

  stub buildkite-agent \
    "annotate * --style error --context lacework : echo 'buildkite-agent: Error Annotation'"

  run "${PWD}"/hooks/command

  assert_failure
  assert_output --partial "ERROR: Missing Lacework API Key and Secret or profile"
  assert_output --partial "buildkite-agent: Error Annotation"

  unstub buildkite-agent
}

@test 'Missing API key secret environment variable' {
  unset BUILDKITE_PLUGIN_LACEWORK_API_KEY_SECRET_ENV_VAR

  stub buildkite-agent \
    "annotate * --style error --context lacework : echo 'buildkite-agent: Error Annotation'"

  run "${PWD}"/hooks/command

  assert_failure
  assert_output --partial 'ERROR: Missing Lacework API Key and Secret'
  assert_output --partial "buildkite-agent: Error Annotation"

  unstub buildkite-agent
}

@test "Error if no account name was set" {
  unset BUILDKITE_PLUGIN_LACEWORK_ACCOUNT_NAME

  stub buildkite-agent \
    "annotate * --style error --context lacework : echo 'buildkite-agent: Error Annotation'"

  run "${PWD}"/hooks/command

  assert_failure
  assert_output --partial "ERROR: Missing required config 'account-name'"
  assert_output --partial "buildkite-agent: Error Annotation"

  unstub buildkite-agent
}

@test 'PROFILE test SCA' {
  unset BUILDKITE_PLUGIN_LACEWORK_API_KEY_SECRET_ENV_VAR
  unset BUILDKITE_PLUGIN_LACEWORK_API_KEY_ENV_VAR
  export BUILDKITE_PLUGIN_LACEWORK_PROFILE="default"

  export BUILDKITE_PLUGIN_LACEWORK_SCAN_TYPE='sca'
  stub lacework \
    "--profile default sca scan . --save-results : echo 'SCA Scan'"

  run "${PWD}"/hooks/command

  assert_success
  assert_output --partial "SCA Scan"

  unstub lacework

}

@test 'Lacework SCA SCAN' {

  export BUILDKITE_PLUGIN_LACEWORK_SCAN_TYPE='sca'
  stub lacework \
    "--account myaccount --api_key key1234 --api_secret secret1234 sca scan . --save-results : echo 'SCA Scan'"

  run "${PWD}"/hooks/command

  assert_success
  assert_output --partial "SCA Scan"

  unstub lacework
}

@test 'Lacework SAST SCAN' {

  export BUILDKITE_PLUGIN_LACEWORK_SCAN_TYPE='sast'

  export BUILDKITE_PIPELINE_SLUG='slug'
  export BUILDKITE_BUILD_NUMBER='123'

  stub lacework \
    "--account myaccount --api_key key1234 --api_secret secret1234 sast scan -o lacework-sast-report-slug-123.sarif : echo 'SAST Scan'"

  #stub buildkite-agent \
  #"artifact upload  lacework-sast-report-slug-123.sarif : echo 'SAST Scan Artifact'"

  run "${PWD}"/hooks/command

  #assert_success
  assert_output --partial "SAST Scan"

  unstub lacework
  #unstub buildkite-agent
}

@test 'Lacework IAC SCAN missing IAC scan type' {

  export BUILDKITE_PLUGIN_LACEWORK_SCAN_TYPE='iac'

  run "${PWD}"/hooks/command

  assert_failure
  assert_output --partial "ERROR: Missing config related to IAC scans."
}

@test 'Lacework IAC SCAN' {

  export BUILDKITE_PLUGIN_LACEWORK_SCAN_TYPE='iac'
  export BUILDKITE_PLUGIN_LACEWORK_IAC_SCAN_TYPE='kubernetes-scan'

  stub lacework \
    "iac kubernetes-scan : echo 'IAC Scan'"

  run "${PWD}"/hooks/command

  assert_success
  assert_output --partial "IAC Scan"

  unstub lacework
}

@test 'Lacework IAC SCAN with fail' {

  export BUILDKITE_PLUGIN_LACEWORK_SCAN_TYPE='iac'
  export BUILDKITE_PLUGIN_LACEWORK_IAC_SCAN_TYPE='kubernetes-scan'
  export BUILDKITE_PLUGIN_LACEWORK_FAIL_LEVEL='critical'

  stub lacework \
    "iac kubernetes-scan --fail critical : echo 'IAC Scan'"

  run "${PWD}"/hooks/command

  assert_success
  assert_output --partial "IAC Scan"

  unstub lacework
}

@test 'Lacework VULN SCAN missing environment variables' {
  export BUILDKITE_PLUGIN_LACEWORK_SCAN_TYPE='vulnerability'

  run "${PWD}"/hooks/command

  assert_failure

  assert_output --partial "ERROR: Missing config related to vulnerability scans"
}

@test 'Lacework VULN SCAN' {
  export BUILDKITE_PLUGIN_LACEWORK_SCAN_TYPE='vulnerability'
  export BUILDKITE_PLUGIN_LACEWORK_ACCESS_TOKEN_ENV_VAR='mytoken1234'
  export BUILDKITE_PLUGIN_LACEWORK_VULNERABILITY_SCAN_REPOSITORY='myrepo'
  export BUILDKITE_PLUGIN_LACEWORK_VULNERABILITY_SCAN_TAG='latest'

  stub lacework \
    "--account-name myaccount --access-token mytoken1234 vuln-scanner -s image evaluate myrepo latest : echo 'Vuln Scan'"

  run "${PWD}"/hooks/command

  assert_success
  assert_output --partial "Vuln Scan"

  unstub lacework
}
