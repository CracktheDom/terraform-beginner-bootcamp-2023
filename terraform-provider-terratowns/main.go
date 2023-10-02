package main

import (
	"fmt"
	// "log"
	"github.com/hashicorp/terraform-plugin-sdk/v2/plugin"
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
	// "github.com/google/uuid"
)

// main is the entry point of the Go program.
func main() {
	// ServeOpts is a struct containing configuration options for serving the Terraform plugin.
	// In this case, we provide a ProviderFunc that should be implemented elsewhere.
	plugin.Serve(&plugin.ServeOpts{
		ProviderFunc: Provider, // ProviderFunc is a function to create and configure the Terraform provider.
	})

	// Print "Hello, World!" to the console.
	fmt.Println("Hello, World!")
}

// Provider returns a Terraform schema.Provider that allows Terraform to manage
// resources and data sources related to an external service.
func Provider() *schema.Provider {
	// Initialize a pointer to a schema.Provider.
	var p *schema.Provider
	// Create a new schema.Provider and assign it to the pointer 'p'.
	p = &schema.Provider{
		// Define the resources that this provider manages.
		ResourcesMap: map[string]*schema.Resource{
			// "terratowns_home": Resource(),
		},
		// Define the data sources that this provider supports.
		DataSourcesMap: map[string]*schema.Resource{},
		// Define the configuration schema for this provider.
		Schema: map[string]*schema.Schema{
			"endpoint": {
				Type:        schema.TypeString,
				Required:    true,
				Description: "The endpoint for the external service",
			},
			"token": {
				Type:        schema.TypeString,
				Sensitive:   true, // Make the token as sensitive to hide it in the logs
				Required:    true,
				Description: "Bearer token for authorization",
			},
			"user_uuid": {
				Type:        schema.TypeString,
				Required:    true,
				Description: "UUID for configuration",
				// ValidateFunc is a custom validation function for 'user_uuid'.
				// ValidateFunc: validateUUID,
			},
		},
	}
	// Set the ConfigureContextFunc for the provider.
	// p.ConfigureContextFunc = providerConfigure(p)
	return p
}

// validateUUID checks if the given value is a valid UUID string.
// It takes an interface{} type value and a key string for reference.
// If the value is not a valid UUID, it appends an error message to the 'errs' slice.
// Returns a slice of warning messages and a slice of errors encountered during validation.
// func validateUUID(value interface{}, key string) (warns []string, errs []error) {
// 	// Log the start of UUID validation
// 	log.Print("validateUUID:start")
	
// 	// Assert that the value is of type string
// 	val := value.(string)
	
// 	// Parse the UUID string, and if there is an error, add it to the 'errs' slice
// 	if _, err := uuid.Parse(val); err != nil {
// 		errs = append(errs, fmt.Errorf("invalid UUID format"))
// 	}
	
// 	// Log the end of UUID validation
// 	log.Print("validateUUID:end")
// }
