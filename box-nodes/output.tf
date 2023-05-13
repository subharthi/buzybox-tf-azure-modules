output "linux-vm" {
    value = lookup(var.azure_nodes,"linux-vm", "")
}