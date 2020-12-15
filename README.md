# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
This project using terraform template and packer for building VM image will result in producing a high availability web server in Microsoft Azure.

Terraform deployments can be customized by editing variables default values directly in the file vars.tf or submitting other values with terraform apply command as follows:

terraform apply -var="system=terraformdemo" -var="location=eastus"

### Getting Started
1. Clone this repository

2. Create your infrastructure as code

3. Update this README to reflect how someone would use your code.

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions

1. Make sure the following environment variables are set and correspond to your azure account details:
- ARM_CLIENT_ID
- ARM_CLIENT_SECRET
- ARM_SUBSCRIPTION_ID
- ARM_TENANT_ID

2. Navigate to the directory containing the .tf and .json files

3. Create the VM image using packer.
Note: The the Resource Group set in server.json (managed_image_resource_group_name) must exist prior to executing packer build command. You can check that by executing:
- az group exists -n <resource-group-name> 
or list all existing groups:
- az group list
If necessary, create the resource group manually:
(Location parameter shall correspond to location property in server.json / all lowercase no space between, e.g. West Europe in server.json corresponds to --location westeurope on CLI)
- az group create --name <resource-group-name> --location <your-location> 

- packer build server.json

4. Create tagging policy definition as defined in tagging-policy-rule.json and assign this to the subscription by running the bash script tagging-policy-create.sh

First make the script executable:
- chmod +x tagging-policy-create.sh 

Execute the script:
- ./tagging-policy-create.sh

5. Deploy the scalable web server by executing the following commands:
- terraform init

Import resource group created in step 3 to terraform state and provide VM user password when prompted:
- terraform import azurerm_resource_group.main /subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/<resource-group-name>

Dry run the deployment and save it to a file "solution.plan"
- terraform plan -out solution.plan
    - provide VM users password when prompted

Deploy the resources
- terraform apply "solution.plan"

6. To destroy resources when finished execute from the same directory:
Provide VM users password when prompted and confirm destruction by typing "yes"

- terraform destroy 

### Output
Below are listed some examples after executing the corresponding steps from Instructions.

3. a) Example output after creation of resource group via CLI: 

~/udacity/azure-course/project1> az group create --name udacity-azure-course-project1-iac-rg --location westeurope

{
  "id": "/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg",
  "location": "westeurope",
  "managedBy": null,
  "name": "udacity-azure-course-project1-iac-rg",
  "properties": {
    "provisioningState": "Succeeded"
  },
  "tags": null,
  "type": "Microsoft.Resources/resourceGroups"
} 

3. a) Example output for checking existence of resource group:

~/udacity/azure-course/project1> az group exists -n udacity-azure-course-project1-iac
false

3. b) Example output for VM image building command (took 7m 42):

 ~/udacity/azure-course/project1> packer build server.json

azure-arm: output will be in this color.
==> azure-arm: Running builder ...
==> azure-arm: Getting tokens using client secret
==> azure-arm: Getting tokens using client secret
    azure-arm: Creating Azure Resource Manager (ARM) client ...
==> azure-arm: WARNING: Zone resiliency may not be supported in West Europe, checkout the docs at https://docs.microsoft.com/en-us/azure/availability-zones/
==> azure-arm: Creating resource group ...
==> azure-arm:  -> ResourceGroupName : 'pkr-Resource-Group-p1cr2b43ir'
==> azure-arm:  -> Location          : 'West Europe'
==> azure-arm:  -> Tags              :
==> azure-arm:  ->> project_name : IaC
==> azure-arm:  ->> stage : Submission
==> azure-arm: Validating deployment template ...
==> azure-arm:  -> ResourceGroupName : 'pkr-Resource-Group-p1cr2b43ir'
==> azure-arm:  -> DeploymentName    : 'pkrdpp1cr2b43ir'
==> azure-arm: Deploying deployment template ...
==> azure-arm:  -> ResourceGroupName : 'pkr-Resource-Group-p1cr2b43ir'
==> azure-arm:  -> DeploymentName    : 'pkrdpp1cr2b43ir'
==> azure-arm:
==> azure-arm: Getting the VM's IP address ...
==> azure-arm:  -> ResourceGroupName   : 'pkr-Resource-Group-p1cr2b43ir'
==> azure-arm:  -> PublicIPAddressName : 'pkripp1cr2b43ir'
==> azure-arm:  -> NicName             : 'pkrnip1cr2b43ir'
==> azure-arm:  -> Network Connection  : 'PublicEndpoint'
==> azure-arm:  -> IP Address          : '20.73.6.254'
==> azure-arm: Waiting for SSH to become available...
==> azure-arm: Connected to SSH!
==> azure-arm: Provisioning with shell script: /var/folders/0m/1vdj4kkn7_g2t9gmtq5z3gtr0000gn/T/packer-shell104191323
==> azure-arm: + echo Hello, World!
==> azure-arm: + nohup busybox httpd -f -p 80
==> azure-arm: Querying the machine's properties ...
==> azure-arm:  -> ResourceGroupName : 'pkr-Resource-Group-p1cr2b43ir'
==> azure-arm:  -> ComputeName       : 'pkrvmp1cr2b43ir'
==> azure-arm:  -> Managed OS Disk   : '/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/pkr-Resource-Group-p1cr2b43ir/providers/Microsoft.Compute/disks/pkrosp1cr2b43ir'
==> azure-arm: Querying the machine's additional disks properties ...
==> azure-arm:  -> ResourceGroupName : 'pkr-Resource-Group-p1cr2b43ir'
==> azure-arm:  -> ComputeName       : 'pkrvmp1cr2b43ir'
==> azure-arm: Powering off machine ...
==> azure-arm:  -> ResourceGroupName : 'pkr-Resource-Group-p1cr2b43ir'
==> azure-arm:  -> ComputeName       : 'pkrvmp1cr2b43ir'
==> azure-arm: Capturing image ...
==> azure-arm:  -> Compute ResourceGroupName : 'pkr-Resource-Group-p1cr2b43ir'
==> azure-arm:  -> Compute Name              : 'pkrvmp1cr2b43ir'
==> azure-arm:  -> Compute Location          : 'West Europe'
==> azure-arm:  -> Image ResourceGroupName   : 'udacity-azure-course-project1-iac-rg'
==> azure-arm:  -> Image Name                : 'Ubuntu1804Image'
==> azure-arm:  -> Image Location            : 'West Europe'
==> azure-arm: Removing the created Deployment object: 'pkrdpp1cr2b43ir'
==> azure-arm: 
==> azure-arm: Cleanup requested, deleting resource group ...
==> azure-arm: Resource group has been deleted.
Build 'azure-arm' finished after 7 minutes 39 seconds.

==> Wait completed after 7 minutes 39 seconds

==> Builds finished. The artifacts of successful builds are:
--> azure-arm: Azure.ResourceManagement.VMImage:

OSType: Linux
ManagedImageResourceGroupName: udacity-azure-course-project1-iac-rg
ManagedImageName: Ubuntu1804Image
ManagedImageId: /subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Compute/images/Ubuntu1804Image
ManagedImageLocation: West Europe

4. a) Example output: Importing existing resource group to terraform state:

~/udacity/azure-course/project1  terraform import azurerm_resource_group.main /subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/udacity-azure-course-project1-iac-rg 

var.password
  The VM users password:
  Enter a value: ********

azurerm_resource_group.main: Importing from ID "/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg"...
azurerm_resource_group.main: Import prepared!
  Prepared azurerm_resource_group for import
azurerm_resource_group.main: Refreshing state... [id=/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg]

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.

4. b) Example output after executing tagging-policy-create.sh script:

~/udacity/azure-course/project1> ./tagging-policy-create.sh

{
  "description": "This policy denies deployment of new Resource unless at least one tag is created.",
  "displayName": "Deny creation of Resources with no tags",
  "id": "/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/providers/Microsoft.Authorization/policyDefinitions/tagging-policy",
  "metadata": {
    "createdBy": "64c322a0-fa29-41f9-bc3a-6351ce317971",
    "createdOn": "2020-12-15T14:07:37.3167553Z",
    "updatedBy": null,
    "updatedOn": null
  },
  "mode": "Indexed",
  "name": "tagging-policy",
  "parameters": null,
  "policyRule": {
    "if": {
      "allOf": [
        {
          "equals": "true",
          "value": "[empty(field('tags'))]"
        }
      ]
    },
    "then": {
      "effect": "deny"
    }
  },
  "policyType": "Custom",
  "type": "Microsoft.Authorization/policyDefinitions"
}
{
  "description": null,
  "displayName": "Assignment of tagging-policy to all Resources in the subscription.",
  "enforcementMode": "Default",
  "id": "/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/providers/Microsoft.Authorization/policyAssignments/tagging-policy-assignment",
  "identity": null,
  "location": null,
  "metadata": {
    "createdBy": "64c322a0-fa29-41f9-bc3a-6351ce317971",
    "createdOn": "2020-12-15T14:07:39.271325Z",
    "updatedBy": null,
    "updatedOn": null
  },
  "name": "tagging-policy-assignment",
  "notScopes": null,
  "parameters": null,
  "policyDefinitionId": "/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/providers/Microsoft.Authorization/policyDefinitions/tagging-policy",
  "scope": "/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef",
  "sku": {
    "name": "A0",
    "tier": "Free"
  },
  "type": "Microsoft.Authorization/policyAssignments"
}


5. b) Example output after executing the terraform plan command (took 16s):

~/udacity/azure-course/project1> terraform plan -out solution.plan

var.password
  The VM users password:
  Enter a value: *********

azurerm_resource_group.main: Refreshing state... [id=/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg]

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create
  ~ update in-place

Terraform will perform the following actions:

  # azurerm_availability_set.main will be created
  + resource "azurerm_availability_set" "main" {
      + id                           = (known after apply)
      + location                     = "westeurope"
      + managed                      = true
      + name                         = "udacity-azure-course-project1-iac-as"
      + platform_fault_domain_count  = 3
      + platform_update_domain_count = 5
      + resource_group_name          = "udacity-azure-course-project1-iac-rg"
      + tags                         = {
          + "project_name" = "IaC"
          + "stage"        = "Submission"
        }
    }

  # azurerm_lb.main will be created
  + resource "azurerm_lb" "main" {
      + id                   = (known after apply)
      + location             = "westeurope"
      + name                 = "udacity-azure-course-project1-iac-lb"
      + private_ip_address   = (known after apply)
      + private_ip_addresses = (known after apply)
      + resource_group_name  = "udacity-azure-course-project1-iac-rg"
      + sku                  = "Basic"
      + tags                 = {
          + "project_name" = "IaC"
          + "stage"        = "Submission"
        }

      + frontend_ip_configuration {
          + id                            = (known after apply)
          + inbound_nat_rules             = (known after apply)
          + load_balancer_rules           = (known after apply)
          + name                          = "PublicIPAddress"
          + outbound_rules                = (known after apply)
          + private_ip_address            = (known after apply)
          + private_ip_address_allocation = (known after apply)
          + private_ip_address_version    = "IPv4"
          + public_ip_address_id          = (known after apply)
          + public_ip_prefix_id           = (known after apply)
          + subnet_id                     = (known after apply)
        }
    }

  # azurerm_lb_backend_address_pool.main will be created
  + resource "azurerm_lb_backend_address_pool" "main" {
      + backend_ip_configurations = (known after apply)
      + id                        = (known after apply)
      + load_balancing_rules      = (known after apply)
      + loadbalancer_id           = (known after apply)
      + name                      = "BackEndAddressPool"
      + resource_group_name       = "udacity-azure-course-project1-iac-rg"
    }

  # azurerm_linux_virtual_machine.main[0] will be created
  + resource "azurerm_linux_virtual_machine" "main" {
      + admin_password                  = (sensitive value)
      + admin_username                  = "eduard"
      + allow_extension_operations      = true
      + computer_name                   = (known after apply)
      + disable_password_authentication = false
      + extensions_time_budget          = "PT1H30M"
      + id                              = (known after apply)
      + location                        = "westeurope"
      + max_bid_price                   = -1
      + name                            = "udacity-azure-course-project1-iac-vm-0"
      + network_interface_ids           = (known after apply)
      + priority                        = "Regular"
      + private_ip_address              = (known after apply)
      + private_ip_addresses            = (known after apply)
      + provision_vm_agent              = true
      + public_ip_address               = (known after apply)
      + public_ip_addresses             = (known after apply)
      + resource_group_name             = "udacity-azure-course-project1-iac-rg"
      + size                            = "Standard_D2s_v3"
      + source_image_id                 = "/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Compute/images/Ubuntu1804Image"
      + tags                            = {
          + "project_name" = "IaC"
          + "stage"        = "Submission"
        }
      + virtual_machine_id              = (known after apply)
      + zone                            = (known after apply)

      + os_disk {
          + caching                   = "ReadWrite"
          + disk_size_gb              = (known after apply)
          + name                      = (known after apply)
          + storage_account_type      = "Standard_LRS"
          + write_accelerator_enabled = false
        }
    }

  # azurerm_linux_virtual_machine.main[1] will be created
  + resource "azurerm_linux_virtual_machine" "main" {
      + admin_password                  = (sensitive value)
      + admin_username                  = "eduard"
      + allow_extension_operations      = true
      + computer_name                   = (known after apply)
      + disable_password_authentication = false
      + extensions_time_budget          = "PT1H30M"
      + id                              = (known after apply)
      + location                        = "westeurope"
      + max_bid_price                   = -1
      + name                            = "udacity-azure-course-project1-iac-vm-1"
      + network_interface_ids           = (known after apply)
      + priority                        = "Regular"
      + private_ip_address              = (known after apply)
      + private_ip_addresses            = (known after apply)
      + provision_vm_agent              = true
      + public_ip_address               = (known after apply)
      + public_ip_addresses             = (known after apply)
      + resource_group_name             = "udacity-azure-course-project1-iac-rg"
      + size                            = "Standard_D2s_v3"
      + source_image_id                 = "/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Compute/images/Ubuntu1804Image"
      + tags                            = {
          + "project_name" = "IaC"
          + "stage"        = "Submission"
        }
      + virtual_machine_id              = (known after apply)
      + zone                            = (known after apply)

      + os_disk {
          + caching                   = "ReadWrite"
          + disk_size_gb              = (known after apply)
          + name                      = (known after apply)
          + storage_account_type      = "Standard_LRS"
          + write_accelerator_enabled = false
        }
    }

  # azurerm_managed_disk.main will be created
  + resource "azurerm_managed_disk" "main" {
      + create_option        = "Empty"
      + disk_iops_read_write = (known after apply)
      + disk_mbps_read_write = (known after apply)
      + disk_size_gb         = 1
      + id                   = (known after apply)
      + location             = "westeurope"
      + name                 = "udacity-azure-course-project1-iac-md"
      + resource_group_name  = "udacity-azure-course-project1-iac-rg"
      + source_uri           = (known after apply)
      + storage_account_type = "Standard_LRS"
      + tags                 = {
          + "project_name" = "IaC"
          + "stage"        = "Submission"
        }
    }

  # azurerm_network_interface.main[0] will be created
  + resource "azurerm_network_interface" "main" {
      + applied_dns_servers           = (known after apply)
      + dns_servers                   = (known after apply)
      + enable_accelerated_networking = false
      + enable_ip_forwarding          = false
      + id                            = (known after apply)
      + internal_dns_name_label       = (known after apply)
      + internal_domain_name_suffix   = (known after apply)
      + location                      = "westeurope"
      + mac_address                   = (known after apply)
      + name                          = "udacity-azure-course-project1-iac-nic-0"
      + private_ip_address            = (known after apply)
      + private_ip_addresses          = (known after apply)
      + resource_group_name           = "udacity-azure-course-project1-iac-rg"
      + tags                          = {
          + "project_name" = "IaC"
          + "stage"        = "Submission"
        }
      + virtual_machine_id            = (known after apply)

      + ip_configuration {
          + name                          = "main"
          + primary                       = (known after apply)
          + private_ip_address            = (known after apply)
          + private_ip_address_allocation = "dynamic"
          + private_ip_address_version    = "IPv4"
          + subnet_id                     = (known after apply)
        }
    }

  # azurerm_network_interface.main[1] will be created
  + resource "azurerm_network_interface" "main" {
      + applied_dns_servers           = (known after apply)
      + dns_servers                   = (known after apply)
      + enable_accelerated_networking = false
      + enable_ip_forwarding          = false
      + id                            = (known after apply)
      + internal_dns_name_label       = (known after apply)
      + internal_domain_name_suffix   = (known after apply)
      + location                      = "westeurope"
      + mac_address                   = (known after apply)
      + name                          = "udacity-azure-course-project1-iac-nic-1"
      + private_ip_address            = (known after apply)
      + private_ip_addresses          = (known after apply)
      + resource_group_name           = "udacity-azure-course-project1-iac-rg"
      + tags                          = {
          + "project_name" = "IaC"
          + "stage"        = "Submission"
        }
      + virtual_machine_id            = (known after apply)

      + ip_configuration {
          + name                          = "main"
          + primary                       = (known after apply)
          + private_ip_address            = (known after apply)
          + private_ip_address_allocation = "dynamic"
          + private_ip_address_version    = "IPv4"
          + subnet_id                     = (known after apply)
        }
    }

  # azurerm_network_security_group.main will be created
  + resource "azurerm_network_security_group" "main" {
      + id                  = (known after apply)
      + location            = "westeurope"
      + name                = "udacity-azure-course-project1-iac-nsg"
      + resource_group_name = "udacity-azure-course-project1-iac-rg"
      + security_rule       = [
          + {
              + access                                     = "Allow"
              + description                                = ""
              + destination_address_prefix                 = "VirtualNetwork"
              + destination_address_prefixes               = []
              + destination_application_security_group_ids = []
              + destination_port_range                     = "*"
              + destination_port_ranges                    = []
              + direction                                  = "Inbound"
              + name                                       = "AllowInboundSameSubnetVms"
              + priority                                   = 110
              + protocol                                   = "*"
              + source_address_prefix                      = "VirtualNetwork"
              + source_address_prefixes                    = []
              + source_application_security_group_ids      = []
              + source_port_range                          = "*"
              + source_port_ranges                         = []
            },
          + {
              + access                                     = "Allow"
              + description                                = ""
              + destination_address_prefix                 = "VirtualNetwork"
              + destination_address_prefixes               = []
              + destination_application_security_group_ids = []
              + destination_port_range                     = "*"
              + destination_port_ranges                    = []
              + direction                                  = "Outbound"
              + name                                       = "AllowOutboundSameSubnetVms"
              + priority                                   = 100
              + protocol                                   = "*"
              + source_address_prefix                      = "VirtualNetwork"
              + source_address_prefixes                    = []
              + source_application_security_group_ids      = []
              + source_port_range                          = "*"
              + source_port_ranges                         = []
            },
          + {
              + access                                     = "Deny"
              + description                                = ""
              + destination_address_prefix                 = "*"
              + destination_address_prefixes               = []
              + destination_application_security_group_ids = []
              + destination_port_range                     = "*"
              + destination_port_ranges                    = []
              + direction                                  = "Inbound"
              + name                                       = "DenyInboundInternet"
              + priority                                   = 120
              + protocol                                   = "*"
              + source_address_prefix                      = "Internet"
              + source_address_prefixes                    = []
              + source_application_security_group_ids      = []
              + source_port_range                          = "*"
              + source_port_ranges                         = []
            },
        ]
      + tags                = {
          + "project_name" = "IaC"
          + "stage"        = "Submission"
        }
    }

  # azurerm_public_ip.main will be created
  + resource "azurerm_public_ip" "main" {
      + allocation_method       = "Static"
      + fqdn                    = (known after apply)
      + id                      = (known after apply)
      + idle_timeout_in_minutes = 4
      + ip_address              = (known after apply)
      + ip_version              = "IPv4"
      + location                = "westeurope"
      + name                    = "udacity-azure-course-project1-iac-ip"
      + resource_group_name     = "udacity-azure-course-project1-iac-rg"
      + sku                     = "Basic"
      + tags                    = {
          + "project_name" = "IaC"
          + "stage"        = "Submission"
        }
    }

  # azurerm_resource_group.main will be updated in-place
  ~ resource "azurerm_resource_group" "main" {
        id       = "/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg"
        name     = "udacity-azure-course-project1-iac-rg"
      ~ tags     = {
          + "project_name" = "IaC"
          + "stage"        = "Submission"
        }
        # (1 unchanged attribute hidden)

        # (1 unchanged block hidden)
    }

  # azurerm_subnet.main will be created
  + resource "azurerm_subnet" "main" {
      + address_prefix                                 = (known after apply)
      + address_prefixes                               = [
          + "10.0.1.0/24",
        ]
      + enforce_private_link_endpoint_network_policies = false
      + enforce_private_link_service_network_policies  = false
      + id                                             = (known after apply)
      + name                                           = "udacity-azure-course-project1-iac-subnet1"
      + resource_group_name                            = "udacity-azure-course-project1-iac-rg"
      + virtual_network_name                           = "udacity-azure-course-project1-iac-nw"
    }

  # azurerm_virtual_network.main will be created
  + resource "azurerm_virtual_network" "main" {
      + address_space         = [
          + "10.0.0.0/16",
        ]
      + guid                  = (known after apply)
      + id                    = (known after apply)
      + location              = "westeurope"
      + name                  = "udacity-azure-course-project1-iac-nw"
      + resource_group_name   = "udacity-azure-course-project1-iac-rg"
      + subnet                = (known after apply)
      + tags                  = {
          + "project_name" = "IaC"
          + "stage"        = "Submission"
        }
      + vm_protection_enabled = false
    }

Plan: 12 to add, 1 to change, 0 to destroy.

------------------------------------------------------------------------

This plan was saved to: solution.plan

To perform exactly these actions, run the following command to apply:
    terraform apply "solution.plan"



5. c) Example output after deploying the resources via terraform apply:

~/udacity/azure-course/project1> terraform apply "solution.plan

azurerm_resource_group.main: Modifying... [id=/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg]
azurerm_resource_group.main: Modifications complete after 1s [id=/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg]
azurerm_availability_set.main: Creating...
azurerm_managed_disk.main: Creating...
azurerm_virtual_network.main: Creating...
azurerm_public_ip.main: Creating...
azurerm_network_security_group.main: Creating...
azurerm_availability_set.main: Creation complete after 2s [id=/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Compute/availabilitySets/udacity-azure-course-project1-iac-as]
azurerm_public_ip.main: Creation complete after 4s [id=/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Network/publicIPAddresses/udacity-azure-course-project1-iac-ip]
azurerm_lb.main: Creating...
azurerm_managed_disk.main: Creation complete after 4s [id=/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Compute/disks/udacity-azure-course-project1-iac-md]
azurerm_network_security_group.main: Creation complete after 5s [id=/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Network/networkSecurityGroups/udacity-azure-course-project1-iac-nsg]
azurerm_virtual_network.main: Creation complete after 5s [id=/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Network/virtualNetworks/udacity-azure-course-project1-iac-nw]
azurerm_subnet.main: Creating...
azurerm_lb.main: Creation complete after 2s [id=/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Network/loadBalancers/udacity-azure-course-project1-iac-lb]
azurerm_lb_backend_address_pool.main: Creating...
azurerm_lb_backend_address_pool.main: Creation complete after 1s [id=/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Network/loadBalancers/udacity-azure-course-project1-iac-lb/backendAddressPools/BackEndAddressPool]
azurerm_subnet.main: Creation complete after 5s [id=/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Network/virtualNetworks/udacity-azure-course-project1-iac-nw/subnets/udacity-azure-course-project1-iac-subnet1]
azurerm_network_interface.main[0]: Creating...
azurerm_network_interface.main[1]: Creating...
azurerm_network_interface.main[1]: Creation complete after 2s [id=/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Network/networkInterfaces/udacity-azure-course-project1-iac-nic-1]
azurerm_network_interface.main[0]: Creation complete after 3s [id=/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Network/networkInterfaces/udacity-azure-course-project1-iac-nic-0]
azurerm_linux_virtual_machine.main[1]: Creating...
azurerm_linux_virtual_machine.main[0]: Creating...
azurerm_linux_virtual_machine.main[1]: Still creating... [10s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [10s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [21s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [21s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [31s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [31s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [41s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [41s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [51s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [51s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [1m1s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [1m1s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [1m11s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [1m11s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [1m21s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [1m21s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [1m31s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [1m31s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [1m41s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [1m41s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [1m51s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [1m51s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [2m1s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [2m1s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [2m11s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [2m11s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [2m21s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [2m21s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [2m31s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [2m31s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [2m41s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [2m41s elapsed]
azurerm_linux_virtual_machine.main[1]: Creation complete after 2m50s [id=/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Compute/virtualMachines/udacity-azure-course-project1-iac-vm-1]
azurerm_linux_virtual_machine.main[0]: Still creating... [2m51s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [3m1s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [3m11s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [3m21s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [3m31s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [3m41s elapsed]
azurerm_linux_virtual_machine.main[0]: Creation complete after 3m49s [id=/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Compute/virtualMachines/udacity-azure-course-project1-iac-vm-0]

Apply complete! Resources: 12 added, 1 changed, 0 destroyed.

The state of your infrastructure has been saved to the path
below. This state is required to modify and destroy your
infrastructure, so keep it safe. To inspect the complete state
use the `terraform show` command.

State path: terraform.tfstate


6. Example output after destroying resources with terraform:

~/udacity/azure-course/project1> terraform destroy
var.password
  The VM users password:
  Enter a value: ********

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # azurerm_availability_set.main will be destroyed
  - resource "azurerm_availability_set" "main" {
      - id                           = "/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Compute/availabilitySets/udacity-azure-course-project1-iac-as" -> null
      - location                     = "westeurope" -> null
      - managed                      = true -> null
      - name                         = "udacity-azure-course-project1-iac-as" -> null
      - platform_fault_domain_count  = 3 -> null
      - platform_update_domain_count = 5 -> null
      - resource_group_name          = "udacity-azure-course-project1-iac-rg" -> null
      - tags                         = {
          - "project_name" = "IaC"
          - "stage"        = "Submission"
        } -> null
    }

  # azurerm_lb.main will be destroyed
  - resource "azurerm_lb" "main" {
      - id                   = "/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Network/loadBalancers/udacity-azure-course-project1-iac-lb" -> null
      - location             = "westeurope" -> null
      - name                 = "udacity-azure-course-project1-iac-lb" -> null
      - private_ip_addresses = [] -> null
      - resource_group_name  = "udacity-azure-course-project1-iac-rg" -> null
      - sku                  = "Basic" -> null
      - tags                 = {
          - "project_name" = "IaC"
          - "stage"        = "Submission"
        } -> null

      - frontend_ip_configuration {
          - id                            = "/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Network/loadBalancers/udacity-azure-course-project1-iac-lb/frontendIPConfigurations/PublicIPAddress" -> null
          - inbound_nat_rules             = [] -> null
          - load_balancer_rules           = [] -> null
          - name                          = "PublicIPAddress" -> null
          - outbound_rules                = [] -> null
          - private_ip_address_allocation = "Dynamic" -> null
          - private_ip_address_version    = "IPv4" -> null
          - public_ip_address_id          = "/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Network/publicIPAddresses/udacity-azure-course-project1-iac-ip" -> null
          - zones                         = [] -> null
        }
    }

  # azurerm_lb_backend_address_pool.main will be destroyed
  - resource "azurerm_lb_backend_address_pool" "main" {
      - backend_ip_configurations = [] -> null
      - id                        = "/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Network/loadBalancers/udacity-azure-course-project1-iac-lb/backendAddressPools/BackEndAddressPool" -> null
      - load_balancing_rules      = [] -> null
      - loadbalancer_id           = "/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Network/loadBalancers/udacity-azure-course-project1-iac-lb" -> null
      - name                      = "BackEndAddressPool" -> null
      - resource_group_name       = "udacity-azure-course-project1-iac-rg" -> null
    }

  # azurerm_linux_virtual_machine.main[0] will be destroyed
  - resource "azurerm_linux_virtual_machine" "main" {
      - admin_password                  = (sensitive value)
      - admin_username                  = "eduard" -> null
      - allow_extension_operations      = true -> null
      - availability_set_id             = "" -> null
      - computer_name                   = "udacity-azure-course-project1-iac-vm-0" -> null
      - dedicated_host_id               = "" -> null
      - disable_password_authentication = false -> null
      - encryption_at_host_enabled      = false -> null
      - eviction_policy                 = "" -> null
      - extensions_time_budget          = "PT1H30M" -> null
      - id                              = "/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Compute/virtualMachines/udacity-azure-course-project1-iac-vm-0" -> null
      - location                        = "westeurope" -> null
      - max_bid_price                   = -1 -> null
      - name                            = "udacity-azure-course-project1-iac-vm-0" -> null
      - network_interface_ids           = [
          - "/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Network/networkInterfaces/udacity-azure-course-project1-iac-nic-0",
        ] -> null
      - priority                        = "Regular" -> null
      - private_ip_address              = "10.0.1.4" -> null
      - private_ip_addresses            = [
          - "10.0.1.4",
        ] -> null
      - provision_vm_agent              = true -> null
      - proximity_placement_group_id    = "" -> null
      - public_ip_address               = "" -> null
      - public_ip_addresses             = [] -> null
      - resource_group_name             = "udacity-azure-course-project1-iac-rg" -> null
      - size                            = "Standard_D2s_v3" -> null
      - source_image_id                 = "/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Compute/images/Ubuntu1804Image" -> null
      - tags                            = {
          - "project_name" = "IaC"
          - "stage"        = "Submission"
        } -> null
      - virtual_machine_id              = "72f84935-366b-40de-86bd-c93a5c14f97e" -> null
      - virtual_machine_scale_set_id    = "" -> null
      - zone                            = "" -> null

      - os_disk {
          - caching                   = "ReadWrite" -> null
          - disk_size_gb              = 30 -> null
          - name                      = "udacity-azure-course-project1-iac-vm-0_disk1_441b55c26b4a41068a305fa2d50558a7" -> null
          - storage_account_type      = "Standard_LRS" -> null
          - write_accelerator_enabled = false -> null
        }
    }

  # azurerm_linux_virtual_machine.main[1] will be destroyed
  - resource "azurerm_linux_virtual_machine" "main" {
      - admin_password                  = (sensitive value)
      - admin_username                  = "eduard" -> null
      - allow_extension_operations      = true -> null
      - availability_set_id             = "" -> null
      - computer_name                   = "udacity-azure-course-project1-iac-vm-1" -> null
      - dedicated_host_id               = "" -> null
      - disable_password_authentication = false -> null
      - encryption_at_host_enabled      = false -> null
      - eviction_policy                 = "" -> null
      - extensions_time_budget          = "PT1H30M" -> null
      - id                              = "/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Compute/virtualMachines/udacity-azure-course-project1-iac-vm-1" -> null
      - location                        = "westeurope" -> null
      - max_bid_price                   = -1 -> null
      - name                            = "udacity-azure-course-project1-iac-vm-1" -> null
      - network_interface_ids           = [
          - "/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Network/networkInterfaces/udacity-azure-course-project1-iac-nic-1",
        ] -> null
      - priority                        = "Regular" -> null
      - private_ip_address              = "10.0.1.5" -> null
      - private_ip_addresses            = [
          - "10.0.1.5",
        ] -> null
      - provision_vm_agent              = true -> null
      - proximity_placement_group_id    = "" -> null
      - public_ip_address               = "" -> null
      - public_ip_addresses             = [] -> null
      - resource_group_name             = "udacity-azure-course-project1-iac-rg" -> null
      - size                            = "Standard_D2s_v3" -> null
      - source_image_id                 = "/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Compute/images/Ubuntu1804Image" -> null
      - tags                            = {
          - "project_name" = "IaC"
          - "stage"        = "Submission"
        } -> null
      - virtual_machine_id              = "b56682e4-d8e4-432b-a662-48cd59146441" -> null
      - virtual_machine_scale_set_id    = "" -> null
      - zone                            = "" -> null

      - os_disk {
          - caching                   = "ReadWrite" -> null
          - disk_size_gb              = 30 -> null
          - name                      = "udacity-azure-course-project1-iac-vm-1_disk1_4c3a975de4ff4e24a881822c41650615" -> null
          - storage_account_type      = "Standard_LRS" -> null
          - write_accelerator_enabled = false -> null
        }
    }

  # azurerm_managed_disk.main will be destroyed
  - resource "azurerm_managed_disk" "main" {
      - create_option        = "Empty" -> null
      - disk_iops_read_write = 500 -> null
      - disk_mbps_read_write = 60 -> null
      - disk_size_gb         = 1 -> null
      - id                   = "/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Compute/disks/udacity-azure-course-project1-iac-md" -> null
      - location             = "westeurope" -> null
      - name                 = "udacity-azure-course-project1-iac-md" -> null
      - resource_group_name  = "udacity-azure-course-project1-iac-rg" -> null
      - storage_account_type = "Standard_LRS" -> null
      - tags                 = {
          - "project_name" = "IaC"
          - "stage"        = "Submission"
        } -> null
      - zones                = [] -> null
    }

  # azurerm_network_interface.main[0] will be destroyed
  - resource "azurerm_network_interface" "main" {
      - applied_dns_servers           = [] -> null
      - dns_servers                   = [] -> null
      - enable_accelerated_networking = false -> null
      - enable_ip_forwarding          = false -> null
      - id                            = "/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Network/networkInterfaces/udacity-azure-course-project1-iac-nic-0" -> null
      - internal_domain_name_suffix   = "bp41s51nwuiungocyegbagpu2h.ax.internal.cloudapp.net" -> null
      - location                      = "westeurope" -> null
      - mac_address                   = "00-0D-3A-BD-0E-F0" -> null
      - name                          = "udacity-azure-course-project1-iac-nic-0" -> null
      - private_ip_address            = "10.0.1.4" -> null
      - private_ip_addresses          = [
          - "10.0.1.4",
        ] -> null
      - resource_group_name           = "udacity-azure-course-project1-iac-rg" -> null
      - tags                          = {
          - "project_name" = "IaC"
          - "stage"        = "Submission"
        } -> null
      - virtual_machine_id            = "/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Compute/virtualMachines/udacity-azure-course-project1-iac-vm-0" -> null

      - ip_configuration {
          - name                          = "main" -> null
          - primary                       = true -> null
          - private_ip_address            = "10.0.1.4" -> null
          - private_ip_address_allocation = "Dynamic" -> null
          - private_ip_address_version    = "IPv4" -> null
          - subnet_id                     = "/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Network/virtualNetworks/udacity-azure-course-project1-iac-nw/subnets/udacity-azure-course-project1-iac-subnet1" -> null
        }
    }

  # azurerm_network_interface.main[1] will be destroyed
  - resource "azurerm_network_interface" "main" {
      - applied_dns_servers           = [] -> null
      - dns_servers                   = [] -> null
      - enable_accelerated_networking = false -> null
      - enable_ip_forwarding          = false -> null
      - id                            = "/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Network/networkInterfaces/udacity-azure-course-project1-iac-nic-1" -> null
      - internal_domain_name_suffix   = "bp41s51nwuiungocyegbagpu2h.ax.internal.cloudapp.net" -> null
      - location                      = "westeurope" -> null
      - mac_address                   = "00-0D-3A-AC-ED-9F" -> null
      - name                          = "udacity-azure-course-project1-iac-nic-1" -> null
      - private_ip_address            = "10.0.1.5" -> null
      - private_ip_addresses          = [
          - "10.0.1.5",
        ] -> null
      - resource_group_name           = "udacity-azure-course-project1-iac-rg" -> null
      - tags                          = {
          - "project_name" = "IaC"
          - "stage"        = "Submission"
        } -> null
      - virtual_machine_id            = "/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Compute/virtualMachines/udacity-azure-course-project1-iac-vm-1" -> null

      - ip_configuration {
          - name                          = "main" -> null
          - primary                       = true -> null
          - private_ip_address            = "10.0.1.5" -> null
          - private_ip_address_allocation = "Dynamic" -> null
          - private_ip_address_version    = "IPv4" -> null
          - subnet_id                     = "/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Network/virtualNetworks/udacity-azure-course-project1-iac-nw/subnets/udacity-azure-course-project1-iac-subnet1" -> null
        }
    }

  # azurerm_network_security_group.main will be destroyed
  - resource "azurerm_network_security_group" "main" {
      - id                  = "/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Network/networkSecurityGroups/udacity-azure-course-project1-iac-nsg" -> null
      - location            = "westeurope" -> null
      - name                = "udacity-azure-course-project1-iac-nsg" -> null
      - resource_group_name = "udacity-azure-course-project1-iac-rg" -> null
      - security_rule       = [
          - {
              - access                                     = "Allow"
              - description                                = ""
              - destination_address_prefix                 = "VirtualNetwork"
              - destination_address_prefixes               = []
              - destination_application_security_group_ids = []
              - destination_port_range                     = "*"
              - destination_port_ranges                    = []
              - direction                                  = "Inbound"
              - name                                       = "AllowInboundSameSubnetVms"
              - priority                                   = 110
              - protocol                                   = "*"
              - source_address_prefix                      = "VirtualNetwork"
              - source_address_prefixes                    = []
              - source_application_security_group_ids      = []
              - source_port_range                          = "*"
              - source_port_ranges                         = []
            },
          - {
              - access                                     = "Allow"
              - description                                = ""
              - destination_address_prefix                 = "VirtualNetwork"
              - destination_address_prefixes               = []
              - destination_application_security_group_ids = []
              - destination_port_range                     = "*"
              - destination_port_ranges                    = []
              - direction                                  = "Outbound"
              - name                                       = "AllowOutboundSameSubnetVms"
              - priority                                   = 100
              - protocol                                   = "*"
              - source_address_prefix                      = "VirtualNetwork"
              - source_address_prefixes                    = []
              - source_application_security_group_ids      = []
              - source_port_range                          = "*"
              - source_port_ranges                         = []
            },
          - {
              - access                                     = "Deny"
              - description                                = ""
              - destination_address_prefix                 = "*"
              - destination_address_prefixes               = []
              - destination_application_security_group_ids = []
              - destination_port_range                     = "*"
              - destination_port_ranges                    = []
              - direction                                  = "Inbound"
              - name                                       = "DenyInboundInternet"
              - priority                                   = 120
              - protocol                                   = "*"
              - source_address_prefix                      = "Internet"
              - source_address_prefixes                    = []
              - source_application_security_group_ids      = []
              - source_port_range                          = "*"
              - source_port_ranges                         = []
            },
        ] -> null
      - tags                = {
          - "project_name" = "IaC"
          - "stage"        = "Submission"
        } -> null
    }

  # azurerm_public_ip.main will be destroyed
  - resource "azurerm_public_ip" "main" {
      - allocation_method       = "Static" -> null
      - id                      = "/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Network/publicIPAddresses/udacity-azure-course-project1-iac-ip" -> null
      - idle_timeout_in_minutes = 4 -> null
      - ip_address              = "20.71.233.43" -> null
      - ip_version              = "IPv4" -> null
      - location                = "westeurope" -> null
      - name                    = "udacity-azure-course-project1-iac-ip" -> null
      - resource_group_name     = "udacity-azure-course-project1-iac-rg" -> null
      - sku                     = "Basic" -> null
      - tags                    = {
          - "project_name" = "IaC"
          - "stage"        = "Submission"
        } -> null
      - zones                   = [] -> null
    }

  # azurerm_resource_group.main will be destroyed
  - resource "azurerm_resource_group" "main" {
      - id       = "/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg" -> null
      - location = "westeurope" -> null
      - name     = "udacity-azure-course-project1-iac-rg" -> null
      - tags     = {
          - "project_name" = "IaC"
          - "stage"        = "Submission"
        } -> null

      - timeouts {}
    }

  # azurerm_subnet.main will be destroyed
  - resource "azurerm_subnet" "main" {
      - address_prefix                                 = "10.0.1.0/24" -> null
      - address_prefixes                               = [
          - "10.0.1.0/24",
        ] -> null
      - enforce_private_link_endpoint_network_policies = false -> null
      - enforce_private_link_service_network_policies  = false -> null
      - id                                             = "/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Network/virtualNetworks/udacity-azure-course-project1-iac-nw/subnets/udacity-azure-course-project1-iac-subnet1" -> null
      - name                                           = "udacity-azure-course-project1-iac-subnet1" -> null
      - resource_group_name                            = "udacity-azure-course-project1-iac-rg" -> null
      - service_endpoints                              = [] -> null
      - virtual_network_name                           = "udacity-azure-course-project1-iac-nw" -> null
    }

  # azurerm_virtual_network.main will be destroyed
  - resource "azurerm_virtual_network" "main" {
      - address_space         = [
          - "10.0.0.0/16",
        ] -> null
      - dns_servers           = [] -> null
      - guid                  = "7fb9fd0b-b56d-4611-99c2-c10c1019f4e7" -> null
      - id                    = "/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Network/virtualNetworks/udacity-azure-course-project1-iac-nw" -> null
      - location              = "westeurope" -> null
      - name                  = "udacity-azure-course-project1-iac-nw" -> null
      - resource_group_name   = "udacity-azure-course-project1-iac-rg" -> null
      - subnet                = [
          - {
              - address_prefix = "10.0.1.0/24"
              - id             = "/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Network/virtualNetworks/udacity-azure-course-project1-iac-nw/subnets/udacity-azure-course-project1-iac-subnet1"
              - name           = "udacity-azure-course-project1-iac-subnet1"
              - security_group = ""
            },
        ] -> null
      - tags                  = {
          - "project_name" = "IaC"
          - "stage"        = "Submission"
        } -> null
      - vm_protection_enabled = false -> null
    }

Plan: 0 to add, 0 to change, 13 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

azurerm_linux_virtual_machine.main[1]: Destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Compute/virtualMachines/udacity-azure-course-project1-iac-vm-1]
azurerm_lb_backend_address_pool.main: Destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Network/loadBalancers/udacity-azure-course-project1-iac-lb/backendAddressPools/BackEndAddressPool]
azurerm_linux_virtual_machine.main[0]: Destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Compute/virtualMachines/udacity-azure-course-project1-iac-vm-0]
azurerm_availability_set.main: Destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Compute/availabilitySets/udacity-azure-course-project1-iac-as]
azurerm_managed_disk.main: Destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Compute/disks/udacity-azure-course-project1-iac-md]
azurerm_network_security_group.main: Destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Network/networkSecurityGroups/udacity-azure-course-project1-iac-nsg]
azurerm_lb_backend_address_pool.main: Destruction complete after 1s
azurerm_lb.main: Destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Network/loadBalancers/udacity-azure-course-project1-iac-lb]
azurerm_availability_set.main: Destruction complete after 2s
azurerm_linux_virtual_machine.main[1]: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...udacity-azure-course-project1-iac-vm-1, 10s elapsed]
azurerm_linux_virtual_machine.main[0]: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...udacity-azure-course-project1-iac-vm-0, 10s elapsed]
azurerm_managed_disk.main: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...s/udacity-azure-course-project1-iac-md, 10s elapsed]
azurerm_network_security_group.main: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-.../udacity-azure-course-project1-iac-nsg, 10s elapsed]
azurerm_network_security_group.main: Destruction complete after 11s
azurerm_lb.main: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...s/udacity-azure-course-project1-iac-lb, 10s elapsed]
azurerm_lb.main: Destruction complete after 11s
azurerm_public_ip.main: Destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Network/publicIPAddresses/udacity-azure-course-project1-iac-ip]
azurerm_managed_disk.main: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...s/udacity-azure-course-project1-iac-md, 20s elapsed]
azurerm_linux_virtual_machine.main[1]: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...udacity-azure-course-project1-iac-vm-1, 20s elapsed]
azurerm_linux_virtual_machine.main[0]: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...udacity-azure-course-project1-iac-vm-0, 20s elapsed]
azurerm_public_ip.main: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...s/udacity-azure-course-project1-iac-ip, 10s elapsed]
azurerm_public_ip.main: Destruction complete after 11s
azurerm_managed_disk.main: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...s/udacity-azure-course-project1-iac-md, 30s elapsed]
azurerm_linux_virtual_machine.main[1]: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...udacity-azure-course-project1-iac-vm-1, 30s elapsed]
azurerm_linux_virtual_machine.main[0]: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...udacity-azure-course-project1-iac-vm-0, 30s elapsed]
azurerm_linux_virtual_machine.main[0]: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...udacity-azure-course-project1-iac-vm-0, 40s elapsed]
azurerm_managed_disk.main: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...s/udacity-azure-course-project1-iac-md, 40s elapsed]
azurerm_linux_virtual_machine.main[1]: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...udacity-azure-course-project1-iac-vm-1, 40s elapsed]
azurerm_linux_virtual_machine.main[1]: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...udacity-azure-course-project1-iac-vm-1, 50s elapsed]
azurerm_linux_virtual_machine.main[0]: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...udacity-azure-course-project1-iac-vm-0, 50s elapsed]
azurerm_managed_disk.main: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...s/udacity-azure-course-project1-iac-md, 50s elapsed]
azurerm_managed_disk.main: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...s/udacity-azure-course-project1-iac-md, 1m0s elapsed]
azurerm_linux_virtual_machine.main[1]: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...udacity-azure-course-project1-iac-vm-1, 1m0s elapsed]
azurerm_linux_virtual_machine.main[0]: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...udacity-azure-course-project1-iac-vm-0, 1m0s elapsed]
azurerm_managed_disk.main: Destruction complete after 1m1s
azurerm_linux_virtual_machine.main[1]: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...udacity-azure-course-project1-iac-vm-1, 1m10s elapsed]
azurerm_linux_virtual_machine.main[0]: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...udacity-azure-course-project1-iac-vm-0, 1m10s elapsed]
azurerm_linux_virtual_machine.main[0]: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...udacity-azure-course-project1-iac-vm-0, 1m20s elapsed]
azurerm_linux_virtual_machine.main[1]: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...udacity-azure-course-project1-iac-vm-1, 1m20s elapsed]
azurerm_linux_virtual_machine.main[0]: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...udacity-azure-course-project1-iac-vm-0, 1m30s elapsed]
azurerm_linux_virtual_machine.main[1]: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...udacity-azure-course-project1-iac-vm-1, 1m30s elapsed]
azurerm_linux_virtual_machine.main[1]: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...udacity-azure-course-project1-iac-vm-1, 1m40s elapsed]
azurerm_linux_virtual_machine.main[0]: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...udacity-azure-course-project1-iac-vm-0, 1m40s elapsed]
azurerm_linux_virtual_machine.main[1]: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...udacity-azure-course-project1-iac-vm-1, 1m50s elapsed]
azurerm_linux_virtual_machine.main[0]: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...udacity-azure-course-project1-iac-vm-0, 1m50s elapsed]
azurerm_linux_virtual_machine.main[0]: Destruction complete after 1m53s
azurerm_linux_virtual_machine.main[1]: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...udacity-azure-course-project1-iac-vm-1, 2m0s elapsed]
azurerm_linux_virtual_machine.main[1]: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...udacity-azure-course-project1-iac-vm-1, 2m10s elapsed]
azurerm_linux_virtual_machine.main[1]: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...udacity-azure-course-project1-iac-vm-1, 2m20s elapsed]
azurerm_linux_virtual_machine.main[1]: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...udacity-azure-course-project1-iac-vm-1, 2m30s elapsed]
azurerm_linux_virtual_machine.main[1]: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...udacity-azure-course-project1-iac-vm-1, 2m40s elapsed]
azurerm_linux_virtual_machine.main[1]: Destruction complete after 2m47s
azurerm_network_interface.main[1]: Destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Network/networkInterfaces/udacity-azure-course-project1-iac-nic-1]
azurerm_network_interface.main[0]: Destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Network/networkInterfaces/udacity-azure-course-project1-iac-nic-0]
azurerm_network_interface.main[0]: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...dacity-azure-course-project1-iac-nic-0, 10s elapsed]
azurerm_network_interface.main[1]: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...dacity-azure-course-project1-iac-nic-1, 10s elapsed]
azurerm_network_interface.main[0]: Destruction complete after 12s
azurerm_network_interface.main[1]: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...dacity-azure-course-project1-iac-nic-1, 20s elapsed]
azurerm_network_interface.main[1]: Destruction complete after 22s
azurerm_subnet.main: Destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Network/virtualNetworks/udacity-azure-course-project1-iac-nw/subnets/udacity-azure-course-project1-iac-subnet1]
azurerm_subnet.main: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...city-azure-course-project1-iac-subnet1, 10s elapsed]
azurerm_subnet.main: Destruction complete after 11s
azurerm_virtual_network.main: Destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg/providers/Microsoft.Network/virtualNetworks/udacity-azure-course-project1-iac-nw]
azurerm_virtual_network.main: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...s/udacity-azure-course-project1-iac-nw, 10s elapsed]
azurerm_virtual_network.main: Destruction complete after 10s
azurerm_resource_group.main: Destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef/resourceGroups/udacity-azure-course-project1-iac-rg]
azurerm_resource_group.main: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...s/udacity-azure-course-project1-iac-rg, 10s elapsed]
azurerm_resource_group.main: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...s/udacity-azure-course-project1-iac-rg, 20s elapsed]
azurerm_resource_group.main: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...s/udacity-azure-course-project1-iac-rg, 30s elapsed]
azurerm_resource_group.main: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...s/udacity-azure-course-project1-iac-rg, 40s elapsed]
azurerm_resource_group.main: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...s/udacity-azure-course-project1-iac-rg, 50s elapsed]
azurerm_resource_group.main: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...s/udacity-azure-course-project1-iac-rg, 1m0s elapsed]
azurerm_resource_group.main: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...s/udacity-azure-course-project1-iac-rg, 1m10s elapsed]
azurerm_resource_group.main: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...s/udacity-azure-course-project1-iac-rg, 1m20s elapsed]
azurerm_resource_group.main: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...s/udacity-azure-course-project1-iac-rg, 1m30s elapsed]
azurerm_resource_group.main: Still destroying... [id=/subscriptions/707a2a01-f589-4fbf-8753-...s/udacity-azure-course-project1-iac-rg, 1m40s elapsed]
azurerm_resource_group.main: Destruction complete after 1m47s

Destroy complete! Resources: 13 destroyed.

