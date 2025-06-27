# RBAC

The [metal-api](https://github.com/metal-stack/metal-api) offers three different
user roles for authorization:

- `Admin`
- `Edit`
- `View`

As part of MEP-4, significant work is underway to introduce more fine-grained access control mechanisms within metal-stack, enhancing the precision and flexibility of permission management.

To ensure that internal components interact securely with the metal-api, metal-stack assigns specific roles to each service based on the principle of least privilege.

### metal-hammer

The metal-hammer component interacts with the metal-api and, under the current access control model, requires the `View` role to perform its operations.

### metal-bmc

The metal-bmc collects hardware information from machines and reports it to the metal-api. This functionality requires the `Edit` role based on the current role-based access model.

### pixiecore

pixiecore enables PXE booting within the designated PXE boot network. It communicates with the metal-api and requires the `View` role to function properly.