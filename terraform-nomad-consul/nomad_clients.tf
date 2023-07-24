resource "latitudesh_server" "nomad_clients" {
  count            = var.nomad_client_count
  hostname         = "nomad-client-${count.index + 1}"
  operating_system = "ubuntu_22_04_x64_lts"
  site             = var.nomad_region
  plan             = "c2-small-x86"
  project          = var.project_id
  ssh_keys         = [var.service_account_ssh_key_id]

  depends_on = [latitudesh_server.nomad_servers]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = self.primary_ipv4
    private_key = file(var.private_key_path)
  }

  provisioner "file" {
    source      = "nomad-setup-scripts/nomad-installations.sh"
    destination = "/tmp/nomad-installations.sh"
  }

  provisioner "remote-exec" {
    inline = [
      # Add executable permission to the script, the execute it.
      "chmod +x /tmp/nomad-installations.sh",
      "sudo /tmp/nomad-installations.sh"
    ]
  }
}

resource "null_resource" "nomad_clients_post_script" {
  count      = var.nomad_client_count
  depends_on = [latitudesh_server.nomad_clients, null_resource.nomad_servers_post_script]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = latitudesh_server.nomad_clients[count.index].primary_ipv4
    private_key = file(var.private_key_path)
  }


  provisioner "file" {
    source      = "nomad-setup-scripts/nomad-client-setup.sh"
    destination = "/tmp/nomad-client-setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      # Add executable permission to the script, the execute it.
      "chmod +x /tmp/nomad-client-setup.sh",
      "sudo /tmp/nomad-client-setup.sh ${count.index + 51} ${var.nomad_server_count} ${var.nomad_region} ${var.nomad_vlan_id}"
    ]
  }
}

