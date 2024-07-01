# Nomad + Consul cluster with Terraform

Deploys a [Nomad](https://www.nomadproject.io/) cluster with [Consul](https://www.consul.io/) with Terraform on Latitude.sh.

* Creates a given number of Nomad server nodes.
* Creates a given number of Nomad client nodes.
* Installs and configures Nomad, Consul, and Docker on each node.
* Starts up Consul and Nomad so that the cluster is up-and-running and accessible by the end of the Terraform process.
* Uses Latitude.sh's [Private Networks](https://docs.latitude.sh/docs/private-networks) feature for private communication between nodes.

Read the [Nomad cluster with Consul and Terraform](https://docs.latitude.sh/docs/nomad-consul-terraform) guide if you're not familiar with Terraform.