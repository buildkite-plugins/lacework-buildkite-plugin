# Lacework Buildkite Plugin (https://buildkite.com/buildkite/plugins-lacework)

A Buildkite plugin that integrates with [Lacework](https://www.lacework.com/).
If you need to start a Lacework trial, [click here](https://aws.amazon.com/marketplace/pp/prodview-wcor2dssgwok6) 

## Initial Configuration

It's necesary to have the [Lacework CLI](https://docs.lacework.net/cli/) installed on the compute running the buildkite agent(s) so you can see the results. The necessary components must be installed as well, install links below:
- SCA Scanning (Software Composition Analysis) (https://docs.lacework.net/iac/restricted/iac-cli#configure-the-cli-for-iac)
- SAST Scanning (Static Application Security Testing) (https://docs.lacework.net/codesecurity/restricted/sast-lw-cli#install-the-sast-component)
- Container Vulnerability Scanning (https://docs.lacework.net/console/local-scanning-quickstart#get-started-with-the-lacework-cli)
- IAC Scanning (Infrastructure As Code) (https://docs.lacework.net/iac/restricted/iac-cli#configure-the-cli-for-iac)

Docker is also needed for vulnerability scans. Make sure you are licensed for the right scanning type. If you are not sure about the right entitlements, contact your Lacework representative or support@lacework.net.


## Authentication with Lacework

Your API key and secret should be available to the job [as any other secret](https://buildkite.com/docs/pipelines/secrets) through a secret manager or environment hook. The value for these secrets can be obtained by following [the corresponding instructions to create a Lacework API key](https://docs.lacework.net/console/api-access-keys).
A separate Authorization token will be needed in place of the API key and secret just for vulnerability scans and can be obtained as such (https://docs.lacework.net/onboarding/integrate-inline-scanner#create-an-inline-scanner-integration-in-the-lacework-console)

There are three ways to authenticate the plug-in with Lacework:
1. Setup a Lacework profile on the compute instance running the job and set the "profile" configuration option under steps. To setup the profile - https://docs.lacework.net/cli/commands/lacework_configure/. For IAC there is an IAC profile which can be setup like this - https://docs.lacework.net/iac/restricted/iac-cli#configure-the-cli
2. Use default environment variables setup on the compute running the buildkite jobs. These variables are LW_API_KEY, LW_API_SECRET. This will not work for vulnerability scans since we are using a separate auth token
3. Pass the API key and secret, or vulnerability authorization token to the Buildkite job with these variables BUILDKITE_PLUGIN_LACEWORK_API_KEY_ENV_VAR (LW API Key), BUILDKITE_PLUGIN_LACEWORK_API_KEY_SECRET_ENV_VAR (LW API Secret), BUILDKITE_PLUGIN_LACEWORK_ACCESS_TOKEN_ENV_VAR (auth token for vuln scans). As mentioned above this can be done with a secrets manager or passing those to the buildkute build under "environment variables" in the options



These are the available configuration options for the plugin:

### Required

#### `account-name` (string)

Your Lacework account name. If your login URL is "mycompany.lacework.net", then the account name should be `mycompany`.

#### `scan-type` (enum)

The Lacework scanning type. Choose from sca, sast, iac or vulnerability

### Optional

#### `api-key-env-var` (string)

Name of the environment variable that contains the authorization token associated with your Lacework account. Only valid for the iac, sast, sca scan-types

#### `api-key-secret-env-var` (string)

Name of the environment variable that contains the API secret associated with your Lacework account. Only valid for the iac, sast, sca scan-types

#### `access-token-env-var` (string)

Name of the environment variable that contains the Vuln scan acces token. Only valid for the vulnerability scan-type

#### `fail-level` (enum)

Only valid for IAC and Vuln scans. Sets the fail level from info, low, medium, high, critical and fails the build with an exit code of 1 if such vulnerabilities/misconfigurations are found

#### ` vulnerability-scan-tag` (string)

Only valid for vulnerability scans. The image tag to scan.

#### `vulnerability-scan-repository` (string)

Only valid for vulnerability scans. The image repository to scan.

#### `iac-scan-type` (enum)

Only valid for iac. Choose from  "cloudformation-scan", "kubernetes-scan", "helm-scan","terraform-scan", "kustomize-scan", "secrets-scan"



## Examples

To perfom an SCA Scan:

```yaml
steps:
  - label: "🔨 Lacework SCA Scan"
    plugins:
      - lacework#v1.0.0:
          account-name: "mycompany"
          scan-type: "sca"
```

To perfom a SAST Scan:

```yaml
steps:
  - label: "🔨 Lacework SAST Scan"
    plugins:
      - lacework#v1.0.0:
          account-name: "mycompany"
          scan-type: "sast"
```

To perfom an IAC Scan with Terraform

```yaml
steps:
  - label: "🔨 Lacework IAC Scan"
    plugins:
      - lacework#v1.0.0:
          account-name: "mycompany"
          scan-type: "iac"
          iac-scan-type: "terraform-scan"
```

To perfom a Vuln Scan preceded by an image docker build

```yaml
steps:
  - command: ls
    plugins:
      - equinixmetal-buildkite/docker-build#v1.0.0:
          tags:
          - 'lw-test-image:latest'
  - label: "🔨 Lacework Vuln Container Scan"
    plugins:
      - lacework#v1.0.0:
          account-name: "mycompany"
          scan-type: "vulnerability"
          vulnerability-scan-repository: "lw-test-image"
          vulnerability-scan-tag: "latest"
```


## Support
For support or any issues, please reach out to tech-alliances@lacework.net
