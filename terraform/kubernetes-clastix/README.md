
# Kubernetes Cluster on Latitude with Terraform

This guide will help you set up a Kubernetes cluster on Latitude using Terraform and Clastix Cloud.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed
- [NPM](https://www.npmjs.com/get-npm) installed
- A [Clastix Cloud](https://console.clastix.cloud) Tenant Control Plane with a join token command string.
- A [Latitude.sh](https://www.latitude.sh) account with an API key

## Important Notes

- Ensure you have correctly provisioned a Tenant Control Plane on [Clastix Cloud Console](https://console.clastix.cloud) as this Terraform plan does not create it. Make sure you have the join token command string from the console.
- The default configuration creates 3 worker nodes to join the Tenant Control Plane and form your baremetal Kubernetes cluster. Adjust the `node_count` variable if you need a different number of nodes.

## Getting Started

1. Download the example files using degit:

```bash
npx degit latitudesh/examples/terraform/kubernetes-clastix my-kubernetes-cluster
cd my-kubernetes-cluster
```

2. Initialize Terraform:

```bash
terraform init
```

3. Update the `variables.tf` file with your specific details:

- `JOIN_URL`: The URL of Tenant Control Plane to join. Find this on the [Clastix Cloud Console](https://console.clastix.cloud).

- `JOIN_TOKEN`: The token to join the Tenant Control Plane. Find this on the [Clastix Cloud Console](https://console.clastix.cloud). You will be asked for it when planning and applying your plan.

- `JOIN_TOKEN_CACERT_HASH`: The CA certificate hash of the token. Find this on the [Clastix Cloud Console](https://console.clastix.cloud). You will be asked for it when planning and applying your plan. 

- `LATITUDESH_AUTH_TOKEN`: Don't hardcode this. You will be asked for it when planning and applying your plan. 
- `project_id`: The ID of the project you want to deploy to. Find this from the [home page](https://www.latitude.sh/dashboard) in the console.
- `plan`: The plan slug. For example, for the m4.metal.medium, use `m4-metal-medium`
- `region`: The slug of the location you want to deploy to. E.g., for Dallas use `DAL`. Find all with the api.latitude.sh/locations endpoint.
- `ssh_key_id`: The ID of the SSH key you want to use for the nodes. Find this in the console under Project settings > SSH keys
- `private_key_path`: This script will access your servers during setup. Add the local path in your computer where the private key of the SSH Key inserted above.
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


