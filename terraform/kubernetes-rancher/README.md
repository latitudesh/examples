
# Kubernetes Cluster on Latitude with Terraform

This guide will help you set up a Kubernetes cluster on Latitude using Terraform and Rancher.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed
- [NPM](https://www.npmjs.com/get-npm) installed
- An existing Rancher server
- A Latitude account with an API key

## Important Notes

- Ensure you have an existing Rancher server where the cluster will be created. This Terraform plan does not create a Rancher server.
- The `rancher_api_url` should be in the format `https://<your-rancher-server>/v3`.
- Make sure your Rancher server is accessible from the internet, as the Latitude servers will need to communicate with it.
- The default configuration creates a cluster with 3 worker nodes. Adjust the `node_count` variable if you need a different number of nodes.

## Getting Started

1. Download the example files using degit:

```bash
npx degit latitudesh/examples/terraform/kubernetes-guide my-kubernetes-cluster
cd my-kubernetes-cluster
```

2. Initialize Terraform:

```bash
terraform init
```

3. Update the `variables.tf` file with your specific details:

- `LATITUDESH_AUTH_TOKEN`: Don't hardcode this. You will be asked for it when planning and applying your plan. 
- `project_id`: The ID of the project you want to deploy to. Find this from the [home page](https://www.latitude.sh/dashboard) in the console.
- `plan`: The plan slug. For example, for the m4.metal.medium, use `m4-metal-medium`
- `region`: The slug of the location you want to deploy to. E.g., for Dallas use `DAL`. Find all with the api.latitude.sh/locations endpoint.
- `ssh_key_id`: The ID of the SSH key you want to use for the nodes. Find this in the console under Project settings > SSH keys
- `private_key_path`: This script will access your servers during setup. Add the local path in your computer where the private key of the SSH Key inserted above.
- `rancher_api_url`:  
- `RANCHER_ACCESS_KEY`: 
- `RANCHER_SECRET_KEY`:
- `server_count`: Optional. Number of nodes to provision and add to the cluster.

4. (Optional) Modify other variables in `variables.tf` as needed:

- `project_id`: Your Latitude project ID
- `region`: The region where you want to deploy the cluster
- `plan`: The server plan for the nodes
- `node_count`: The number of worker nodes (default is 3)

5. Review and adjust the `main.tf` file if necessary.

6. Plan your Terraform execution:

```bash
terraform plan
```

7. If the plan looks good, apply the changes:

```bash
terraform apply
```

8. Confirm by typing `yes` when prompted.

## Cleaning Up

To destroy the resources created by this Terraform plan:

```bash
terraform destroy
```

## Support

If you encounter any issues or have questions, please open an issue in the [examples repository](https://github.com/latitudesh/examples/issues).


