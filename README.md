# PGXMan Buildkit

PGXMan Buildkit is a YAML configuration file that `pgxman` employs to define the build and packaging of a PostgreSQL extension.
[Explore the specification for more details](spec/buildkit.md).

This repository is a hub for the buildkits of various well-known PostgreSQL extensions. Your contributions are welcome! Feel free to enhance our collection by submitting a PR.

## :star: Contributing a Buildkit

Eager to contribute? Follow these steps to add a new buildkit:

1. Fork this repository
1. Add a buildkit configuration file in the `buildkit` directory
1. Build the extension using the command `pgxman build -f buildkit/<extension>.yaml` and ensure the build is successful.
1. Test the built extension with a PostgreSQL instance to verify its functionality.
1. Submit a pull request to this repository for review.

Your contribution will go through a review process, and once approved, it will be merged into the main repository!

### Example Configuration

Below is an example buildkit configuration for [pgvector](https://github.com/pgvector/pgvector):

```yaml
apiVersion: v1
name: pgvector
version: "0.4.4"
homepage: https://github.com/pgvector/pgvector
source: https://github.com/pgvector/pgvector/archive/refs/tags/v0.4.4.tar.gz
description: Open-source vector similarity search for Postgres.
license: PostgreSQL
keywords:
  - nearest-neighbor-search
  - approximate-nearest-neighbor-search
arch:
  - amd64
  - arm64
maintainers:
  - name: Owen Ou
    email: o@hydra.so
build:
  main:
    - name: Build pgvector
      run: |
        make
        DESTDIR=${DESTDIR} make install
pgVersions:
  - "13"
  - "14"
  - "15"
```

## :rocket: Build Artifact Publication

Wondering how the build artifacts are shared with the community?
They are published to an Apt repository via GitHub Actions.
The workflow is defined in [.github/ci.yaml](.github/ci.yaml).
