provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-rg"
  location = var.location
  tags = {
    project_name = "IaC"
    stage        = "Submission"
  }
}

# Couldnt get the authorization for the client to perform action 
#   'Microsoft.Authorization/policyDefinitions/write' 
#   over scope '/subscriptions/707a2a01-f589-4fbf-8753-b278612b58ef'
#resource "azurerm_policy_definition" "main" {
#  name         = "tagging-policy"
#  policy_type  = "Custom"
#  mode         = "Indexed"
#  display_name = "Tagging Policy definition"
#  description  = "This policy denies deployment of new Resource with no tags."
#
#  policy_rule = <<POLICY_RULE
#    {
#      "if": {
#        "allOf": [
#          {
#            "value": "[empty(field('tags'))]",
#            "equals": "true"
#          }
#      ]},
#      "then": {
#        "effect": "deny"
#      }
#    }
#POLICY_RULE
#
#}
#
#resource "azurerm_policy_assignment" "main" {
#  name                 = "tagging-policy-assignment"
#  scope                = var.subscription
#  policy_definition_id = azurerm_policy_definition.main.id
#  display_name         = "Tagging Policy Assignment"
#  description          = "Assignment of tagging-policy to all Resources in the Resource Group."
#}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-nw"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    project_name = "IaC"
    stage        = "Submission"
  }
}

resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
    
  security_rule {
    name                       = "AllowOutboundSameSubnetVms"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowInboundSameSubnetVms"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "DenyInboundInternet"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  tags = {
    project_name = "IaC"
    stage        = "Submission"
  }
}

resource "azurerm_subnet" "main" {
  name                 = "${var.prefix}-subnet1"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "main" {
  count               = var.number_of_vms
  name                = "${var.prefix}-nic-${count.index}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "main"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    project_name = "IaC"
    stage        = "Submission"
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  count                           = var.number_of_vms
  name                            = "${var.prefix}-vm-${count.index}"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = "Standard_D2s_v3"
  admin_username                  = var.username
  admin_password                  = var.password
  source_image_id                 = var.packer_image
  disable_password_authentication = false
  network_interface_ids = [
    element(azurerm_network_interface.main.*.id, count.index)
  ]

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  tags = {
    project_name = "IaC"
    stage        = "Submission"
  }
}

resource "azurerm_lb" "main" {
  name                = "${var.prefix}-lb"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.main.id
  }

  tags = {
    project_name = "IaC"
    stage        = "Submission"
  }
}

resource "azurerm_lb_backend_address_pool" "main" {
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.main.id
  name                = "BackEndAddressPool"
}

resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-ip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"

  tags = {
    project_name = "IaC"
    stage        = "Submission"
  }
}

resource "azurerm_availability_set" "main" {
  name                = "${var.prefix}-as"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  managed             = true

  tags = {
    project_name = "IaC"
    stage        = "Submission"
  }
}

resource "azurerm_managed_disk" "main" {
  name                 = "${var.prefix}-md"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1"

  tags = {
    project_name = "IaC"
    stage        = "Submission"
  }
}