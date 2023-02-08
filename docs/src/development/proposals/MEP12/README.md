# Rack Spreading

Currently, when creating a machine through the metal-api, the machine is placed randomly inside a partition. This algorithm does not consider spreading machines across different racks and different chassis. This may lead to the situation that a group of machines (that for example form a cluster) can end up being placed in the same rack and the same chassis.

Spreading a group of machines across racks can enhance availability for scenarios like a rack loosing power or a chassis meltdown.

So, instead of just randomly electing a machine candidate, we want to propose the introduction of a placement strategy for the machine allocation.

## Placement Strategies

The following placement strategies should be implemented:

- `project`: Machines in the project are spread across all available racks evenly (best effort), the user can optionally pass tags which will be considered for spreading the machines as well
- `random`: Machines are randomly placed inside the racks (current implementation)

As the new placement strategy is advantageous over the old implementation, the `project` strategy should become the default if no placement strategy is given.

## API

```golang
// service/v1/machine.go

type PlacementStrategy string

const (
    PlacementStrategyProject    PlacementStrategy = "project"
    PlacementStrategyRandom     PlacementStrategy = "random"
)

type MachinePlacementStrategy struct {
    Strategy        PlacementStrategy
    ProjectStrategy *ProjectStrategy
}

type ProjectStrategy struct {
    Tags    []string
}

type MachineAllocation struct {
	// existing fields are omitted for readability
    Placement *MachinePlacementStrategy `json:"placement_strategy" description:"defines how machines are placed inside a partition, defaults to project"`
}
```
