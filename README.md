[![repo standards badge](https://img.shields.io/badge/dynamic/json?color=blue&style=flat&logo=github&labelColor=32393F&label=MoJ%20Compliant&query=%24.result&url=https%3A%2F%2Foperations-engineering-reports.cloud-platform.service.justice.gov.uk%2Fapi%2Fv1%2Fcompliant_public_repositories%2Fnetwork-access-control-admin)](https://operations-engineering-reports.cloud-platform.service.justice.gov.uk/public-github-repositories.html#network-access-control-admin "Link to report")

# Network Access Control Admin

This is the web frontend for managing Network Access Control

## Getting Started

### Authenticating with DockerHub


Local development shouldn't go over the download limits of Dockerhub.
https://docs.docker.com/docker-hub/download-rate-limit/

If these limits are encountered, authentication with Docker is required:

```
export DOCKER_USERNAME=your-docker-hub-username
export DOCKER_PASSWORD=your-docker-hub-password

make authenticate-docker
```

### Prepare the Variables

1. Clone the repository to a local directory
1. Create a `.env` file in the root directory and populate with the required values for the environment



### Build the Containers
3. Build the base images on your local docker

```sh
make build-dev
```

### Setup Database

4. Start the database image and run setup

```sh
make db-setup
```

### Run the Application

5. Start the application on your local docker

```sh
$ make serve
```

### Running Tests Locally

6. Setup the test database

```sh
ENV=test make db-setup
```

7. Run the entire test suite

```sh
ENV=test make test
```

To run individual tests:

8. Shell onto a test container

```sh
ENV=test make shell
```

9. Run the test file or folder

```sh
bundle exec rspec path/to/spec/file
```

## Scripts

There are two utility scripts in the `./scripts` directory to:

1. Migrate the database schema
2. Deploy new tasks into the service

### Deployment

The `deploy` command is wrapped in a Makefile. It calls `./scripts/deploy` which schedules a zero downtime phased [deployment](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/update-service.html) in ECS.

It doubles the currently running tasks and briefly serves traffic from the new and existing tasks in the service.
The older tasks are eventually decommissioned, and production traffic is gradually shifted over to only the new running tasks.

On CI this command is executed from the [buildspec.yml](./buildspec.yml) file after migrations and publishing the new image to ECR has been completed.

### Targetting the ECS Cluster and Service to Deploy

The ECS infrastructure is managed by Terraform. The name of the cluster and service are [outputs](https://www.terraform.io/docs/configuration/outputs.html) from the Terraform apply. These values are published to SSM Parameter Store, when this container is deployed it pulls those values from Parameter Store and sets them as environment variables.

The deploy script references these environment variables to target the ECS Admin service and cluster. This is to avoid depending on the hardcoded strings.

The build pipeline assumes a role to access the target AWS account.

#### Publishing Image from Local Machine

1. Export the following configurations as an environment variable.

```bash
  export NAC_TERRAFORM_OUTPUTS='{
    "admin": {
      "ecs": {
        "cluster_name": "[TARGET_CLUSTER_NAME]",
        "service_name": "[TARGET_SERVICE_NAME]"
      }
    }
  }'
```

This mimics what happens on CI where this environment variable is already set.

When run locally, you need to target the AWS account directly with AWS Vault.

2. Schedule the deployment

```bash
  aws-vault exec [target_aws_account_profile] -- make deploy
```

## Certificate management

There are 3 types of certificates required to allow authentications:
- End-User trust certificates
- Infrastructure certificates
- Server certificates

### End-User trust certificates

These are the certificate authorities (CAs) of the end user device certificates installed on the NACS server to establish trust and only allow authorised devices to connect. This can contain root and any intermediate certificates, uploaded as separate PEM files. No encrypted private key is required.

### Infrastructure certificates

These are the certificate authorities (CAs) of the network authenticator vendors, installed on the NACS server and used to establish trust between authenticators and the server. These used for RADSEC connections exclusively. No encrypted private key is required.

### Server certificates

There are 2 types of server certificates uploaded to NACS. 
The first is used for RADSEC, and sent to the authenticators. The second is used for authentication and sent to the end user devices. This is to establish trust and ensure that the devices / authenticators are communicating with the actual Network Access Control Service. 
These certificates are uploaded as PEM files. 

To upload a new server certificate, follow these steps:

1. Ensure the encrypted private key is included in the PEM file.
2. Ensure the passphrase for the key is up to date in AWS Systems Manager Parameter Store in the Shared Services AWS account.
    - If the passphrase has changed, a deployment of the infrastructure pipeline followed by a deployment of the admin pipeline is required.
    - Validations are in place to only allow uploading certificates with encrypted private keys that match the current passphrase.
3. Ensure the "Server Certificate" checkbox is selected when uploading these certificates.
## CI/CD

- [CI Terraform code - network-access-control-admin](https://github.com/ministryofjustice/network-access-control-admin)
- Terraform module - module "network-access-control-admin"
- AWS Account - MOJ Official (Shared Services)
- [Pipeline "network-access-control-server"](https://eu-west-2.console.aws.amazon.com/codesuite/codepipeline/pipelines/network-access-control-admin/view?region=eu-west-2)
