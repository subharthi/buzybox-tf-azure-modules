resource "tls_private_key" "linux_vm_user_key_pair" {
  count = length(var.user_list)
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  count = length(var.user_list)
  content         = "${trimspace(tls_private_key.linux_vm_user_key_pair[count.index].private_key_pem)}"
  filename        = "${var.user_list[count.index].outpath}/${var.user_list[count.index].boxname}/${var.hostname}/${var.user_list[count.index].username}/ssh_key"
  file_permission = "0600"
}

resource "local_file" "public_key" {
  count = length(var.user_list)
  content         = "${trimspace(tls_private_key.linux_vm_user_key_pair[count.index].public_key_openssh)}"
  filename        = "${var.user_list[count.index].outpath}/${var.user_list[count.index].boxname}/${var.hostname}/${var.user_list[count.index].username}/ssh_key.pub"
  file_permission = "0600"
}
