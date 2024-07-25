# Create a new rancher2 imported Cluster
resource "rancher2_cluster" "imported_cluster" {
  name        = "latitudesh-kubernetes-guide"
  description = "Terraform-provisioned cluster."
}

resource "latitudesh_server" "control-plane" {
  hostname         = "latitudesh-terraform-guide-1"
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
      private_key = file(pathexpand(var.private_key_path))
    }

    inline = [
      "curl -sfL https://get.rke2.io | sudo sh -",
      "sudo systemctl enable rke2-server.service",
      "sudo systemctl start rke2-server.service",
      "sleep 10",
      "sudo sed -i \"s/127.0.0.1/${self.primary_ipv4}/g\" /etc/rancher/rke2/rke2.yaml",
      "sudo cat /etc/rancher/rke2/rke2.yaml > /tmp/rke2.yaml",
      "sudo cat /var/lib/rancher/rke2/server/node-token > /tmp/node-token",
      "cat /tmp/node-token |  awk '{ print \"token: \" $1 }' >> /tmp/config.yaml",
      "echo ${self.primary_ipv4} | awk '{ print \"node-external-ip: \" $1 }' >> /tmp/config.yaml",
      "sudo mv /tmp/config.yaml /etc/rancher/rke2/",
      "sudo systemctl restart rke2-server.service",
      "sleep 10",
      "sudo -E bash -c '/var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml label node ${self.hostname} node-role.kubernetes.io/worker=worker'"
    ]
  }

  provisioner "local-exec" {
    command = "scp -OT -o StrictHostKeyChecking=no -i ${var.private_key_path} ubuntu@${latitudesh_server.control-plane.primary_ipv4}:\"/tmp/rke2.yaml /tmp/node-token\" ./"
  }

}

resource "latitudesh_server" "control-plane-secundary" {
  count            = var.server_count
  hostname         = "latitudesh-terraform-guide-${count.index + 2}"
  operating_system = "ubuntu_24_04_x64_lts"
  plan             = var.plan
  project          = var.project_id # You can use the project id or slug
  site             = var.region     # You can use the site id or slug
  ssh_keys         = [var.ssh_key_id]

  depends_on = [latitudesh_server.control-plane]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = self.primary_ipv4
    private_key = file(pathexpand(var.private_key_path))
  }

  provisioner "file" {
    source      = "${path.module}/node-token"
    destination = "/tmp/node-token"
  }

  provisioner "file" {
    source      = "${path.module}/rke2.yaml"
    destination = "/tmp/rke2.yaml"
  }

  provisioner "remote-exec" {

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.primary_ipv4
      private_key = file(pathexpand(var.private_key_path))
    }

    inline = [
      "curl -sfL https://get.rke2.io | sudo sh -",
      "sudo mkdir -p /etc/rancher/rke2/",
      "echo \"server: https://${latitudesh_server.control-plane.primary_ipv4}:9345\" >> /tmp/config.yaml",
      "echo \"token: $(cat /tmp/node-token)\" >> /tmp/config.yaml",
      "echo ${self.primary_ipv4} | awk '{ print \"node-external-ip: \" $1 }' >> /tmp/config.yaml",
      "sudo mv /tmp/config.yaml /etc/rancher/rke2/",
      "sudo mv /tmp/rke2.yaml /etc/rancher/rke2/",
      "sudo systemctl enable rke2-agent.service",
      "sudo systemctl start rke2-agent.service",
      "sleep 10",
      "sudo -E bash -c '/var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml label node ${self.hostname} node-role.kubernetes.io/control-plane=control-plane'",
      "sudo -E bash -c '/var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml label node ${self.hostname} node-role.kubernetes.io/etcd=etcd'",
      "sudo -E bash -c '/var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml label node ${self.hostname} node-role.kubernetes.io/master=master'",
      "sudo -E bash -c '/var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml label node ${self.hostname} node-role.kubernetes.io/worker=worker'"
    ]
  }
}

resource "null_resource" "rancher_connection" {

  depends_on = [latitudesh_server.control-plane]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = latitudesh_server.control-plane.primary_ipv4
    private_key = file(pathexpand(var.private_key_path))
  }

  provisioner "remote-exec" {
    inline = [
      "export KUBECONFIG=/tmp/rke2.yaml",
      "export PATH=$PATH:/var/lib/rancher/rke2/bin/",
      "${rancher2_cluster.imported_cluster.cluster_registration_token[0].insecure_command}"
    ]
  }
}