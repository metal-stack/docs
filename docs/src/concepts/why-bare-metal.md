# Why Bare Metal?

Bare metal has several advantages over virtual environments and overcomes several drawbacks of virtual machines. We also listed drawbacks of the bare metal approach. Bare in mind though that it is still possible to virtualize on bare metal environments when you have your stack up and running.

## Virtual Environment Drawbacks

- [Spectre and Meltdown](https://meltdownattack.com/) can only be mitigated with a "cluster per tenant" approach
- Missing isolation of multi-tenant change impacts
- Licensing restrictions
- Noisy-neighbors

## Bare Metal Advantages

- Guaranteed and fastest possible performance (especially disk i/o)
- Reduced stack depth (Host / VM / Application vs. Host / Container)
  - Reduced attack surface
  - Lower costs, higher performance
  - No VM live-migrations
- Bigger hardware configurations possible (hypervisors have restrictions, e.g. it is not possible to assign all CPUs to a single VM)

## Bare Metal Drawbacks

- Hardware defects have direct impact (should be considered by design) and can not be mitigated by live-migration as in virtual environments
- Capacity planning is more difficult (no resource overbooking possible)
