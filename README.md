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
3. Replace Terraform installation instructions in `.gitpod.yml` with those on the Hashicorp website

### Gitpod Lifecycle Considerations
+ We need to be careful using using `init` because it will not rerun commands in that section if an existing workspace is restarted. 
+ Change Gitpod tasks in `.gitpod.yml`, from `init` to `before` so installation occurs everytime new workspace is started.[^2]

### References
[^1]: [Learn more about semantic versioning](http://www.semver.org)
[^2]: [Gitpod documentation](http://gitpod.io/docs/configure/workspaces/tasks)