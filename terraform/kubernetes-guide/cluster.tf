# Create a new rancher2 imported Cluster
resource "rancher2_cluster" "imported_cluster" {
  name        = "latitudesh-kubernetes-guide"
  description = "imported Cluster using terraform"
}

resource "latitudesh_server" "server" {
  hostname         = "latitudesh-terraform-guide"
  operating_system = "ubuntu_24_04_x64_lts"
  plan             = var.plan
  project          = var.project_id # You can use the project id or slug
  site             = var.region     # You can use the site id or slug
  ssh_keys         = [var.ssh_key_id]


  provisioner "remote-exec" {

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.primary_ipv4
      private_key = file(var.private_key_path)
    }

    inline = [
      "curl -sfL https://get.rke2.io | sudo sh -",
      "sudo systemctl enable rke2-server.service",
      "sudo systemctl start rke2-server.service",
      "sudo snap install kubectl --classic",
      "sudo chmod +r /etc/rancher/rke2/rke2.yaml",
      "export KUBECONFIG=/etc/rancher/rke2/rke2.yaml",
      "${rancher2_cluster.imported_cluster.cluster_registration_token[0].insecure_command}"
    ]
  }

}