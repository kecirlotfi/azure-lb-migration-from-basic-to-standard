resource "azurerm_lb" "testing-load-balancer" {
  name                = "standard-testing-lb"
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  #sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "frontendip"
    public_ip_address_id = azurerm_public_ip.testing-lb-public-ip.id
  }
  tags = {
    project       = "LBMigration",
    owner         = "Platform Team",
    contibutor    = "Kinja",
    environment   = "LAB"
  }
}

resource "azurerm_public_ip" "testing-lb-public-ip" {
  name                 = "${data.azurerm_resource_group.existing_rg.name}-pub-ip"
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  allocation_method    = "Static"
  #sku  = "Standard"
  tags = {
    project       = "LBMigration",
    owner         = "Platform Team",
    contibutor    = "KINJA",
    environment   = "LAB"
  }
}



resource "azurerm_lb_backend_address_pool" "testing-load-balancer-backend-pool" {
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  loadbalancer_id     = azurerm_lb.testing-load-balancer.id
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "testing-load-balancer-http-probe" {
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  loadbalancer_id     = azurerm_lb.testing-load-balancer.id
  name                = "http-probe"
  protocol            = "tcp"
  port                = "80"
  interval_in_seconds = "5"
  number_of_probes    = "2"
}

resource "azurerm_lb_rule" "testing-load-balancer-hhtps-lb-rule" {
  resource_group_name            = data.azurerm_resource_group.existing_rg.name
  loadbalancer_id                = azurerm_lb.testing-load-balancer.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.testing-load-balancer-backend-pool.id 
  probe_id                       = azurerm_lb_probe.testing-load-balancer-http-probe.id
  name                           = "HTTPS"
  protocol                       = "tcp"
  frontend_port                  = "443"
  backend_port                   = "443"
  frontend_ip_configuration_name = "frontendip"
  idle_timeout_in_minutes        = "5"
  enable_floating_ip            = false
  load_distribution             = "SourceIPProtocol"
  #enable_tcp_reset              = true
}

resource "azurerm_lb_rule" "testing-load-balancer-http-lb-rule" {
  resource_group_name            = data.azurerm_resource_group.existing_rg.name
  loadbalancer_id                = azurerm_lb.testing-load-balancer.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.testing-load-balancer-backend-pool.id
  probe_id                       = azurerm_lb_probe.testing-load-balancer-http-probe.id
  name                           = "HTTP"
  protocol                       = "tcp"
  frontend_port                  = "80"
  backend_port                   = "80"
  frontend_ip_configuration_name = "frontendip"
  idle_timeout_in_minutes        = "5"
  enable_floating_ip            = false
  load_distribution             = "SourceIPProtocol"
  #enable_tcp_reset              = true
}

resource "azurerm_network_interface_backend_address_pool_association" "testing-nic-backend-address-pool-assoc" {
  network_interface_id    = data.azurerm_network_interface.awx.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.testing-load-balancer-backend-pool.id
}