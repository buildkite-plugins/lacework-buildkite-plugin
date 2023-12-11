# Lacework Buildkite Plugin

A Buildkite plugin that integrates with [Lacework](https://www.lacework.com/).

## Configuration

It's necesary to have the [Lacework CLI](https://docs.lacework.net/cli/) installed in order to send the metadata schema output into the Lacework UI so you can see the results. Also, the necessary components must be installed as well. Currently, the plugin only supports the `sca` component.

Your API key and secret should be available to the job [as any other secret](https://buildkite.com/docs/pipelines/secrets) through a secret manager or environment hook. The value for these secrets can be obtained by following [the corresponding instructions to create a Lacework API key](https://docs.lacework.net/console/api-access-keys).

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

Default: `""` (use the Lacework CLI default profile)


## Examples

To perfom a Software Component Analysis:

```yaml
steps:
  - label: "🔨 Analysis"
    plugins:
      - lacework#v1.0.0:
          account-name: "mycompany"
```
