# Latitude Machine

This example shows how to create a machine on Latitude using the Cluster API provider for Latitude.sh.

## Getting Started

0. Change the `PROJECT_ID`, `LOCATION`, `PLAN`, `OPERATING_SYSTEM`, and `SSH_KEY_ID` in the `lsh-machine.yaml` file.
```bash
sed -i \
  -e 's/<MACHINE_NAME>/my-machine/g' \
  -e 's/<PROJECT_ID>/your-project-id/g' \
  -e 's/<LOCATION>/SAO2/g' \
  -e 's/<PLAN>/c2-small-x86/g' \
  -e 's/<SSH_KEY_ID>/your-ssh-key-id/g' \
  -e 's/<KUBEADM_CONFIG_NAME>/my-kubeadm-config/g' \
  -e 's/<CLUSTER_NAME>/my-cluster/g' \
  lsh-machine.yaml
```

1. Apply the `lsh-machine.yaml` file:

```bash
kubectl apply -f lsh-machine.yaml
```

2. Wait for the machine to be ready:

```bash
kubectl get latitudemachine
```

3. Get the description of the machine:

```bash
kubectl describe latitudemachine <MACHINE_NAME>
```

4. Get the status of the machine:

```bash
kubectl get latitudemachine <MACHINE_NAME> -o jsonpath='{.status.ready}'
```

5. Delete the machine:

```bash
kubectl delete latitudemachine <MACHINE_NAME>
```

6. Delete all stale resources:

```bash
kubectl delete -f lsh-machine.yaml
```