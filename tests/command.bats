#!/usr/bin/env bats

setup() {
  load "$BATS_PLUGIN_PATH/load.bash"

  export BUILDKITE_PLUGIN_LACEWORK_API_KEY_ENV_VAR=key1234
  export BUILDKITE_PLUGIN_LACEWORK_API_KEY_SECRET_ENV_VAR=secret1234
  export BUILDKITE_PLUGIN_LACEWORK_ACCOUNT_NAME='myaccount'
  export BUILDKITE_PLUGIN_LACEWORK_SCAN_TYPE='sca'
}


@test 'Missing  API key environment variable' {
  unset BUILDKITE_PLUGIN_LACEWORK_API_KEY_ENV_VAR
 
  run "${PWD}"/hooks/command

  assert_failure
  assert_output --partial 'ERROR: Missing Lacework API Key and Secret'

}

@test 'Missing API key secret environment variable' {
  unset BUILDKITE_PLUGIN_LACEWORK_API_KEY_SECRET_ENV_VAR

  run "${PWD}"/hooks/command

  assert_failure
  assert_output --partial 'ERROR: Missing Lacework API Key and Secret'
  
}



@test "Error if no account name was set" {
  unset BUILDKITE_PLUGIN_LACEWORK_ACCOUNT_NAME
  run "$PWD/hooks/command"

  assert_failure
  assert_output --partial "ERROR: Missing required config 'account-name'"
}

@test 'PROFILE test SCA' {
  unset BUILDKITE_PLUGIN_LACEWORK_API_KEY_SECRET_ENV_VAR
  unset BUILDKITE_PLUGIN_LACEWORK_API_KEY_ENV_VAR
  export BUILDKITE_PLUGIN_LACEWORK_PROFILE=default

  export BUILDKITE_PLUGIN_LACEWORK_SCAN_TYPE='sca'
  stub lacework \
  "--profile default sca scan . --save-results : echo 'SCA Scan'"

  run "${PWD}"/hooks/command

  assert_success

  unstub lacework
  
}

@test 'Lacework SCA SCAN' {

  export BUILDKITE_PLUGIN_LACEWORK_SCAN_TYPE='sca'
  stub lacework \
  "--account myaccount --api_key key1234 --api_secret secret1234 sca scan . --save-results : echo 'SCA Scan'"

  run "${PWD}"/hooks/command

  assert_success
  
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
  assert_output --partial "lacework --account myaccount --api_key key1234 --api_secret secret1234 sast scan -o lacework-sast-report-slug-123.sarif"
  
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
  
  unstub lacework
}

@test 'Lacework VULN SCAN missing environment variables' {

  BUILDKITE_PLUGIN_LACEWORK_SCAN_TYPE='vulnerability'

  run "${PWD}"/hooks/command

  assert_failure
  
 assert_output --partial "ERROR: Missing config related to vulnerability scans"
}

@test 'Lacework VULN SCAN' {

  BUILDKITE_PLUGIN_LACEWORK_SCAN_TYPE='vulnerability'
  export BUILDKITE_PLUGIN_LACEWORK_ACCESS_TOKEN_ENV_VAR='mytoken1234'
  export BUILDKITE_PLUGIN_LACEWORK_VULNERABILITY_SCAN_REPOSITORY='myrepo'
  export BUILDKITE_PLUGIN_LACEWORK_VULNERABILITY_SCAN_TAG='latest'

  stub lacework \
  "--account-name myaccount --access-token mytoken1234 vuln-scanner -s image evaluate myrepo latest : echo 'Vuln Scan'"

  run "${PWD}"/hooks/command

  assert_success
  
  unstub lacework
}

#@test 'Lacework VULN SCAN with fail' {

  #BUILDKITE_PLUGIN_LACEWORK_SCAN_TYPE='vulnerability'
  #export BUILDKITE_PLUGIN_LACEWORK_ACCESS_TOKEN_ENV_VAR='mytoken1234'
  #export BUILDKITE_PLUGIN_LACEWORK_VULNERABILITY_SCAN_REPOSITORY='myrepo'
  #export BUILDKITE_PLUGIN_LACEWORK_VULNERABILITY_SCAN_TAG='latest'
  #export BUILDKITE_PLUGIN_LACEWORK_FAIL_LEVEL='critical'

  #stub lacework \
  #"--account-name myaccount --access-token mytoken1234 vuln-scanner -s image evaluate myrepo latest --policy --critical-violation-exit-code 1 : echo 'Vuln Scan w failure'"

  #run "${PWD}"/hooks/command

  #assert_failure
  #assert_output --partial "latest --policy --critical-violation-exit-code 1"
  
  #unstub lacework
#}