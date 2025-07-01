# RBAC

The [metal-api](https://github.com/metal-stack/metal-api) offers three different user roles for authorization:

- `Admin`
- `Edit`
- `View`

As part of [MEP-4](../developers/proposals/MEP4/README.md), significant work is underway to introduce more fine-grained access control mechanisms within metal-stack, enhancing the precision and flexibility of permission management.

To ensure that internal components interact securely with the metal-api, metal-stack assigns specific roles to each service based on the principle of least privilege.

| Component              | Role  |
| ---------------------- | ----- |
| image-cache            | View  |
| Gardener               | Admin |
| metal-bmc              | Edit  |
| metal-core             | Edit  |
| metal-hammer           | View  |
| metal-metrics-exporter | Admin |
| pixiecore              | View  |
