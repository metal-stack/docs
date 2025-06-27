# Expose partition services to control plane via VPN

This MEP is a followup to [MEP9](../MEP9/).

There are services in a partition where control plane components needs to talk to. In a very basic setup this comes down to the `metal-bmc` which enable the serial console access to the machines directly from `metalctl`.
This communication is secured by mTLS which checks the offer of a appropriate client certificate. But still a open Port is present from the partition.

In most scenarios, storage also raises the requirement that a gardener extension in the control plane must be able to talk to the API of the storage in the partition.

With this MEP we draw a solution how to get rid of the requirement to have open ports from the partition and also get rid of a static accessible ip from the outside world to the partition.
This is achieved by using the already existing `headscale` service, which acts as a coordination service for tailscale managed wireguard vpn.

This approach mimics what gardener already does for the `seed` to `shoot` communication.

## Architecture

![Storage API Access](./cluster-and-storage.drawio.svg)

> Storage API Server Access from the control plane

![Console Access](./cluster-and-storage.drawio.svg)

> Console Access from the control plane

## Implementation

It is required to add a tailscale sidecar to the controller which needs vpn access into a partition service. These steps are required:

1.) generate a permanent auth-key for tailscale with:

```bash
metalctl vpn key --ephemeral=false --project <projectid>
---
fad06fb8c4351a3d9d1c2ab36ae8e4e4cc107f719f38724d
```

2.) modify the controller deployment to have the [tailscale sidecar](./sidecar.yaml) configured.
3.) start the modified controller deployment and check logs the network connectivity of the tailscale service:

```bash
kubectl exec -it <pod of the controller> -c tailscale -- tailscale status --active
0.0.0.1         sample-service       b5f26a3b-9a4d-48db-a6b3-d1dd4ac4abec linux   -
```

4.) install tailscale also on a machine inside the partition, see: [Tailscale Installation](https://tailscale.com/download)
5.) generate a permanent auth-key for this machine similar to 1.)
6.) authenticate this installation with this auth-key and the headscale login server

```bash
tailscale login --login-server https://<headscale public dns entry> --accept-routes --auth-key <auth-key from above command>
```

7.) Now you can see the ip addresses of all connected tailnet members with:

```bash
tailscale status
fd7a:115c:a1e0::4 storage              00000000-0000-0000-0000-000000000001 linux   active; relay "nue", tx 11948 rx 15316
fd7a:115c:a1e0::1 sample-service       b5f26a3b-9a4d-48db-a6b3-d1dd4ac4abec linux   active
```

You should be able to ping the other side in both directions.

## Open Topics

- currently all tailnet members can see each other, we should introduce tag based acls
- monitoring of the vpn endpoints must be implemented
- deployment of tailscale to machines must be automated in a way that the generation of the auth-key is integrated
- deployment of tailscale as a sidecar requires adoption of pods which need vpn connectivity (duros-controller, ontap-controller, metal-console)
- also the auth-key generation and the detection of the target ip addresses must be automated by adopting the metal-api endpoint to query vpn members.
