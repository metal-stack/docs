# BGP data plane visibility

Currently a operator can not identify if a certain IP, which is allocated, is actually announced to the outer world.
We want to gather information about the routes on the edge of the network of every partition and store them in the metal-api.

This will bring more visibility to the network and ip address usage in the dataplane.

To achieve this goal we need to implement a new microservice which collects these data and send them via grpc to the metal-api.
The metal-api will store them in a separate table. Later when a network or single IP is described
a lookup to that table is made to show when this ip was last announced.

## metal-api

TODO: describe the new grpc endpoint API and the table structure where the data is stored

## new microservice on the border router

TODO: decide name

HINT: reuse the frr api logic from frr-monitor
