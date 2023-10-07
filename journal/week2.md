# Terraform Beginner Bootcamp - Week 2

## Ruby
Ruby's package manager, commonly known as RubyGems, is a powerful tool for managing and distributing Ruby libraries (gems). Here's a concise summary of key points when using Ruby's package manager:

1. **Installation**: RubyGems is usually included with Ruby installations. You can check its version by running `gem -v` in your terminal.

2. **Gem Installation**: To install a gem, you can use the `gem install` command followed by the gem's name. For example, `gem install rails` installs the Ruby on Rails gem.

3. **Gemfile**: In Ruby projects, you can define gem dependencies in a `Gemfile`. This file lists the gems your project depends on and their versions. You can then run `bundle install` to install all the gems specified in the Gemfile.

4. **Gem Versions**: Gems often have multiple versions available. You can specify a particular version or a range of versions in your Gemfile to ensure compatibility with your project.

5. **Dependency Resolution**: RubyGems resolves dependencies automatically when installing gems. It ensures that all required gems and their compatible versions are installed.

6. **Updating Gems**: You can update installed gems using the `gem update` command. To update all gems, use `gem update --system`.

7. **Listing Installed Gems**: Use `gem list` to see a list of all installed gems, and `gem list gem_name` to check if a specific gem is installed.

8. **Creating Gems**: You can create your own gems using tools like Bundler's `bundle gem` command. This allows you to package and distribute your Ruby code as a reusable gem.

9. **Publishing Gems**: If you want to share your gem with others, you can publish it to the RubyGems.org repository. Use the `gem push` command after creating an account on RubyGems.org.

10. **Removing Gems**: To uninstall a gem, use `gem uninstall gem_name`. Be cautious when removing gems, as it can affect your application's functionality.

11. **Documentation**: Most gems include documentation. You can view a gem's documentation using the `gem server` command, which starts a local server with gem documentation.

12. **Version Locking**: For stability, it's a good practice to lock gem versions in your Gemfile. This prevents unexpected updates that could introduce breaking changes.

RubyGems simplifies the process of managing and distributing Ruby libraries, making it easier for developers to leverage existing code and share their own. By understanding and effectively using Ruby's package manager, you can streamline your Ruby development workflow and collaborate more efficiently with the Ruby community.

## Sinatra
Sinatra is a minimalistic and lightweight web framework for Ruby that is designed to make it incredibly easy to create web applications and APIs. Here's a concise summary of the key points about Sinatra:

1. **Lightweight**: Sinatra is known for its simplicity and minimalism. It provides just enough structure to build web applications without unnecessary complexity.

2. **DSL (Domain-Specific Language)**: Sinatra uses a clean and intuitive DSL that allows developers to define routes and actions in a straightforward manner. It's easy to understand and quick to get started with.

3. **Modular**: Sinatra applications are often built in a modular fashion. You can create multiple small applications or services within a single Sinatra application, each with its own set of routes and functionality.

4. **Routing**: Sinatra's routing is based on HTTP methods (GET, POST, PUT, DELETE, etc.) and URL patterns. You can define routes using simple patterns and attach corresponding actions to them.

5. **Templates**: Sinatra supports various templating engines such as ERB, Haml, and Slim, making it easy to generate dynamic HTML content.

6. **Middleware**: You can use middleware in Sinatra to add functionality to your application's request-response cycle. Sinatra itself is built on top of Rack, which enables the use of a wide range of middleware components.

7. **RESTful**: Sinatra encourages the creation of RESTful APIs by design. Routes and HTTP methods map directly to resource actions (e.g., GET for reading, POST for creating, PUT for updating, DELETE for deleting).

8. **Extensible**: While Sinatra is minimal by default, you can extend its functionality by using various plugins and adding custom middleware.

9. **Community and Ecosystem**: Sinatra has an active and supportive community. It also benefits from the broader Ruby ecosystem, including libraries and gems that can be integrated into Sinatra applications.

10. **Deployment**: Sinatra applications can be easily deployed to various hosting platforms, making it a versatile choice for deploying web services and microservices.

11. **Learning Curve**: Sinatra's simplicity makes it an excellent choice for beginners or for small projects where a full-fledged web framework might be overkill. It's often used as a learning tool for web development in Ruby.

12. **Scalability**: While Sinatra is well-suited for small to medium-sized applications, it might not be the best choice for large-scale, complex systems, where more extensive frameworks like Ruby on Rails might be preferable.

In summary, Sinatra is a lightweight and easy-to-learn web framework for Ruby that's perfect for quickly building small to medium-sized web applications and APIs. Its simplicity, clear syntax, and modularity make it an excellent choice for developers looking for a straightforward way to get their web projects up and running.

## Setting Up the Mock Server
1. Create a new github issue and a branch associated with same issue
2. Make new directory to house mock server repository, `mkdir terratown_mock_server`
3. Clone the repo that contains the necessary components to implement the Sinatra server, `git clone https://github.com/...`
4. Remove the *.git file from the directory. If the git file is not removed before committing changes, git will interpret the newly imported sub-directory as a module
5. Move the Bash scripts in the terratowns bin directory to the bin directory in the workspace root directory.
   + The Bash scripts will perform Create, Read, Update & Delete operations that will be reflected in the Sinatra server
   + Make the scripts executable using `chmod u+x /path/to/file`
6. The `server.rb` file is configured to run the Sinatra server and handle HTTP requests sent by the respective Bash scripts
7. To start the Sinatra server, navigate to the directory containing the `server.rb` file and execute
   ```sh
   bundle install
   bundle exec ruby server.rb
   ```
8. Tasks were added to the `.gitpod.yml` to automate the compilation of the `server.rb` file and start the Sinatra server

## Implement the Custom Terraform Provider
### Create a Bash script to automate the steps to build the Terraform Provider
1. Sets the `PLUGIN_DIR` variable to a specific directory where Terraform provider plugins are typically located.

2. Changes the current working directory to a location specified by the `PROJECT_ROOT` variable, which is expected to be set elsewhere in the script or environment.

3. Moves a file named `.terraformrc` from the `PROJECT_ROOT` directory to the user's home directory (`$HOME`).

4. Removes two directories: `$HOME/.terraform.d/plugins` and `.terraform` in the `PROJECT_ROOT` directory. This is likely done to clean up any previously installed Terraform plugins and related cache.

5. Removes a file named `.terraform.lock.hcl` in the `PROJECT_ROOT` directory.

6. Compiles a Go binary from the source code located in the `PROJECT_ROOT/terraform-provider-terratowns` directory, naming it `terraform-provider-terratowns_v1.0.0`.

7. Creates two directories (`$PLUGIN_DIR/x86_64` and `$PLUGIN_DIR/linux_amd64`) in the `PLUGIN_DIR` to store the compiled plugin binary for different platforms.

8. Copies the compiled binary `terraform-provider-terratowns_v1.0.0` to both `$PLUGIN_DIR/x86_64` and `$PLUGIN_DIR/linux_amd64`.

In summary, this script, `./bin/build_provider` seems to be involved in managing a Terraform provider plugin for a specific custom provider named "terratowns." It compiles the provider from source code, organizes it in a directory structure for different platforms, and prepares it for use in Terraform configurations. Additionally, it moves the `.terraformrc` file and removes certain cache and lock files as part of the setup process.

### The Custom Terraform Provider
- The custom Terraform provider is written in Golang
- example of installing dependencies: `go get github.com/hashicorp/terraform-plugin-sdk/v2/plugin`

### Terraform Provider Block

## Implement CRUD in the Custom Terraform Provider

## Access to Terratowns
Navigate to [https://terratowns.cloud/](https://terratowns.cloud/)
