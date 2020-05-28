# Multi-tenancy for the metal-api

In the past we decided to treat the metal-api as a "low-level API", i.e. the API does not know anything about projects and tenants. A user with editor access can for example assign machines to every project he desires, he can see all the machines available and control them. Even though we always wanted to keep open the possibility to just offer bare metal machines to the end-user, the ultimate objective has always been to create an API for Kubernetes clusters. Hence, we tried to keep the metal-api code base as small as possible and we added resource scoping to a "higher-level API", the cloud-api. From there, a user would only be able to see his own clusters and IP addresses. The cloud-api is a component that is not open-source.

The implication is that the metal-api has no multi-tenancy without another layer on top of it that implements resource scoping. We treat clusters as first-class citizens and fulfill the objective that we had from the very beginning: give clusters to the end-users.

However, as time passed by, things changed: The Metal Stack is becoming an open-source product and we already have promising adopters of our product, who are willing to contribute to Metal Stack. This is a serious chance of making our product better and more successful. It turns out that the decision we made is sufficient for us, but for others it is not.

## Why adopters need multi-tenancy in the metal-api

### Not every adopter will be interested in the cloud-api

For example, users who want to combine the Metal Stack with Gardener, may not want to hide all of the Gardener's functionality behind the cloud-api in the way we do. They want to use the much more powerful Gardener Dashboard instead. The Gardener itself does not need the cloud-api either. It is a cluster-api by itself. It only needs to utilize our "low-level API" and actually expects this API to have multi-tenancy as otherwise every logged in user can create / destroy clusters in every existing project from the Gardener dashboard.

This makes obvious that, with our decision, we placed an unnecessary obstacle in the way of our adopters: They now need to implement an own layer between the Gardener and the metal-api to provide multi-tenancy. From the Gardener-perspective we strongly differ from other cloud providers in this aspect and it is a matter of time when this will become an issue. When we encourage adopters to implement such interfaces on their own we also partly lose control of our product, we increase divergence.

### We cannot claim that Metal Stack is a multi-tenant solution on our website

As the cloud-api is not part of the Metal Stack, the promise of multi-tenancy is only true for our network layer. Without the cloud-api to enable multi-tenancy, the network isolation is currently useless for end-users. Users of the Metal Stack can not self-manage machines, networks and ips without compromising the environment and thus, there is no self-service. We lose a valuable selling point when adopters can not immediately make use of our leading edge network isolation where we put so much effort to.

### Open partitions for third-party usage

If a third-party uses Gardener and our metal-api had multi-tenancy, we would be able to allow a third-party to create clusters with workers in our own partitions. At the moment, this is not possible because the Gardener needs to know the HMAC secrets to create worker nodes, which would compromise our environment. If a thirdy-party knows our HMAC we lose control over the machines of our own tenants.

### We do not actually want to open-source the cloud-api

One could think about solving the multi-tenancy issue by adding machine endpoints to the cloud-api. Gardener would then not consume the metal-api anymore but only the cloud-api.

This approach would not be ideal. We only want to offer a minimum viable product to adopters. The Gardener does not need a cluster-api as provided by the cloud-api. We want to treat additions on top of the basic stack as enterprise products.

The cloud-api contains billing endpoints, which are a perfect example for an optional addition of the Metal Stack. For basic usage of the Metal Stack a user does not need billing. Still, billing functionality can be interesting for some enterprises, who are like us, selling the infrastructure to third-parties.

### Increased security for provider admins

Multi-tenancy in the metal-api also has the potential to limit the damage that a provider administrator can cause by mistake. If an administrator has to acquire project permissions on machine-level we can effectively reduce the damage he can make to this single project.

Another example would be the automatic provisioning of a Gitlab CI runner used for integration testing (a use case that we have where we do not require the cloud-api). This can easily be done in automated manner with Ansible and the Metal dynamic inventory + modules. However, with Ansible, mistakes in the automation can be made very quickly and if Ansible would only see machines of a dedicated project, this would also reduce damage it can make.

It is likely that there are more similar use-cases like that to come (maybe even for the storage solution?).

Also the surface for our Gardener components (metal-ccm, gardener-extension-provider-metal, machine-controller-manager) would be reduced to project scopes.

## Conclusion

For these reasons the decision we made is very likely to have a negative impact on the adoption-rate of the Metal Stack and we should think about treating machines, networks and ips as first-class citizens as well. This makes us closer to the offer of hyperscalers. As mentioned in the beginning, all the time we tried to keep the possibility open to just offer bare metal machines. Let's continue with decision by adding multi-tenancy to the metal-api.

## Required actions

### Resource scoping

Just as implemented by the cloud-api, resource scoping needs to be added to almost every endpoint of the metal-api:

- Machines / Firewalls
  - A user should only be able to view machines / firewalls of the projects he has at least view access to
  - A user should only be able to create and destroy machines / firewalls for projects he has at least editor access to
    Provider-tenants with at least view access can additionally view machines which have no project assignments
    Provider-tenants with at least editor access can additionally allocate / reserve machines which have no project assignments
- Networks
  - A user should only be able to view networks of the projects he has at least view access to
  - A user should only be able to allocate networks of projects he has at least editor access to
  - A user should only be able to free networks assigned to projects he has at least editor access to
    Provider-tenants with at least view access can additionally view networks which have no project assignments
    Provider-tenants with at least editor access can additionally edit networks which have no project assignments
    Provider-tenants with at least admin access can additionally create or remove networks which have no project assignments
- IPs
  - A user should only be able to view ips of the projects he has at least view access to
  - A user should only be able to allocate ips in networks of projects he has at least editor access to
  - A user should only be able to free ips assigned to projects he has at least editor access to
- Projects
  - A logged in user is able to create projects when he has the permission to create projects
  - A user should only be able to view projects where he has at least view access to
  - A user should only be able to delete projects where he has admin access to
- Partitions / Images
  - Only provider-admin users can add, delete, update
  - All logged in users can view
- IPMI
  - Only provider-tenants can view machine IPMI data
- Endpoints for internal use
  - Should only be accessible with HMAC auth and the HMAC secrets are only known by components of the Metal Stack (mainly for communication between partition and control plane), never for third-party usage

For all of this we need enhance the database queries with a filter for projects that a user has access to. As we already use a client to the masterdata-api in the metal-api, we can extract project memberships of a logged in user from there.

### More permissions

We do not only need `kaas-...` permissions in the LDAP but also `maas-`. This way we can differentiate between permissions for the cloud-api and permissions for the metal-api.

### Service account tokens / technical users

We need to provide the possibility for users to obtain access tokens to use for technical purposes (CI, third-party tooling like Gardener, ...).

We do not have this functionality yet, but it would also become a necessity for the cloud-api at some point in the future.

### Cloud API

- Project creation and deletion again have to be moved back into the metal-api, this also frees adopters from the need to write an own API in order to manage projects- The cloud-api will (again) only proxy project endpoints through to the metal-api
- Do not point the secret bindings to a the shared provider secret in a partition. Create an individual provider-secret for the logged in tenant. The Gardener needs to use this tenant-specific provider secret to talk to the metal-api, do not give the Gardener HMAC access anymore.
- The provider secret partition mapping can be removed from the cloud-api config and from the deployment
