Harvester is an open-source hyper-converged infrastructure (HCI) software built on Kubernetes. It is designed to simplify the deployment and management of virtualized workloads.

This repository indicates the Harvester installation steps in an automated way, replacing all place holders correctly this script will deliver the Harvester ready for operation.

The place holder {{HARVESTER-CONFIG-FILE}} must be replaced by url of the config HARVESTER-CONFIG-FILE.yaml

The HARVESTER-ADD-NODE-TO-CLUSTER.yaml configuration file pertains to any other node added after the first one. Since the cluster is already up, the new node will join the cluster.
