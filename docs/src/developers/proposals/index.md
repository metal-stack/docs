Metal Stack Enhancement Proposals (MEPs)

This section contains proposals which address substantial modifications to metal-stack.

Every proposal has a short name which starts with _MEP_ followed by an incremental, unique number. Proposals should be raised as pull requests in the [docs](https://github.com/metal-stack/docs) repository and can be discussed in Github issues.

The list of proposals and their current state is listed in the table below.

Possible states are:

- `In Discussion`
- `Accepted`
- `Declined`
- `In Progress`
- `Completed`
- `Aborted`

Once a proposal was accepted, an issue should be raised and the implementation should be done in a separate PR.

| Name                      | Description                                    |      State      |
| :------------------------ | :--------------------------------------------- | :-------------: |
| [MEP-1](MEP1/README.md)   | Distributed Control Plane Deployment           |   `Declined`    |
| [MEP-2](MEP2/README.md)   | Two Factor Authentication                      |    `Aborted`    |
| [MEP-3](MEP3/README.md)   | Machine Re-Installation to preserve local data |   `Completed`   |
| [MEP-4](MEP4/README.md)   | Multi-tenancy for the metal-api                |  `In Progress`  |
| [MEP-5](MEP5/README.md)   | Shared Networks                                |   `Completed`   |
| [MEP-6](MEP6/README.md)   | DMZ Networks                                   |   `Completed`   |
| MEP-7                     | Passing environment variables to machines      |   `Declined`    |
| [MEP-8](MEP8/README.md)   | Configurable Filesystemlayout                  |   `Completed`   |
| [MEP-9](MEP9/README.md)   | No Open Ports To the Data Center               |   `Completed`   |
| [MEP-10](MEP10/README.md) | SONiC Support                                  |   `Completed`   |
| [MEP-11](MEP11/README.md) | Auditing ^of metal-stack resources             |   `Completed`   |
| [MEP-12](MEP12/README.md) | Rack Spreading                                 |   `Completed`   |
| [MEP-13](MEP13/README.md) | IPv6                                           |   `Completed`   |
| [MEP-14](MEP14/README.md) | Independence from external sources             |   `Completed`   |
| MEP-15                    | HAL Improvements                               | `In Discussion` |
| [MEP-16](MEP16/README.md) | Firewall Support for Cluster API Provider      | `In Discussion` |
| [MEP-17](MEP17/README.md) | Global Network View                            | `In Discussion` |
| [MEP-18](MEP18/README.md) | Autonomous Control Plane                       | `In Discussion` |
