# Machine Re-Installation

In the current metal-api only machine installations are possible, performing a machine upgrade is only possible by creating a new machine and delete the old one.
This has the drawback that in case a lot of data is stored on the local disks, a full restore of the original data must be performed.

To prevent this, we will introduce a new metal-api endpoint to reinstall the machine with a new image, *without* actually deleting the data stored on the additional hard disks.

Storage is a difficult task to get right and reliable. A short analysis of our different storage requirements lead to 3 different scenarios.

- Storage for the etcd pvs in the seed cluster of every partition.  
  This is the most important storage in our setup because these etcd pods serve as configuration backend for all customer kubernetes clusters. If they fail, the cluster is down. However gardener deploys a backup and restore sidecar into the etcd pod of every customer kubernetes control plane, and if this sidecar detects a corrupt or missing etcd database file(s) it starts automatic restore from the configured backup location. This will take some minutes. If for example a node dies, and gardener creates a new node instead, the csi-lvm created pv is not present on that node. Kubernetes will not schedule the missing etcd pod on this node because it has a local PV configured and is therefore tainted to run only on that node. To let kubernetes create that pod anyhow, someone has to either remove the taint, or delete the pod. If this is done, the pod starts and the restore of the etcd data can start as well. You can see this is a bit too complicated and will take the customer cluster down for a while (not measured yet but in the range of 5-10 minutes).
- Storage in customer clusters.  
  This was not promised in 2020. We have a intermediate solution with the provisioning of csi-lvm by default into all customer clusters. Albeit this is only local storage and will get deleted if a node dies.
- S3 Storage.  
  We have two possibilities to cope with storage:
  - In place update of the OS with a daemonset  
    This will be fast and simple, but might fail because the packages being installed are broken right now, or a filesystem gets full, or any other failure you can think of during a os update. Another drawback is that metal-api does not reflect the updated os image.
  - metal-api get a machine reinstall endpoint  
    With this approach we leverage from existing and already proven mechanisms. Reinstall must keep all data except the sata-dom. Gardener currently is not able to do an update with this approach because it can only do `rolling` updates. Therefore a additional `osupdatestrategy` has to be implemented for metal and other providers in gardener to be able to leverage the metal reinstall on the same machineID approach.

If reinstall is implemented, we should focus on the same technology for all scenarios and put ceph via rook.io into the kubernetes clusters as additional StorageClass. It has to be checked whether to use the raw disk or a PV as the underlay block device where ceph stores its data.

## API and behavior

The API will get an new endpoint "reinstall" this endpoint takes two arguments:

- machineID
- image

No other aspects of the machine can be modified during the re-installation. All data stored in the existing allocation will be preserved, only the image will be modified.
Once this endpoint was called, the machine will get a `reboot` signal with the boot order set to PXE instead of HDD and the network interfaces on the leaf are set to PXE as well. Then the normal installation process starts:

- unchanged: PXE boot with metal-hammer
- changed: metal-hammer first checks with the machineID in the metal-api (through metal-core) if there is already a allocation present
- changed: if a allocation is present and the allocation has set `reinstall: true`, wipe disk is only executed for the root disk, all other disks are untouched.
- unchanged: the specified image is downloaded and burned, `/install.sh` is executed
- unchanged: successful installation is reported back, network is set the the vrf, boot order is set to HDD.
- unchanged: distribution kernel is booted via kexec

We can see that the `allocation` requires one additional parameter: `reinstall` and metal-hammer must check for already existing allocation at an earlier stage.

Components which requires modifications (first guess):

- metal-hammer:
  - check for allocation present earlier
  - evaluation of `reinstall` flag set
  - wipe of disks depends on that flag
  - Bonus: move configuration of disk layout and primary disk detection algorithm (PDDA) from metal-hammer into metal-api.  
    metal-api **MUST** reject reinstallation if the disk found by PDDA does not have the `/etc/metal` directory!
- metal-core:
  - probably nothing
- metal-api:
  - new endpoint `/machine/reinstall`
  - add `Reinstall bool` to data model of `allocation`
  - make sure to reset `Reinstall` after reinstallation to prevent endless reinstallation loop
- metalctl:
  - implement `reinstall`
- metal-go:
  - implement `reinstall`
- gardener (longterm):
  - add the `OSUpgradeStrategy` `reinstall`
