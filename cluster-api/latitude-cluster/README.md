# Latitude Cluster

This example shows how to create a Kubernetes cluster on Latitude using the Cluster API provider for Latitude.sh.

## Getting Started

0. Change the `CLUSTER_NAME`, `PROJECT_ID`, `LOCATION`, `PLAN`, `OPERATING_SYSTEM`, and `SSH_KEY_ID` in the `lsh-cluster.yaml` file.
```bash
sed -i \
  -e 's/<CLUSTER_NAME>/my-cluster/g' \
  -e 's/<PROJECT_ID>/your-project-id/g' \
  -e 's/<LOCATION>/SAO2/g' \
  -e 's/<PLAN>/c2-small-x86/g' \
  -e 's/<SSH_KEY_ID>/your-ssh-key-id/g' \
  lsh-cluster.yaml
```

1. Apply the `lsh-cluster.yaml` file:

```bash
kubectl apply -f lsh-cluster.yaml
```

2. Wait for the cluster to be ready:

```bash
kubectl get latitudecluster
```

3. Get the description of the cluster:

```bash
kubectl describe latitudecluster <CLUSTER_NAME>
```

4. Get the status of the cluster:

```bash
kubectl get latitudecluster <CLUSTER_NAME> -o jsonpath='{.status.ready}'
```

5. Delete the cluster:

```bash
kubectl delete latitudecluster <CLUSTER_NAME>
```

6. Delete all stale resources:

```bash
kubectl delete -f lsh-cluster.yaml
```