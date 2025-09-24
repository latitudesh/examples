# Cluster API - Latitude.sh

## Disclaimer

This project is a work in progress and is not yet ready for production use. The project is currently in alpha and is not recommended for production use.

## Prerequisites

- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) installed
- [Cluster API provider for Latitude.sh](https://github.com/latitudesh/cluster-api-provider-latitudesh) installed

## Getting Started

1. Install the Cluster API provider for Latitude.sh:

```bash
make install
```

2. Deploy the Cluster API provider for Latitude.sh:

```bash
make deploy
```

3. Apply the `lsh-cluster.yaml` file:

```bash
kubectl apply -f lsh-cluster.yaml
```

4. Wait for the cluster to be ready:

```bash
kubectl get latitudecluster
```

5. Delete the cluster:

```bash
kubectl delete latitudecluster <CLUSTER_NAME>
```

6. Delete all stale resources:

```bash
kubectl delete -f lsh-cluster.yaml
```