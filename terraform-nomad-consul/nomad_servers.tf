resource "latitudesh_server" "nomad_servers" {
  count            = var.nomad_server_count
  hostname         = "nomad-server-${count.index + 1}"
  operating_system = "ubuntu_22_04_x64_lts"
  site             = var.nomad_region
  plan             = var.plan
  project          = var.project_id
  ssh_keys         = [var.ssh_key_id]

  provisioner "file" {

    connection {
      host        = self.primary_ipv4
      user        = "ubuntu"
      private_key = file(var.private_key_path)
    }

    source      = "nomad-setup-scripts/nomad-installations.sh"
    destination = "/tmp/nomad-installations.sh"
  }

  provisioner "remote-exec" {

    connection {
      host        = self.primary_ipv4
      user        = "ubuntu"
      private_key = file(var.private_key_path)
    }

    inline = [
      # Add executable permission to the script, the execute it.
      "chmod +x /tmp/nomad-installations.sh",
      "sudo /tmp/nomad-installations.sh"
    ]
  }
}

resource "null_resource" "nomad_servers_post_script" {
  count      = var.nomad_server_count
  depends_on = [latitudesh_server.nomad_servers]

  provisioner "file" {

    connection {
      host        = latitudesh_server.nomad_servers[count.index].primary_ipv4
      user        = "ubuntu"
      private_key = file(var.private_key_path)
    }

    source      = "nomad-setup-scripts/nomad-server-setup.sh"
    destination = "/tmp/nomad-server-setup.sh"
  }

  provisioner "remote-exec" {

    connection {
      host        = latitudesh_server.nomad_servers[count.index].primary_ipv4
      user        = "ubuntu"
      private_key = file(var.private_key_path)
    }

    inline = [
      # Add executable permission to the script, the execute it.
      "chmod +x /tmp/nomad-server-setup.sh",
      "sudo /tmp/nomad-server-setup.sh ${count.index + 1} ${var.nomad_server_count} ${var.nomad_region} ${var.nomad_vlan_id}"
    ]
  }
}
