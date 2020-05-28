# Deploying metal-stack

We are bootstrapping our control-plane as well as our partitions using Ansible through CI.

In order to build up your deployment, you can make use of the Ansible roles that we are using by ourselves in order to deploy the metal-stack. You can find them in the repository called [metal-roles](https://github.com/metal-stack/metal-roles).

## Deploying the Control Plane

The metal-stack control-plane is typically deployed on Kubernetes. However, there are no specific dependencies of metal-stack running in a Kubernetes cluster. It exposes a traditional REST API that can be used for managing bare metal machines.

## Bootstrapping a Partition

## Deploying a Partition

## Deploying Gardener with metal-stack
