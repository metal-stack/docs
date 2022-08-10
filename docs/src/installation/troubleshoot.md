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

```
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

#### no-partition

When a machine has no partition, the [metal-hammer](https://github.com/metal-stack/metal-hammer) has not yet registered the machine at the [metal-api](https://github.com/metal-stack/metal-api). Instead, the machine was created through metal-stack's event machinery, which does not have a lot of information about a machine (e.g. a PXE boot event was reported from the pixiecore).

This can usually happen on the very first boot of a machine and the machine's [hardware is not supported](../overview/hardware.md) by metal-stack, leading to the [metal-bmc](https://github.com/metal-stack/metal-bmc) being unable to report BMC details to the metal-api (a metal-bmc report sets the partition id of a machine) and the metal-hammer not finishing the machine registration phase.

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

#### failed-machine-reclaim

If a machine remains in the `Phoned Home` state without having an allocation, this indicates that the [metal-bmc](https://github.com/metal-stack/metal-bmc) was not able to put the machine back into PXE boot mode after `metalctl machine rm`. The machine is still running the operating system and it does not return back into the allocatable machine pool. Effectively, you lost a machine in your environment and no-one pays for it. Therefore, you should resolve this issue as soon as possible.

In bad scenarios, when the machine was a firewall, the machine can still reach the internet through the PXE boot network and also attract traffic, which it cannot route anymore inside the tenant VRF. This can cause traffic loss inside a tenant network.

In most of the cases, it should be sufficient to run another `metalctl machine rm` on this machine in order to retry booting into PXE mode. If this still does not succeed, you can boot the machine into the BIOS and manually and change the boot order to PXE boot. This should force booting the metal-hammer again and add the machine back into your pool of allocatable machines.

For further reference, see [metal-api#145](https://github.com/metal-stack/metal-api/issues/145).

#### crashloop

Under bad circumstances, a machine diverges from its typical machine lifecycle. When this happens, the internal state-machine of the metal-api detects that the machine reboots unexpectedly during the provisioning phase. It is likely that the machine has entered a crash loop where it PXE boots again and again without the machine ever becoming usable.

Reasons for this can be:

- The machine's [hardware is not supported](../overview/hardware.md) and the metal-hammer crashes during the machine discovery
- The machine registration fails through the metal-hammer because an orphaned / dead machine is still present in the metal-api's data base. The machine is connected to the same switch ports that were used by the orphaned machine. In this case, you should clean up the orphaned machine through `metalctl machine rm --remove-from-database`.

Please also consider console logs of the machine for investigating the issue.

The incomplete cycle count is reset as soon as the machine reaches `Phoned Home` state or there is a `Planned Reboot` of the machine (planned reboot is also done by the metal-hammer once a day in order to reboot with the latest version).

#### last-event-error

The machine had an error during the provisioning lifecycle recently or events are arriving out of order at the metal-api. This can be an interesting hint for the operator that something during machine provisioning went wrong. You can look at the error through `metalctl machine describe` or `metalctl machine logs`.

This error will disappear after a certain time period from `machine issues`. You can still look up the error as described above.

#### asn-not-unique

This issue was introduced by a bug in earlier versions of metal-stack and was fixed in https://github.com/metal-stack/metal-api/pull/105.

To resolve the issue, you need to recreate the firewalls that use the same ASN.

#### bmc-without-mac

The [metal-bmc](https://github.com/metal-stack/metal-bmc) is responsible to report connection data for the machine's [BMC](https://en.wikipedia.org/wiki/Intelligent_Platform_Management_Interface#Baseboard_management_controller).

If it's uncapable of discovering this information, your [hardware might not be supported](../overview/hardware.md). Please investigate the logs of the metal-bmc to find out what's going wrong with this machine.

#### bmc-without-ip

The [metal-bmc](https://github.com/metal-stack/metal-bmc) is responsible to report connection data for the machine's [BMC](https://en.wikipedia.org/wiki/Intelligent_Platform_Management_Interface#Baseboard_management_controller).

If it's uncapable of discovering this information, your [hardware might not be supported](../overview/hardware.md). Please investigate the logs of the metal-bmc to find out what's going wrong with this machine.

#### bmc-no-distinct-ip

The [metal-bmc](https://github.com/metal-stack/metal-bmc) is responsible to report connection data for the machine's [BMC](https://en.wikipedia.org/wiki/Intelligent_Platform_Management_Interface#Baseboard_management_controller).

When there is no distinct IP address for the BMC, it can be that an orphaned machine used this IP in the past. In this case, you need to clean up the orphaned machine through `metalctl machine rm --remove-from-database`.

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
