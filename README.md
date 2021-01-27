# DoS Test Database

## Table of Contents

- [DoS Test Database](#dos-test-database)
  - [Table of Contents](#table-of-contents)
  - [Quick Start](#quick-start)
    - [Development Requirements](#development-requirements)
    - [Local Environment Configuration](#local-environment-configuration)
    - [Local Project Setup](#local-project-setup)
  - [Refresh project infrastructure from the template](#refresh-project-infrastructure-from-the-template)

This project provides a way to build a Core DoS database from the test data.

## Quick Start

### Development Requirements

- macOS operating system provisioned with the `curl -L bit.ly/make-devops-macos | bash` command
- `iTerm2` command-line terminal and `Visual Studio Code` source code editor, which will be installed automatically for you in the next steps
- Before starting any work, please read [CONTRIBUTING.md](documentation/CONTRIBUTING.md)

### Local Environment Configuration

    git clone [project-url]
    cd ./[project-dir]

    make macos-setup
    make devops-setup-aws-accounts
    make trust-certificate

### Local Project Setup

Start up a local version of the Core DoS test database

    make download
    make build
    make start log

Build a reusable database

    make image-create

This produces `dtdb/database` Docker image that can be started up using the following command

    docker run -it --name db-dos \
      --publish 5432:5432 \
      --detach \
      000000000000.dkr.ecr.eu-west-2.amazonaws.com/uec-tools/dtdb/database:latest
    docker logs --follow db-dos

Connect to the database

- Host: `localhost`
- Port: `5432`
- Database name: `pathwaysdos_dev`
- Username: `release_manager`
- Password: `postgres`

## Refresh project infrastructure from the template

    make project-create-infrastructure MODULE_TEMPLATE=rds STACK_TEMPLATE=rds STACK=database PROFILE=dev-v2
