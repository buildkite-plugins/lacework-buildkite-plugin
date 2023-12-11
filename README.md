# Lacework Buildkite Plugin

A Buildkite plugin that integrates with [Lacework](https://www.lacework.com/).

## Configuration

It's necesary to have the [Lacework CLI](https://docs.lacework.net/cli/) installed in order to send the metadata schema output into the Lacework UI so you can see the results, and the component to use. Currently, the plugin only supports the `sca` component.

You should add the secrets `LW_API_KEY` and `LW_API_SECRET` into your secret manager or environment hook. The value for these secrets can be obtained by following the instructions [here](https://docs.lacework.net/console/api-access-keys) to create an API key and then download it.

These are the available configuration options for the plugin.

### Required

#### `account-name` (string)

Your Lacework account name. If your login URL is "mycompany.lacework.net", then the account name should be `mycompany`.

### Optional

#### `api-key-env-var` (string)

Name of the environment variable that contains the authorization token associated with your Lacework account.

Default: `LW_API_KEY`

#### `api-key-secret-env-var` (string)

Name of the environment variable that contains the API secret associated with your Lacework account.

Default: `LW_API_SECRET`

#### `profile` (string)

When you run a command, you can specify a `--profile name`` and use the credentials and settings stored under that name.

Default: `default`


## Examples

To perfom a Software Component Analysis:

steps:
  - label: "🔨 Analysis"
    plugins:
      - lacework#v1.0.0:
          account-name: "mycompany"