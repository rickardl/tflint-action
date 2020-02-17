# Terraform TFLint action

This action runs [https://github.com/terraform-linters/tflint](https://github.com/terraform-linters/tflint) on `$GITHUB_WORKSPACE`. TFLint is a Terraform linter focused on possible errors, best practices, etc. (Terraform >= 0.12)

The action requires the [actions/checkout@v2](https://github.com/actions/checkout) before to download the content of your repo inside the docker.

## Inputs

| Parameter                        | Value | Description                                                                           |
| -------------------------------- | ----- | ------------------------------------------------------------------------------------- |
| `TFLINT_ACTION_COMMENT`          | true  | (Optional) Whether or not to comment on GitHub pull requests.                         |
| `TFLINT_ACTION_TERRAFORM_FOLDER` | `.`   | Which directory the `Terraform` code resides. Relative to the root of the repository. |
| `TFLINT_ACTION_OPTS`             | none  | Optional arguments to tflint.                                                         |

## Usage

```yaml
on: pull_request
name: tflint action
jobs:
  lint:
    name: Terraform Lint on PR
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: rickardl/tflint-action@v1
```

The above example uses a tagged version (`v1`), you can also opt to use any of the released version.

To allow the action to add a comment to a PR when it fails you need to append the `GITHUB_TOKEN` variable to the tflint action:

```yaml
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

Full example:

```yaml
jobs:
  tflint:
    name: tlint
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v2
      - name: Terraform Lint
        uses: rickardl/tflint-action@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Authors

Currently maintained by [these contributors](../../graphs/contributors).

## License

MIT License. See [LICENSE](LICENSE) for full details.
