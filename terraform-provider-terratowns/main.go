package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"github.com/google/uuid"
	"github.com/hashicorp/terraform-plugin-sdk/v2/diag"
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
	"github.com/hashicorp/terraform-plugin-sdk/v2/plugin"
	"log"
	"net/http"
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

type Config struct {
	Endpoint string
	Token    string
	UserUuid string
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
			"terratowns_home": Resource(),
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
				Sensitive:   true, // Make the token sensitive to hide it in the logs
				Required:    true,
				Description: "Bearer token for authorization",
			},
			"user_uuid": {
				Type:        schema.TypeString,
				Required:    true,
				Description: "UUID for configuration",
				// ValidateFunc is a custom validation function for 'user_uuid'.
				ValidateFunc: validateUUID,
			},
		},
	}
	// Set the ConfigureContextFunc for the provider.
	p.ConfigureContextFunc = providerConfigure(p)
	return p
}

// validateUUID checks if the given value is a valid UUID string.
// It takes an interface{} type value and a key string for reference.
// If the value is not a valid UUID, it appends an error message to the 'errs' slice.
// Returns a slice of warning messages and a slice of errors encountered during validation.
func validateUUID(value interface{}, key string) (warns []string, errs []error) {
	// Log the start of UUID validation
	log.Print("validateUUID:start")

	// Assert that the value is of type string
	val := value.(string)

	// Parse the UUID string, and if there is an error, add it to the 'errs' slice
	if _, err := uuid.Parse(val); err != nil {
		errs = append(errs, fmt.Errorf("invalid UUID format"))
	}

	// Log the end of UUID validation
	log.Print("validateUUID:end")
	return
}

// providerConfigure is a function that creates a ConfigureContextFunc for the provider.
// This function is called during provider configuration and returns a configuration object
// and any diagnostic messages.
func providerConfigure(p *schema.Provider) schema.ConfigureContextFunc {
	return func(ctx context.Context, resource_d *schema.ResourceData) (interface{}, diag.Diagnostics) {
		// Log a message indicating the start of provider configuration.
		log.Print("providerConfigure:start")

		// Create a Config object by extracting configuration values from the ResourceData.
		config := Config{
			Endpoint: resource_d.Get("endpoint").(string),
			Token:    resource_d.Get("token").(string),
			UserUuid: resource_d.Get("user_uuid").(string),
		}

		// Log a message indicating the end of provider configuration.
		log.Print("providerConfigure:end")

		// Return the configuration object and no diagnostics (nil).
		return &config, nil
	}
}

// Resource returns a pointer to a schema.Resource for managing houses.
func Resource() *schema.Resource {
	// Log that the Resource function has started.
	log.Print("Resource:start")

	// Create a new schema.Resource for managing houses.
	resource := &schema.Resource{
		CreateContext: resourceHouseCreate, // Set the create operation context.
		ReadContext:   resourceHouseRead,   // Set the read operation context.
		UpdateContext: resourceHouseUpdate, // Set the update operation context.
		DeleteContext: resourceHouseDelete, // Set the delete operation context.
		Schema: map[string]*schema.Schema{
			"name": {
				Type:        schema.TypeString,
				Required:    true,
				Description: "Name of home",
			},
			"description": {
				Type:        schema.TypeString,
				Required:    true,
				Description: "Description of home",
			},
			"domain_name": {
				Type:        schema.TypeString,
				Required:    true,
				Description: "CloudFront Distribution url",
			},
			"town": {
				Type:        schema.TypeString,
				Required:    true,
				Description: "The town that the home is associated with",
			},
			"content_version": {
				Type:        schema.TypeInt,
				Required:    true,
				Description: "The content version",
			},
		},
	}

	// Log that the Resource function has completed.
	log.Print("Resource:end")

	// Return the created resource for use in Terraform provider.
	return resource
}

// resourceHouseCreate is a Terraform resource creation function.
// It is responsible for creating a new 'house' resource.
func resourceHouseCreate(ctx context.Context, resource_d *schema.ResourceData, m interface{}) diag.Diagnostics {
	log.Print("resourceHouseCreate:start")
	var diags diag.Diagnostics

	config := m.(*Config)

	payload := map[string]interface{}{
		"name":            resource_d.Get("name").(string),
		"description":     resource_d.Get("description").(string),
		"domain_name":     resource_d.Get("domain_name").(string),
		"town":            resource_d.Get("town").(string),
		"content_version": resource_d.Get("content_version").(int),
	}

	payloadBytes, err := json.Marshal(payload)
	if err != nil {
		return diag.FromErr(err)
	}

	url := config.Endpoint + "/u/" + config.UserUuid + "/homes/"
	log.Print("URL: " + url)

	// Construct the HTTP request
	log.Print("Constructing the HTTP request")
	request, err := http.NewRequest("POST", url, bytes.NewBuffer(payloadBytes))
	if err != nil {
		log.Print("Error creating the POST request")
		return diag.FromErr(err)
	}

	// Set Headers
	request.Header.Set("Authorization", "Bearer "+config.Token)
	request.Header.Set("Content-Type", "application/json")
	request.Header.Set("Accept", "application/json")

	log.Print("HTTP request sent, awaiting response")
	client := &http.Client{}
	response, err := client.Do(request)
	if err != nil {
		log.Print("Error to the POST request")
		return diag.FromErr(err)
	}

	defer response.Body.Close()

	var responseData map[string]interface{}
	if err := json.NewDecoder(response.Body).Decode(&responseData); err != nil {
		return diag.FromErr(err)
	}

	if response.StatusCode != http.StatusOK {
		return diag.FromErr(fmt.Errorf("failed to create home resource, status_code: %d, status: %s, body %s", response.StatusCode, response.Status, responseData))
	}

	homeUUID := responseData["uuid"].(string)
	resource_d.SetId(homeUUID)

	log.Print("resourceHouseCreate:end")
	return diags
}

// resourceHouseRead is a Terraform resource reading function.
// It is responsible for reading the state of an existing 'house' resource.
func resourceHouseRead(ctx context.Context, resource_d *schema.ResourceData, m interface{}) diag.Diagnostics {
	log.Print("resourceHouseRead:start")

	var diags diag.Diagnostics

	config := m.(*Config)

	homeUUID := resource_d.Id()

	url := config.Endpoint + "/u/" + config.UserUuid + "/homes/" + homeUUID
	log.Print("URL: " + url)

	// Construct the HTTP request

	request, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return diag.FromErr(err)
	}

	// Set Headers
	request.Header.Set("Authorization", "Bearer "+config.Token)
	request.Header.Set("Content-Type", "application/json")
	request.Header.Set("Accept", "application/json")

	client := http.Client{}
	response, err := client.Do(request)
	if err != nil {
		return diag.FromErr(err)
	}

	defer response.Body.Close()

	var responseData map[string]interface{}

	// StatusOK = 200 HTTP Response Code
	if response.StatusCode == http.StatusOK {
		// parse response JSON
		if err := json.NewDecoder(response.Body).Decode(&responseData); err != nil {
			return diag.FromErr(err)
		}
		resource_d.Set("name", responseData["name"].(string))
		resource_d.Set("description", responseData["description"].(string))
		resource_d.Set("domain_name", responseData["domain_name"].(string))
		resource_d.Set("content_version", responseData["content_version"].(float64))
	} else if response.StatusCode == http.StatusNotFound {
		resource_d.SetId("")
	} else if response.StatusCode != http.StatusOK {
		return diag.FromErr(fmt.Errorf("failed to read home resource, status_code: %d, status: %s, body %s", response.StatusCode, response.Status, responseData))
	}

	log.Print("resourceHouseRead:end")

	return diags
}

// resourceHouseUpdate is a Terraform resource update function.
// It is responsible for updating the state of an existing 'house' resource.
func resourceHouseUpdate(ctx context.Context, resource_d *schema.ResourceData, m interface{}) diag.Diagnostics {
	log.Print("resourceHouseUpdate:start")
	var diags diag.Diagnostics

	config := m.(*Config)

	homeUUID := resource_d.Id()
	payload := map[string]interface{}{
		"name":            resource_d.Get("name").(string),
		"description":     resource_d.Get("description").(string),
		"content_version": resource_d.Get("content_version").(float64),
	}

	payloadBytes, err := json.Marshal(payload)
	if err != nil {
		return diag.FromErr(err)
	}

	url := config.Endpoint + "/u/" + config.UserUuid + "/homes/" + homeUUID
	log.Print("URL: " + url)

	// Construct the HTTP request
	request, err := http.NewRequest("PUT", url, bytes.NewBuffer(payloadBytes))
	if err != nil {
		return diag.FromErr(err)
	}

	// Set Headers
	request.Header.Set("Authorization", "Bearer "+config.Token)
	request.Header.Set("Content-Type", "application/json")
	request.Header.Set("Accept", "application/json")

	client := http.Client{}
	response, err := client.Do(request)
	if err != nil {
		return diag.FromErr(err)
	}

	defer response.Body.Close()

	var responseData map[string]interface{}
	if err := json.NewDecoder(response.Body).Decode(&responseData); err != nil {
		return diag.FromErr(err)
	}

	if response.StatusCode != http.StatusOK {
		return diag.FromErr(fmt.Errorf("failed to update home resource, status_code: %d, status: %s, body: %s", response.StatusCode, response.Status, responseData))
	}

	// homeUUID = responseData["uuid"].(string)

	resource_d.SetId(responseData["uuid"].(string))

	log.Print("resourceHouseUpdate:end")

	resource_d.Set("name", payload["name"])
	resource_d.Set("description", payload["description"])
	resource_d.Set("content_version", payload["content_version"])

	return diags
}

// resourceHouseDelete is a Terraform resource deletion function.
// It is responsible for deleting an existing 'house' resource.
func resourceHouseDelete(ctx context.Context, resource_d *schema.ResourceData, m interface{}) diag.Diagnostics {
	log.Print("resourceHouseDelete:start")
	var diags diag.Diagnostics

	config := m.(*Config)

	homeUUID := resource_d.Id()

	var url = config.Endpoint + "/u/" + config.UserUuid + "/homes/" + homeUUID
	log.Print("URL: " + url)

	// Construct the HTTP request
	request, err := http.NewRequest("DELETE", url, nil)
	if err != nil {
		return diag.FromErr(err)
	}

	// Set Headers
	request.Header.Set("Authorization", "Bearer "+config.Token)
	request.Header.Set("Content-Type", "application/json")
	request.Header.Set("Accept", "application/json")

	client := http.Client{}
	response, err := client.Do(request)
	if err != nil {
		return diag.FromErr(err)
	}

	defer response.Body.Close()

	resource_d.SetId("")

	log.Print("resourceHouseDelete:end")
	return diags
}
