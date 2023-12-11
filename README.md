# Lacework Buildkite Plugin

A Buildkite plugin that integrates with [Lacework](https://www.lacework.com/) image evaluation.

## Configuration

It's necesary to have the [Lacework CLI](https://docs.lacework.net/cli/) installed in order to send the metadata schema output into the Lacework UI so you can see the results, and the component to use.

These are the available configuration options for the plugin.

### Required

#### `account-name` (string)

Your Lacework account name. If your login URL is "mycompany.lacework.net", then the account name should be `mycompany`.

### Optional

#### `api-key-env-var` (string)

Name of the environment variable that contains the authorization token associated with your Lacework account.
Default: `LW_API_KEY`

#### `component` (string)

Name of the Lacework component to use.
































#### `image-name` (string)

The image name to be evaluated

#### `image-tag` (string)

The tag for the image to evaluate.

### Optional

#### `access-token-var` (string)

The name of the environment variable that contains the authorization token associated with your Lacework account.
Default: `LW_ACCESS_TOKEN`

#### `cli-updates` (boolean)

Enable this option of the CLI tool to check for available new versions of itself and display a message if there are.
Default: `false`

