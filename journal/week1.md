# Terraform Beginner Bootcamp 2023 - week 1

## Standard Module Structure[^1]
```sh
$ tree complete-module/
.
├── README.md
├── main.tf
├── variables.tf
├── outputs.tf
├── ...
├── modules/
│   ├── nestedA/
│   │   ├── README.md
│   │   ├── variables.tf
│   │   ├── main.tf
│   │   ├── outputs.tf
│   ├── nestedB/
│   ├── .../
├── examples/
│   ├── exampleA/
│   │   ├── main.tf
│   ├── exampleB/
│   ├── .../
```

Terraform modules allow you to reuse and share configurations. A Terraform module is a set of Terraform configuration files in a single directory. The standard module structure consists of:

- main.tf - Contains the main Terraform configuration code to create the resources for the module. This may reference other files within the module.

- variables.tf - Defines the input variables that can be passed in to the module. This allows customization of the module.

- outputs.tf - Defines the values that are output from the module. This allows the module to return data to the calling module.

- versions.tf - Constrains the versions of Terraform and providers required by the module. This ensures compatibility. 

- README.md - Provides documentation for using the module. Describes the module, inputs, outputs etc.

- modules/ - Contains any nested modules used by this module.

- examples/ - Provides examples of using the module, including example variables and outputs.

This standard structure makes Terraform modules portable, reusable and maintainable. Modules can encapsulate infrastructure into reusable packages that can be shared and consumed like any other code.

### Terraform and Input Variables

#### -var flag

- This flag allows you to set individual variables via the command line. For example:

`terraform apply -var "instance_type=t2.micro"`

This lets you override a variable value without modifying config files.

#### -var-file flag
- This flag specifies an external variables file for Terraform to load. For example:

`terraform apply -var-file="prod.tfvars"`

This allows you to define reusable groups of variable values.

#### auto.tfvars file

- If this file is present in the current directory, Terraform automatically loads it to populate variables.

auto.tfvars is loaded after terraform.tfvars. It sets default values that can still be overridden.

### Terraform Cloud Variables

Terraform variables and environment variables serve different purposes in Terraform configurations:

Terraform variables (-var, -var-file, .tfvars files) are used to parameterize and customize a Terraform configuration. They allow customizing infrastructure without changing the base Terraform code. Terraform variables are defined and consumed within the Terraform language.

Some examples:

- Defining variable values in terraform.tfvars
- Passing variables via -var flags 
- Setting input variables on modules

Environment variables are used to configure the Terraform CLI behavior and authentication. They are consumed by Terraform itself before running a configuration. 

Some examples:

- TF_LOG - Enables detailed Terraform logging
- AWS_ACCESS_KEY_ID - Sets AWS access key for provider auth
- ARM_CLIENT_SECRET - Authentication for Terraform AzureRM provider

Key differences:

- Terraform vars customize config, env vars configure Terraform CLI 
- Terraform vars defined in TF files, env vars set outside Terraform
- Terraform vars pass data into a config, env vars pass data into Terraform

So in summary, Terraform variables customize configuration while environment variables configure and authenticate the Terraform tool. Both are useful but serve very distinct purposes.

### Loading Terraform Input Variables

- Input variables allow you to parameterize your Terraform configuration. This lets you customize infrastructure without changing code.

- Variables are defined in your Terraform files with variable blocks:
  
```hcl
variable "instance_type" {
  type = string
  default = "t2.micro"
}
```
- Variable types include string, number, boolean, list, map, object, tuple. You can set defaults and mark variables optional/required.

- Simple variables can be passed via the -var command line flag:

`terraform apply -var "instance_type=t2.small"`

- Groups of variables can be defined in .tfvars files like terraform.tfvars. Terraform automatically loads them.

- Modules have input variables defined in variables.tf. You pass values when calling the module.

- Sensitive variables should go in a separate tfvars file that is not committed to source control.

- auto.tfvars can define defaults that are overridable via other variables.

- Unset variables fall back to defaults defined in variable blocks.

- Multiple tfvars files and -var flags can be combined in one command. Later values override earlier ones.

- Environment variables are used for configuring Terraform itself, not passed to your configuration.

Overall, input variables allow full customization of Terraform infrastructure with parameterized configurations.

[Learn more about Inputting variables](https://developer.hashicorp.com/terraform/language/values/variables)

## Addressing Configuration Drift with Terraform Import

Terraform allows importing existing infrastructure into your Terraform state so that it can be managed by Terraform. Here is an overview of how to import infrastructure:

1. Write your Terraform configuration for the infrastructure or resources you want to import. Leave the resource definition empty without any attributes.

2. Run `terraform import` for each resource, specifying the resource address and resource ID:

```
terraform import aws_instance.example i-abcd1234
```
![pic of successful import](../assets/terraform-import-resized.png)

3. Terraform will import the resource and add it to your state file. It will show up in state as "imported".

4. Refresh your state to pull the latest details:

```
terraform refresh
```
![pic of new remote state file](../assets/terraform-new-state.png)
![pic of new remote state file](../assets/terraform-new-state-diff.png)

5. Populate your Terraform resource configuration with the attributes and details now in your state. You can output resources to see their attributes.

6. Now when you run `terraform plan`, it will show any changes needed to match your configuration rather than wanting to create a new resource. 

7. You can proceed with running `terraform apply` and managing the existing infrastructure going forward.

The key is mapping existing infrastructure to empty resource definitions and importing them before populating the configuration. This allows adopting resources not originally created by Terraform.

### How to Remove Managed Resources Without Destroying Them
Here are a few options to remove a resource from Terraform state without destroying it:

- Execute `terraform state list` to display currently managed resources in the state file
- `terraform taint <resource>` - This marks a resource as tainted, meaning it will be destroyed and recreated on the next apply. You can then prevent the destroy by commenting out the resource config or using `-ignore-tainted` on apply. The resource remains intact outside of Terraform.

- `terraform state rm <resource>` - This removes the resource from the Terraform state entirely. It will no longer be managed by Terraform. Use with caution as it could leave orphaned resources.
  - `terraform state rm -dry-run <resource>`[^2] - Displays that the `<resource>` would be removed from the state file without actually executing the action.

- replace provider with null - Replace the provider for that resource with the null provider. Terraform will no longer perform actions on it.

- `ignore_changes` - Add `ignore_changes` lifecycle rule to ignore all changes to the resource. It will remain in state but unmodified.

- Comment out - Simply comment out the resource config. On next apply it will be removed from state without destroy.

## Terraform Modules

- Terraform modules allow you to encapsulate and reuse infrastructure configurations.

- Modules exist as files in a directory structure. This module directory can be stored and shared. 

- The module source refers to where the module code is loaded from when using a module.

- Modules can be sourced from:

  - Local file paths - ./modules/my-module or ../modules/my-module

  - Terraform Registry - registry.terraform.io/namespace/module

  - GitHub - github.com/username/repo//modules/my-module

  - BitBucket - bitbucket.org/username/repo/modules/my-module

  - HTTP URLs - http://example.com/modules/my-module

- The source is specified in your Terraform code when declaring a module:

```hcl
module "terrahouse_aws" {
  source = "./modules/terrahouse_aws"
}
```

- Terraform will download and cache the module code from the source location.

- Using version tags like 1.0.0 in the source URL pins the module to a specific release.

- Module versions allow upgrading module functionality over time.

- Refer to Terraform [docs](https://developer.hashicorp.com/terraform/tutorials/modules/module-create#create-a-module) for guidance on creating a module

### Installing a Module

- When you run `terraform init`, the module code is downloaded to a `modules/` directory in your working directory.

- Updates to modules are installed by re-running `terraform init` or running `terraform get`.

- Installed modules appear in the Terraform dependency graph. Resources defined in modules look like: `module.vpc.aws_subnet.public`

- Input variables allow customizing and parameterizing modules. Set them within your module block:

```hcl
module "vpc" {
  source = "..."
  
  subnet_counts = {
    public = 2 
    private = 3
  }
}
```

- Outputs from modules can be referenced to pass data to other resources.

Overall, modules allow Terraform configurations to be decomposed and packaged into reusable components that can be published, shared, and installed like any other code dependency.

[Terraform Docs on Module Sources](https://developer.hashicorp.com/terraform/language/modules/sources)


## Setting Up S3 Static Web Hosting
+ [Enable](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration) static website hosting by adding `aws_s3_bucket_website_configuration` block
+ configure **index.html** & **error.html** files
  + execute `mkdir public && touch ./public/index.html ./public/error.html`

```sh
# Insert HTML code into index.html
cat <<EOF > ./public/index.html
<!DOCTYPE html>
<html>
<head>
  <title>My Website</title>
</head>
<body>

  <h1>Welcome to my website!</h1>
  
  <p>This is my main page content.</p>
  
</body>
</html>
EOF
```

### Working with Files in Terraform

#### Path Variable

Here is a summary of using Terraform's path functions to manipulate file paths:

- The path functions allow transforming and extracting parts of filesystem paths in Terraform.

- `path.module` returns the filesystem path of the module where the expression is called. Useful for locating files relative to a module.

- `path.root` returns the filesystem path of the root module. Helpful for referencing files relative to the root.

- `path.cwd` returns the current working directory where Terraform was run. Can create paths relative to cwd.

- `path.basename` extracts just the filename from a path. Removes directories.

- `path.dirname` extracts the directory portion of a path without the filename.

- `path.ext` extracts the file extension from a path.

- `path.join` concatenates path segments into a single path. Prevents OS-specific issues.

Example usages:

```
path.module   # /terraform/modules/vpc
path.root     # /terraform/modules 
path.basename(# /terraform/modules/vpc/main.tf) -> main.tf
path.ext(# /terraform/modules/vpc.zip) -> .zip
path.join("data", "users.csv") # data/users.csv
```

Overall, path functions are useful for working with filesystem paths in a portable way. They help locate, parse, and manipulate paths in Terraform code.

## S3 Static Web Hosting continued

+ Setting permissions for website access
  + Step 1: Edit S3 Block Public Access settings by adding `aws_s3_bucket_public_access_block` block, learn more [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block)
  + Step 2: Add a bucket policy, `aws_s3_bucket_policy`
    + Use a bucket policy to grant public read permission to your objects. However, the bucket policy applies only to objects that are owned by the bucket owner. If your bucket contains objects that aren't owned by the bucket owner, the bucket owner should use the object access control list (ACL) to grant public READ permission on those objects. [^3]
  
When the code is correctly implemented, the url for the site will be outputted.

![pic showing S3 static website](../assets/S3-website-success.png)

## References
[^1]: [Learn more about Standard Module Structure](https://developer.hashicorp.com/terraform/language/modules/develop/structure)
[^2]: [Documentation on `terraform state rm` command](https://developer.hashicorp.com/terraform/cli/commands/state/rm)
[^3]: [Object access control lists](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteAccessPermissionsReqd.html#object-acl)
