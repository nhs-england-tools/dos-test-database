# Todo

## Table of contents

- [Todo](#todo)
  - [Table of contents](#table-of-contents)
  - [Documentation](#documentation)
  - [General](#general)

## Documentation

- Quick start guide for dev and ops in the `README.md` file
- Instructions on how to use the `database` Docker image
- Diagrams

## General

- Make sure Core DoS database roles and users are present and operational
- Provide a sample Core DoS database dump file that can be shared publicly
- Consider a different source of the Core DoS database dump, i.e. Profile Updater nightly data feed
- Currently the Jenkins AWS role does not have permissions to describe RDS
- There is no security group that would provide access to the database for a developer
- Allow to create multiple DoS schemas in a single database instance
