# Rack Spreading

Currently, when creating a machine through the metal-api, the machine is placed randomly inside a partition. This algorithm does not consider spreading machines across different racks and different chassis. This may lead to the situation that a group of machines (that for example form a cluster) can end up being placed in the same rack and the same chassis.

Spreading a group of machines across racks can enhance availability for scenarios like a rack loosing power or a chassis meltdown.

So, instead of just randomly deciding the placement of a machine candidate, we want to propose a placement strategy that attempts to spread machine candidates across the racks inside a partition.

## Placement Strategy

Machines in the project are spread across all available racks evenly within a partition (best effort). For this, an additional request to the datastore has to be made in order to find allocated machines within the project in the partition.

The algorithm will then figure out the least occupied racks and elect a machine candidate randomly from those racks.

The user can optionally pass placement tags which will be considered for spreading the machines as well (this will for example allow spreading by a cluster id tag inside the same project).

## API

```golang
// service/v1/machine.go

type MachineAllocation struct {
    // existing fields are omitted for readability
    PlacementTags []string `json:"placement_tags" description:"by default machines are spread across the racks inside a partition for every project. if placement tags are provided, the machine candidate has an additional anti-affinity to other machines having the same tags"`
}
```
