# Deploying metal-stack

We are bootstrapping the [metal control plane](../overview/architecture.md##Metal-Control-Plane-1) as well as our [partitions](../overview/architecture.md#Partitions-1) with [Ansible](https://www.ansible.com/) through CI.

In order to build up your deployment, you can make use of the Ansible roles that we are using by ourselves in order to deploy the metal-stack. You can find them in the repository called [metal-roles](https://github.com/metal-stack/metal-roles). In order to wrap all deployment dependencies there is a special [deployment base image](https://hub.docker.com/r/metalstack/metal-deployment-base) on Docker Hub that you can use. Using this Docker image eliminates a lot of moving parts in the deployment and should keep the footprints on your system fairly small and maintainable.

This document will from now on assume that you want to use our Ansible deployment roles for setting up metal-stack. We will also use the deployment base image, so you should also have [Docker](https://docs.docker.com/get-docker/) installed.

!!! warning

    Probably you need to learn writing Ansible playbooks if you want to be able to deploy the metal-stack as presented in this documentation. Even when starting without any knowledge about Ansible it should not be too hard to follow these docs. In case you need further explanations regarding Ansible please refer to [docs.ansible.com](https://docs.ansible.com/).

!!! info

    If you do not want to use Ansible for deployment, you need to come up with a deployment mechanism by yourself. However, you will probably be able to re-use some of our contents from our [metal-roles](https://github.com/metal-stack/metal-roles) repository, e.g. the Helm chart for deploying the metal control plane.

## Metal Control Plane Deployment

The metal control plane is typically deployed in a Kubernetes cluster. Therefore, this document will assume that you have a Kubernetes cluster ready for application deployment. However, there are no specific dependencies for metal-stack running in a Kubernetes cluster. 

!!! tip

    It is not a requirement to run Kubernetes in your own data center. You can use a cluster managed by a hyperscaler. This has the advantage that you do not need to setup a Kubernetes cluster by yourself and could even become beneficial if you want to improve on fail-safe operation. The only requirement from metal-stack is that your partitions can establish network connections to the metal control plane.

Let's start off with a fresh folder for a new git repository in order to start with your deployment:

```bash
mkdir -p metal-stack-deployment
cd metal-stack-deployment
git init
```

Let's now create the following files and folder structures:

```
.
├── ansible.cfg
├── deploy_metal_control_plane.yaml
├── group_vars
│   └── control-plane
│       └── all.yaml
├── inventory.yaml
├── requirements.yaml
└── roles
    └── ingress-controller
        └── tasks
            └── main.yaml
```

!!! tip

    You can also use the [mini-lab](https://github.com/metal-stack/mini-lab) as a template project for your deployment. It uses the same mechanisms mentioned in this document.

The `requirements.yaml` is used for declaring [Ansible Galaxy](https://galaxy.ansible.com/) role depedencies. It will dynamically provide [metal-roles](https://github.com/metal-stack/metal-roles) and the [ansible-common](https://github.com/metal-stack/ansible-common) role when starting the deployment. The file should contain the following dependencies:

```yaml
---
- src: https://github.com/metal-stack/ansible-common.git
  name: ansible-common
  version: v0.5.2
- src: https://github.com/metal-stack/metal-roles.git
  name: metal-roles
  version: v0.1.12
```

!!! tip

    The [ansible-common](https://github.com/metal-stack/ansible-common.git) repository contains very general roles that you can also use when extending your deployment further.

Then, there will be an inventory in the `inventory.yaml` that adds the localhost to the `control-plane` host group:

```yaml
---
control-plane:
  hosts:
    localhost:
      ansible_python_interpreter: "{{ ansible_playbook_python }}"
```

We do this since we are deploying to Kubernetes and do not need to SSH-connect to any hosts for deployment (which is what Ansible typically does). This inventory is also necessary to pick up the variables inside `group_vars/control-plane` during the deployment.

We also recommend using the following `ansible.cfg`:

```ini
[defaults]
retry_files_enabled = false
force_color = true
host_key_checking = false
stdout_callback = yaml
jinja2_native = true
transport = ssh
timeout = 30
```

Most of the properties in there are up to taste, but make sure you enable the [Jinja2 native environment](https://jinja.palletsprojects.com/en/2.11.x/nativetypes/) as this is needed for some of our roles.

Next, we will define the first playbook in a file called `deploy_metal_control_plane.yaml`. You can start with the following lines:

```yaml
---
- name: Deploy Control Plane
  hosts: control-plane
  connection: local
  gather_facts: no
  roles:
    - name: ansible-common
      tags: always
    - name: ingress-controller
      tags: ingress-controller
    - name: metal-roles/control-plane/roles/prepare
      tags: prepare
    - name: metal-roles/control-plane/roles/nsq
      tags: nsq
    - name: metal-roles/control-plane/roles/metal-db
      tags: metal-db
    - name: metal-roles/control-plane/roles/ipam-db
      tags: ipam-db
    - name: metal-roles/control-plane/roles/masterdata-db
      tags: masterdata-db
    - name: metal-roles/control-plane/roles/metal
      tags: metal
```

The parametrization of the referenced roles can be looked up in more detail in the role documention on [metal-roles/control-plane](https://github.com/metal-stack/metal-roles/tree/master/control-plane). You should not need much special parametrization for now. Just make sure you define all the variables marked as "required" in your `group_vars/control-plane/all.yaml`:

```yaml
---
# common defaults
metal_control_plane_provider_tenant: acme
metal_control_plane_ingress_dns: <your-dns-domain>
metal_control_plane_stage_name: test

# image versions
metal_api_image_tag: v0.7.5
metal_metalctl_image_tag: v0.7.5
metal_masterdata_api_image_tag: v0.7.1
metal_console_image_tag: v0.4.1

metal_db_backup_restore_sidecar_image_tag: v0.5.1
ipam_db_backup_restore_sidecar_image_tag: v0.5.1
masterdata_db_backup_restore_sidecar_image_tag: v0.5.1
```

By the time you will certainly add more parametrization to the deployment. Feel free to split up your `all.yaml` into separate files to keep everything short and clean.

TODO: Describe dealing with grpc certs and certs for NSQ...

As a next step you will need add the tasks for deploying an ingress-controller into your cluster. [nginx-ingress](https://kubernetes.github.io/ingress-nginx/) is what we use. If you want to use another ingress-controller, you need to parametrize the metal roles carefully. When you just use nginx-ingress, make sure to also deploy it to the default namespace ingress-nginx.

TODO: Add deployment via helm chart

Now, it should be possible to run the deployment through Docker. Make sure to have the [Kubeconfig file](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/) of your cluster for Ansible and set the path in the following command accordingly:

```bash
export KUBECONFIG=<path-to-your-cluster-kubeconfig>
docker run --rm -it \
  -v $(pwd):/workdir \
  --workdir /workdir \
  -e KUBECONFIG="${KUBECONFIG}" \
  -e K8S_AUTH_KUBECONFIG="${KUBECONFIG}" \
  metalstack/metal-deployment-base:v0.0.5 \
  /bin/bash -ce \
    "ansible-galaxy install -r requirements.yaml
    ansible-playbook \
      -i inventory.yaml \
      deploy_metal_control_plane.yaml"
```

After the deployment succeeded, you should consider deploying some masterdata entities into your metal-api. For example, you can add your first machine sizes, operating system images, partitions and networks. You can do this by further parametrizing the [metal role](https://github.com/metal-stack/metal-roles/tree/master/control-plane/roles/metal). Please check the role documentation on how to do that.

The basic principles of how the metal control plane can be deployed should now be clear. It is now up to you to migrate the deployment execution into your CI.

!!! info

    Image versions and ansible-role depedencies should be regularly checked for updates and adjusted according to the release notes.

### Setting up the backup-restore-sidecar

The backup-restore-sidecar can come up very handy when you want to add another layer of security to the metal-stack databases in your Kubernetes cluster. The sidecar takes backups of the metal databases in small time intervals and stores them in a blobstore of a cloud provider. This way your metal-stack setup can even survive the deletion of your Kubernetes control plane cluster (including all volumes getting lost). After re-deploying metal-stack to another Kubernetes clusters, the databases should come up quite with the backup data in a matter of seconds.

Checkout the role documentation of the individual databases to find out how to configure the sidecar properly. You can also try out the mechanism from the [backup-restore-sidecar](https://github.com/metal-stack/backup-restore-sidecar) repository.

### Authentication

metal-stack uses [dex](https://github.com/dexidp/dex) for providing user authentication through [OpenID Connect](https://openid.net/connect/) (OIDC).

After setting up a dex server, you can parametrize the [metal role](https://github.com/metal-stack/metal-roles/tree/master/control-plane/roles/metal) for using your dex server by defining the variable `metal_api_dex_address`.

!!! info

    We also have dedicated controllers for using the dex server for Kubernetes clusters when deploying metal-stack along with the Gardener in your environment. The approach is described in further detail in the section [Gardener with metal-stack](@ref).

## Bootstrapping a Partition

## Partition Deployment

## Gardener with metal-stack
