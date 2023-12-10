# Lacework Buildkite Plugin

A Buildkite plugin that integrates with [Lacework](https://www.lacework.com/) image evaluation.

## Configuration

These are the available configuration options for the plugin.

### Required

#### `account-name` (string)

Your Lacework account name. If your login URL is "mycompany.lacework.net", then the account name should be `mycompany`.

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

