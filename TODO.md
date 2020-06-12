# TODO

- Provide a sample Core DoS database dump file that can be shared publicly
- Make sure Core DoS database roles and users are present and operational
- Consider a different source of the Core DoS database dump, i.e. Profile Updater nightly data feed
- Version image after the DoS release

Pipeline Questions, tasks, and issues that need resolving

- Currently the Jenkins AWS role doesn't appear to have permissions to query RDS about the endpoint address
  or the username of an instance. Either need to modify the Jenkins role or assume a different one.

- Currently seeing some error when the `k8s-replace-variables` make target runs about a missing `$key`,
  as part of calling the target `k8s-deploy-job`. Though this is happing the target still creates valid k8s
  files with the correct variable values.

- In the infrastructure definition the RDS doesn't currently have a security group add/set that would provide
  access for a developer us the database from there development environment. Would it be expected that you
  would have dev environment access / should we add it ?

- A review of the terraform code for the RDS DoS database model needs to be done to check to see if the current
  parameters values are correct. Additional need to check that all expected configurable aspect of the module
  are being parameterised.

- Provide a solution or instructions on how to use the docker image with database sql as a local instance of
  the Dos database.
