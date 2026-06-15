output "load_balancer_public_ip" {
  value = azurerm_public_ip.lb.ip_address
}

output "bastion_public_ip" {
  value = azurerm_public_ip.bastion.ip_address
}