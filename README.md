# Terraform Beginner Bootcamp 2023

Semantic versioning[^1] is a system for assigning version numbers that conveys meaning about the code changes in each new release. It follows a **MAJOR.MINOR.PATCH** format, e.g. `1.0.1`:

- MAJOR version - Incremented when incompatible API changes are made. This signals breaking changes.

- MINOR version - Incremented when backwards-compatible functionality is added. No existing code should break.

- PATCH version - Incremented when backwards-compatible bug fixes are made.

Additional labels can be attached for pre-release and build metadata.

Some key principles of semantic versioning:

- Versions should be parsed and compared easily by programs.

- Clearly communicates impact of updates for users and maintainers.

- Flexible for varied development workflows.

- Provides an easy way to set version dependencies.

Overall, semantic versioning provides a standardized, semantic system for version numbers that gives meaning to each version bump. This helps manage expectations around updates and reduces version number confusion. It has become a very common versioning approach, especially for open source libraries and APIs.

## Install Terraform CLI
### Considerations with the installation of Terraform
The commands to install Terraform were incorrect and utilized deprecate commands. Referred to the latest Hashicorp installation instructions for Terraform.

1.  Type `lsb_release -a` in a BASH terminal to determine what distribution of Linux is running
2. [Documentation on installing the Terraform CLI](https://developer.hashicorp.com/terraform/downloads?ajs_aid=22fc059b-b792-4213-a9f8-2d26d4fc4b31&product_intent=terraform)
3. Replace Terraform installation instructions in `.gitpod.yml` with those on the Hashicorp website and transfer commands to Bash script [./bin/install_terraform_cli](./bin/install_terraform_cli)

### Gitpod Lifecycle Considerations
+ We need to be careful using using `init` because it will not rerun commands in that section if an existing workspace is restarted. 
+ Change Gitpod tasks in `.gitpod.yml`, from `init` to `before` so installation occurs everytime new workspace is started.[^2]

## Working with Environment Variables
+ To list all currently set environment variables, use the `env` command
+ The results of the `env` command can be filtered using the `grep` command, e.g. `env | grep AWS_`

### Setting/Unsetting Environment Variables
+ To set a variable, execute `variable_name=value_of_variable`, e.g. `GREETING='Hi, there!'`
+ This method sets the environment variable in the current terminal that is being used. If another terminal is opened, this enviroment variable will not be available.
+ To set environment variables *globally*, execute the following `export GREETING='Hi, there!!'`
+ To check the value of an environment variable, execute `echo $VARIABLE_NAME`, e.g. `echo $GREETING` or `env | grep GREETING`
+ To unset an environment variable, execute `unset VARIABLE_NAME`, e.g. `unset HELLO`

### Setting Environment Variables in Gitpod
+ To set a variable, execute `gp env variable_name=value_of_variable`, e.g. `gp env GREETING='Hi, there!'`

## Installing AWS CLI
Transferring commands to install AWS CLI into a Bash script will aid in debugging potential issues, and enable portability of feature to other sections of project
- [Instructions for installing the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

- The location of the script to install the AWS CLI is [./bin/install_aws_cli](./bin/install_aws_cli)

### She-bang
+ Scripts in the Linux environment, start with the she-bang[^3], `#!`, followed by the path to the executable, `/usr/bin/env bash`. This indicates to the Bash shell which program will be used to execute script; in this instance, Bash is going to be used to execute script.

### Linux Permissions
+ When new files are created in the environment, they are not given the permission to be executed. This permission has to be explicitly given to the file.
+ Use the `chmod`[^4] command to change the permission of files and directories, e.g. `chmod u+x file_name` or `chmod 0744 file_name`
+ `u+x` indicates that the executable permission will be enabled for the user
+ `0744` this is the octet representation for read, write & execute permissions for user, group, & other. This indicates that read, write and execute permissions will be enabled for the user, and only read permission enabled for group and all others

### AWS CLI Environment Variables
To check which AWS user is configured to execute API calls, execute `aws sts get-caller-identity`, if successful, something similar to the following output will be displayed:
```json
{
    "UserId": "AIDA3NTPOYBEXAMPLES",
    "Account": "123456789112",
    "Arn": "arn:aws:iam::123456789112:user/terraform-bootcamp"
}
```
[Configuring AWS CLI env vars](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html)
<p>It is necessary to generate AWS CLI credentials via AWS IAM console to utilize the AWS CLI</p>

## Terraform Basics

### Providers

Terraform providers configure access to cloud platforms like AWS, Azure, or GCP. Providers are initialized with `terraform init`. 

Example providers:

- AWS
- AzureRM
- Google 

### Modules

Modules encapsulate reusable Terraform configurations. Modules can be used to create pre-built infrastructure components. 

Module example:

```
module "vpc" {
  source = "./vpc-module"
  name = "my-vpc"
}
```
Terraform documentation on generating random ids, uuids, numbers and strings using the *random* provider can be found [here.](https://registry.terraform.io/providers/hashicorp/random/latest/docs)

### State Files

The `terraform.tfstate` file tracks metadata like resource IDs and associates them with real world objects. This allows Terraform to determine differences between real and desired state.

**The state file should not be manually edited.**

### Lock Files 

`.terraform.lock.lock` files prevent conflicting operations from different Terraform commands running at the same time.

### Common Commands

- `terraform init` - Initializes Providers and Modules
- `terraform plan` - Previews changes 
- `terraform apply` - Applies changes
- `terraform destroy` - Destroys infrastructure

### Version Control

The following are recommended for version control:

- `.tf` files - Infrastructure as Code files
- `.tfvars` files - Input variable files

The following should NOT be committed to version control:

- `terraform.tfstate` 
- `.terraform` directory
- `.terraform.lock.hcl`

This separation prevents sensitive data exposure.

## Terraform Cloud
To migrate the state file from the local environment to Terra Cloud:
1. [Sign up for Terraform Cloud](https://developer.hashicorp.com/terraform/tutorials/cloud-get-started/cloud-sign-up)
2. Create new project and workspace
2. When executing the `terraform login` command, the script utilizes Lynx, a text-based browser, that does not render the html page correctly within the terminal of the Gitpod environment. The workaround is to navigate to [https://app.terraform.io/app/settings/tokens?source=terraform-login](https://app.terraform.io/app/settings/tokens?source=terraform-login)
3. Create the API token
4. Copy the API token
5. Quit, `Q`, the Lynx browser
6. Paste the API token after the prompt that asks for the token
7. Execute `ls -lah ~/.terraform.d` & verify the `credentials.tfrc.json` file exists
8. Add the following `cloud` block to any `.tf` file with the appropriate values for `organization` and `workspaces`
```terraform
terraform {
  cloud {
    organization = "organization-name"
    workspaces {
      name = "terra-house-1"
    }
  }
```
9. [Terraform Cloud Documentation for storing the state file remotely](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-remote)

10. In the Terraform Cloud console, in **terra-house-1** workspace, navigate to the **Variables** console
11. Add **Workspace Variables** for **AWS_ACCESS_KEY_ID** and **AWS_SECRET_ACCESS_KEY** and input their respective values from AWS IAM user credentials created earlier. Make sure to select the **Sensitive** option
12. Execute `terraform init` to add the cloud provider
13. Next, execute `terraform plan` to view proposed changes that will be applied to deploying infrastructure
14. Next, execute `terraform apply` to deploy infrastructure
15. Check the **Runs** console within Terraform Cloud to view whether the `terraform plan` or `terraform apply` commands were successful or not
16. If `terraform apply` commands was successful, you can view the state file in the **States** console

### Generate Terraform Cloud credentials file
Since the `.terraform` directory and other similar directories are not being tracked in the version control system, whenever a Gitpod workspace is started, the directories and files, i.e., `~/.terraform.d/credentials.tfrc.json` that were previously created by executing the `terraform login` command are lost. Setting the Terraform Cloud API Token as an environment variable, TERRAFORM_CLOUD_TOKEN, would allow for the implementation of a Bash script to recreate the `~/.terraform.d/credentials.tfrc.json` file, and allow for the Terraform state file to continue to be stored remotely.


## References
[^1]: [Learn more about semantic versioning](http://www.semver.org)
[^2]: [Gitpod documentation](http://gitpod.io/docs/configure/workspaces/tasks)
[^3]: [She-bang](https://en.wikipedia.org/wiki/Shebang_(Unix))
[^4]: [chmod usage and Linux file permissions](https://linuxize.com/post/chmod-command-in-linux/)
