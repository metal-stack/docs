# Troubleshoot

This document summarizes help when something goes wrong and provides advice on debugging the metal-stack in certain situations.

Of course, it is also advisable to check out the issues on the Github projects for help.

If you still can't find a solution to your problem, please reach out to us and our community. We have a public Slack Channel to discuss problems, but you can also reach us via mail. Check out [metal-stack.io](https://metal-stack.io) for contact information.

```@contents
Pages = ["troubleshoot.md"]
Depth = 5
```

## Deployment

### Ansible fails when the metal control plane helm chart gets applied

There can be many reasons for this. Since you are deploying the metal control plane into a Kubernetes cluster, the first step should be to install [kubectl](https://kubernetes.io/docs/tasks/tools/) and check the pods in your cluster. Depending on the metal-stack version and Kubernetes cluster, your control-plane should look something like this after the deployment (this is in a Kind cluster):

```bash
kubectl get pod -A
NAMESPACE             NAME                                         READY   STATUS      RESTARTS   AGE
ingress-nginx         nginx-ingress-controller-56966f7dc7-khfp9    1/1     Running     0          2m34s
kube-system           coredns-66bff467f8-grn7q                     1/1     Running     0          2m34s
kube-system           coredns-66bff467f8-n7n77                     1/1     Running     0          2m34s
kube-system           etcd-kind-control-plane                      1/1     Running     0          2m42s
kube-system           kindnet-4dv7m                                1/1     Running     0          2m34s
kube-system           kube-apiserver-kind-control-plane            1/1     Running     0          2m42s
kube-system           kube-controller-manager-kind-control-plane   1/1     Running     0          2m42s
kube-system           kube-proxy-jz7kp                             1/1     Running     0          2m34s
kube-system           kube-scheduler-kind-control-plane            1/1     Running     0          2m42s
local-path-storage    local-path-provisioner-bd4bb6b75-cwfb7       1/1     Running     0          2m34s
metal-control-plane   ipam-db-0                                    2/2     Running     0          2m31s
metal-control-plane   masterdata-api-6dd4b54db5-rwk45              1/1     Running     0          33s
metal-control-plane   masterdata-db-0                              2/2     Running     0          2m29s
metal-control-plane   metal-api-998cb46c4-jj2tt                    1/1     Running     0          33s
metal-control-plane   metal-api-initdb-r9sc6                       0/1     Completed   0          2m24s
metal-control-plane   metal-api-liveliness-1590479940-brhc7        0/1     Completed   0          6s
metal-control-plane   metal-console-7955cbb7d7-p6hxp               1/1     Running     0          33s
metal-control-plane   metal-db-0                                   2/2     Running     0          2m34s
metal-control-plane   nsq-lookupd-5b4ccbfb64-n6prg                 1/1     Running     0          2m34s
metal-control-plane   nsqd-6cd87f69c4-vtn9k                        2/2     Running     0          2m33s
```

If there are any failing pods, investigate those and look into container logs. This information should point you to the place where the deployment goes wrong.

!!! info

    Sometimes, you see a helm errors like "no deployed releases" or something like this. When a helm chart fails after the first deployment it could be that you have a chart installation still pending. Also, the control plane helm chart uses pre- and post-hooks, which creates [jobs](https://kubernetes.io/docs/concepts/workloads/controllers/job/) that helm expects to be completed before attempting another deployment. Delete the helm chart (use Helm 3) with `helm delete -n metal-control-plane metal-control-plane` and delete the jobs in the `metal-control-plane` namespace before retrying the deployment.

### In the mini-lab the control-plane deployment fails because my system can't resolve api.172.17.0.1.nip.io

The control-plane deployment returns an error like this:

```bash
deploy-control-plane | fatal: [localhost]: FAILED! => changed=false
deploy-control-plane |   attempts: 60
deploy-control-plane |   content: ''
deploy-control-plane |   elapsed: 0
deploy-control-plane |   msg: 'Status code was -1 and not [200]: Request failed: <urlopen error [Errno -5] No address associated with hostname>'
deploy-control-plane |   redirected: false
deploy-control-plane |   status: -1
deploy-control-plane |   url: http://api.172.17.0.1.nip.io:8080/metal/v1/health
deploy-control-plane |
deploy-control-plane | PLAY RECAP *********************************************************************
deploy-control-plane | localhost                  : ok=29   changed=4    unreachable=0    failed=1    skipped=7    rescued=0    ignored=0
deploy-control-plane |
deploy-control-plane exited with code 2
```

Some home routers have a security feature that prevents DNS Servers to resolve anything in the router's local IP range (DNS-Rebind-Protection).

You need to add an exception for `nip.io` in your router configuration or add `127.0.0.1    api.172.17.0.1.nip.io` to your `/etc/hosts`.

#### FritzBox

`Home Network -> Network -> Network Settings -> Additional Settings -> DNS Rebind Protection -> Host name exceptions -> nip.io`

## Operations

### Fixing Machine Issues

The `metalctl machine issues` command gives you an overview over machines in your metal-stack environment that are in an unusual state.

!!! tip

    Machines that are known not to function properly, should be locked through `metalctl machine lock` and annotated with a description of the problem. This way, you can mark machine for replacement without being in danger of having a user allocating the faulty machine.

In the following sections, you can look up the machine issues that are returned by `metalctl` and find out how to deal with them properly.

#### no-event-container

Every machine in the metal-stack database usually has a corresponding event container where provisioning events are stored. This database entity gets created lazily as soon as a machine is registered by the metal-hammer or a provisioning event for the machine arrives at the metal-api.

When there is no event container, this means that the machine has never registered nor received a provisioning event. As an operator you should evaluate why this machine is not booting into the metal-hammer.

This issue is special in a way that it prevents other issues from being evaluated for this machine because the issue calculation usually requires information from the machine event container.

#### no-partition

When a machine has no partition, the [metal-hammer](https://github.com/metal-stack/metal-hammer) has not yet registered the machine at the [metal-api](https://github.com/metal-stack/metal-api). Instead, the machine was created through metal-stack's event machinery, which does not have a lot of information about a machine (e.g. a PXE boot event was reported from the pixiecore), or just by the [metal-bmc](https://github.com/metal-stack/metal-bmc) which discovered the machine through DHCP.

This can usually happen on the very first boot of a machine and the machine's [hardware is not supported](hardware.md) by metal-stack, leading to the [metal-bmc](https://github.com/metal-stack/metal-bmc) being unable to report BMC details to the metal-api (a metal-bmc report sets the partition id of a machine) and the metal-hammer not finishing the machine registration phase.

To resolve this issue, you need to identify the machine in your metal-stack partition that emits PXE boot events and find the reason why it is not properly booting into the metal-hammer. The console logs of this machine should enable you to find out the root cause.

#### liveliness-dead

For machines without an allocation, the metal-hammer consistently reports whether a machine is still being responsive or not. When the liveliness is `Dead`, there were no events received from this machine for longer than ~5 minutes.

Reasons for this can be:

- The network connection between the partition and metal-stack control plane is interrupted
- The machine was removed from your data center
- The machine has changed its UUID [metal-hammer#52](https://github.com/metal-stack/metal-hammer/issues/52)
- The machine is turned off
- The machine hangs / freezes
- The machine booted to BIOS or UEFI shell and does not try to PXE boot again
- The issue only appears temporarily
  - The machine takes longer than 5 minutes for the reboot
  - The machine is performing a firmware upgrade, which usually takes longer than 5 minutes to succeed

!!! info

    In order to minimize maintenance overhead, a machine which is dead for longer than an hour will be rebooted through the metal-api.

    In case you want to prevent this action from happening for a machine, you can lock the machine through `metalctl machine lock`.

If the machine is dead for a long time and you are sure that it will never come back, you can clean up the machine through `metalctl machine rm --remove-from-database`.

#### liveliness-unknown

For machines that are allocated by a user, the ownership has gone over to this user and as an operator you cannot access the machine anymore. This makes it harder to detect whether a machine is in a healthy state or not. Typically, all official metal-stack OS images deploy an LLDP daemon, that consistently emits alive messages. These messages are caught by the [metal-core](https://github.com/metal-stack/metal-core) and turned into a `Phoned Home` event. Internally, the metal-api uses these events as an indicator to decide whether the machine is still responsive or not.

When the LLDP daemon stopped sending packages, the reasons are identical to those of [dead machines](#liveliness-dead). However, it's not possible anymore to decide whether the user is responsible for reaching this state or not.

In most of the cases, there is not much that can be done from the operator's perspective. You will need to wait for the user to report an issue with the machine. When you do support, you can use this issue type to quickly identify this machine.

#### liveliness-not-available

This is more of a theoretical issue. When the machine liveliness is not available check that the Kubernetes `CronJob` in the metal-stack control plane for evaluating the machine liveliness is running regularly and not containing error logs. Make the machine boot into the metal-hammer and this issue should not appear.

#### failed-machine-reclaim

If a machine remains in the `Phoned Home` state without having an allocation, this indicates that the [metal-bmc](https://github.com/metal-stack/metal-bmc) was not able to put the machine back into PXE boot mode after `metalctl machine rm`. The machine is still running the operating system and it does not return back into the allocatable machine pool. Effectively, you lost a machine in your environment and no-one pays for it. Therefore, you should resolve this issue as soon as possible.

In bad scenarios, when the machine was a firewall, the machine can still reach the internet through the PXE boot network and also attract traffic, which it cannot route anymore inside the tenant VRF. This can cause traffic loss inside a tenant network.

In most of the cases, it should be sufficient to run another `metalctl machine rm` on this machine in order to retry booting into PXE mode. If this still does not succeed, you can boot the machine into the BIOS and manually and change the boot order to PXE boot. This should force booting the metal-hammer again and add the machine back into your pool of allocatable machines.

For further reference, see [metal-api#145](https://github.com/metal-stack/metal-api/issues/145).

#### crashloop

Under bad circumstances, a machine diverges from its typical machine lifecycle. When this happens, the internal state-machine of the metal-api detects that the machine reboots unexpectedly during the provisioning phase. It is likely that the machine has entered a crash loop where it PXE boots again and again without the machine ever becoming usable.

Reasons for this can be:

- The machine's [hardware is not supported](hardware.md) and the metal-hammer crashes during the machine discovery
- The machine registration fails through the metal-hammer because an orphaned / dead machine is still present in the metal-api's data base. The machine is connected to the same switch ports that were used by the orphaned machine. In this case, you should clean up the orphaned machine through `metalctl machine rm --remove-from-database`.

Please also consider console logs of the machine for investigating the issue.

The incomplete cycle count is reset as soon as the machine reaches `Phoned Home` state or there is a `Planned Reboot` of the machine (planned reboot is also done by the metal-hammer once a day in order to reboot with the latest version).

#### last-event-error

The machine had an error during the provisioning lifecycle recently or events are arriving out of order at the metal-api. This can be an interesting hint for the operator that something during machine provisioning went wrong. You can look at the error through `metalctl machine describe` or `metalctl machine logs`.

This error will disappear after a certain time period from `machine issues`. You can still look up the error as described above.

#### asn-not-unique

This issue was introduced by a bug in earlier versions of metal-stack and was fixed in [PR105](https://github.com/metal-stack/metal-api/pull/105.)

To resolve the issue, you need to recreate the firewalls that use the same ASN.

#### bmc-without-mac

The [metal-bmc](https://github.com/metal-stack/metal-bmc) is responsible to report connection data for the machine's [BMC](https://en.wikipedia.org/wiki/Intelligent_Platform_Management_Interface#Baseboard_management_controller).

If it's uncapable of discovering this information, your [hardware might not be supported](hardware.md). Please investigate the logs of the metal-bmc to find out what's going wrong with this machine.

#### bmc-without-ip

The [metal-bmc](https://github.com/metal-stack/metal-bmc) is responsible to report connection data for the machine's [BMC](https://en.wikipedia.org/wiki/Intelligent_Platform_Management_Interface#Baseboard_management_controller).

If it's uncapable of discovering this information, your [hardware might not be supported](hardware.md). Please investigate the logs of the metal-bmc to find out what's going wrong with this machine.

#### bmc-no-distinct-ip

The [metal-bmc](https://github.com/metal-stack/metal-bmc) is responsible to report connection data for the machine's [BMC](https://en.wikipedia.org/wiki/Intelligent_Platform_Management_Interface#Baseboard_management_controller).

When there is no distinct IP address for the BMC, it can be that an orphaned machine used this IP in the past. In this case, you need to clean up the orphaned machine through `metalctl machine rm --remove-from-database`.

#### bmc-info-outdated

The [metal-bmc](https://github.com/metal-stack/metal-bmc) is responsible to report bmc details for the machine's [BMC](https://en.wikipedia.org/wiki/Intelligent_Platform_Management_Interface#Baseboard_management_controller).

When the metal-bmc was not able to fetch the bmc info for longer than 20 minutes, something is wrong with the BMC configuration of the machine. This can be caused by one of the following reasons:

- Wrong password for the root user is configured in the BMC
- ip address of the BMC is either wrong or not present
- the device on the given ip address is not a machine, maybe a switch or a management component which is not managed by the metal-api

In either case, please check the logs for the given machine UUID on the metal-bmc for further details. Also check that the metal-bmc is configured to only consider BMC IPs in the range they are configured from the DHCP server in the partition. This prevents grabbing unrelated BMCs.

### A machine has registered with a different UUID after reboot

metal-stack heavily relies on steady machine UUIDs as the UUID is the primary key of the machine entity in the metal-api.

For further reference also see [metal-stack/metal-hammer#52](https://github.com/metal-stack/metal-hammer/issues/52).

#### Reasons

There are some scenarios (can be vendor-specific), which can cause a machine UUID to change over time, e.g.:

- When the UUID partly contains of a network card's mac address, it can happen when:
  - Exchanging network cards
  - Disabling network cards through BIOS
- Changing the UUID through vendor-specific CLI tool

#### Solution

1. After five minutes, the orphaned machine UUID will be marked dead (💀) because machine events will be sent only to the most recent UUID
1. Identify the dead machine through `metalctl machine ls`
1. Remove the dead machine forcefully with `metalctl machine rm --remove-from-database --yes-i-really-mean-it <uuid>`

### Fixing Switch Issues

#### switch-sync-failing

For your network infrastructure it is key to adapt to new configuration. In case this sync process fails for more than 10 minutes, it is likely to require manual investigation.

Depending on your switch operating system, the error sources might differ a lot.
Try to connect to your switch using the console or ssh and investigate the logs. Check if the hard drive is full.

### Switch Replacement and Migration

There are two mechanisms to replace an existing switch with a new one, both of which will transfer existing VRF configuration and machine connections from one switch to another.
Due to the redundance of the CLOS topology, a switch replacement can be performed without downtime.

#### Replacing a Switch

If the new switch should have the same ID as the old one you should perform a switch replacement.
To find detailed information about the procedure of a switch replacement use `metalctl switch replace --help`.
Basically, what you need to do is mark the switch for replacement via `metalctl switch replace`, then physically replace the switch with the new one and configure it.
The last step is to deploy metal-core on the switch.
Once metal-core registers the new switch at the metal-api, the old switches configuration and machine connections will be transferred to the new one.
Note that the replacement only works if the new switch has the same ID as the old one.
Otherwise metal-core will simply register a new switch and leave the old one untouched.

#### Migrating from one Switch to another

If the new switch should not or cannot have the same ID as the old one, then the `switch migrate` command can be used to achieve the same result as a switch replacement.
Perform the following steps:

1. Leave the old switch in place.
1. Install the new switch in the rack without connecting it to any machines yet.
1. Adjust the metal-stack deployment in the same way as for a switch replacement.
1. Deploy metal-core on the new switch and wait for it to register at the metal-api. Once the switch is registered it will be listed when you run `metalctl switch ls`.
1. Run `metalctl switch migrate <old-switch-id> <new-switch-id>`.
1. Disconnect all machines from the old switch and connect them to the new one.

In between steps 5 and 6 there is a mismatch between the switch-machine-connections known to the metal-api and the real connections.
Since the metal-api learns about the connections from what a machine reports during registration, a machine registration that occurs in between steps 5 and 6 will result in a condition that looks somewhat broken.
The metal-api will think that a machine is connected to three switches.
This, however, should not cause any problems.
Just move on to step 6 and delete the old switch from the metal-api afterwards.
If the case just described really occurs, then `metalctl switch delete <old-switch-id>` will throw an error, because deleting a switch with existing machine connections might be dangerous.
If, apart from that, the migration was successful, then the old switch can be safely deleted with `metalctl switch delete <old-switch-id> --force`.

#### Preconditions for Migration and Replacement

An invariant that must be satisfied throughout is that the switch ports a machine is connected to must match, i.e. a machine connected to `Ethernet0` on switch 1 must be connected to `Ethernet0` on switch 2 etc.
Furthermore, the breakout configurations of both switches must match and the new switch must contain at least all of the old switch's interfaces.

#### Migrating from Cumulus to Edgecore SONiC

Both migration and replacement can be used to move from Cumulus to Edgecore SONiC (or vice versa).
Migrating to or from Broadcom SONiC or mixing Broadcom SONiC with Cumulus or Edgecore SONiC is not supported.

### Connect a Machine to Another Switch Pair

As soon as a machine was connected to the management network and a pair of leaf switches, and the metal-hammer successfully registered the machine at the metal-api after PXE boot, the `switch` entity in metal-stack contains the machine ID in a data structure called _machine connections_.

In case you would like to wire this machine to another pair of switches inside this partition, the metal-api would prevent the machine registration because it finds that the machine is already connected to other switches in this partition.

To resolve this state, the approach for recabling a machine works as follows:

1. Free the machine if it still has an allocation.
1. Reconnect the machine to the new switch pair.
1. Leave the machine turned off or turn it off and wait until the machine reaches the dead state (💀) in the metal-api.
1. Delete the machine through `metalctl machine delete <id> --remove-from-database --yes-i-really-mean-it`. This cleans up the existing machine connections, too.
1. The machine will soon show up again because the [metal-bmc](https://github.com/metal-stack/metal-bmc) discovers it through the DHCP address obtained by the machine BMC.
1. Power on the machine again and let the metal-hammer register the machine.
