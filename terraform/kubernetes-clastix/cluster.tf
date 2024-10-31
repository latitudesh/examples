# Create and join worker machines

resource "latitudesh_server" "latitudesh-worker-machine" {
  count            = var.server_count
  hostname         = "latitudesh-worker-machine-${count.index + 1}"
  operating_system = "ubuntu_22_04_x64_lts"
  plan             = var.plan
  project          = var.project_id # You can use the project id or slug
  site             = var.region     # You can use the site id or slug
  ssh_keys         = [var.ssh_key_id]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = self.primary_ipv4
    private_key = file(pathexpand(var.private_key_path))
  }

  provisioner "remote-exec" {

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.primary_ipv4
      private_key = file(pathexpand(var.private_key_path))
    }

    inline = [
      "sudo apt update",
      "sudo apt install socat conntrack -y",
      "wget -O- https://goyaki.clastix.io | sudo JOIN_URL=${var.JOIN_URL} JOIN_TOKEN=${var.JOIN_TOKEN} JOIN_TOKEN_CACERT_HASH=${var.JOIN_TOKEN_CACERT_HASH} bash -s join"
    ]
  }

}
