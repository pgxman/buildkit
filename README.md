# PGXMan Buildkit

PGXMan Buildkit is a YAML configuration file that `pgxman` employs to define the build and packaging of a PostgreSQL extension.
Explore the specification for more details [here](https://github.com/pgxman/pgxman/blob/main/spec/buildkit.md).

This repository is a hub for the buildkits of various well-known PostgreSQL extensions. Your contributions are welcome! Feel free to enhance our collection by submitting a PR.

## :star: Contributing a Buildkit

Eager to contribute? Follow these steps to add a new buildkit:

1. Fork this repository
1. Add a buildkit configuration file in the `buildkit` directory
1. Build the extension using the command `pgxman build -f buildkit/<extension>.yaml` and ensure the build is successful.
1. Test the built extension with a PostgreSQL instance to verify its functionality.
1. Submit a pull request to this repository for review.

Your contribution will go through a review process, and once approved, it will be merged into the main repository!

## :rocket: Build Artifact Publication

Wondering how the build artifacts are shared with the community?
They are published to an Apt repository via GitHub Actions.
The workflow is defined in [.github/ci.yaml](.github/ci.yaml).
