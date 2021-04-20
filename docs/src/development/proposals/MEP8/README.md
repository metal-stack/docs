# Configurable Filesystem layout for Machine Allocation

The current implementation uses a hard coded filesystem layout depending on the specified size and image. This is done in the metal-hammer. This worked well in the past because we had a small amount of sizes and images. But we reached a point where this is to restricted for all use cases we have to fulfill. It also forces us to modify the metal-hammer source code to support a new filesystem layout.

This proposal tries to address this issue by introducing a filesystem layout struct in the metal-api which is then configurable per machine allocation.
The original behavior of automatic filesystem layout decision must still be present, because there must be no API change for existing API consumers. It should be a additional feature during machine allocation.

## API and behavior

The API will get a new endpoint `filesystemlayouts` (TODO naming) to create/update/delete a set of available `filesystemlayouts`.

A `filesystemlayout` will have the following properties

```go
// FilesystemLayout to be created on the given machine
type FilesystemLayout struct {
  // ID unique layout identifier
  ID          string
  // Description is human readable
  Description string
  // Filesystems to create on the server
  Filesystems []Filesystem
  // Disks to configure in the server with their partitions
  Disks       []Disk
  // Raid if not empty, create raid arrays out of the individual disks, to place filesystems onto
  Raid        []Raid
  // Constraints which must match to select this Layout
  Constraints FilesystemLayoutConstraints
}

type FilesystemLayoutConstraints struct {
  // Sizes defines the list of sizes this layout applies to
  Sizes []string
  // Images defines a list of image glob patterns this layout should apply
  // the most specific combination of sizes and images will be picked fo a allocation
  // If prefixed with "!" this image glob is not allowed
  Images []string
}


type FilesystemOption string
type MountOption string
type RaidOption string
type RaidLevel string
type Device string
type Format string
type GUID string
type GPTType string

// Filesystem defines a single filesystem to be mounted
type Filesystem struct {
  // Path defines the mountpoint, if nil, it will not be mounted
  Path           *string
  // Device where the filesystem is created on, must be the full device path seen by the OS
  Device         Device
  // Format is the type of filesystem should be created
  Format         Format
  // Label is optional enhances readability
  Label          *string
  // MountOptions which might be required
  MountOptions   []MountOption
  // Options during filesystem creation
  Options        []FilesystemOption
}

// Disk represents a single block device visible from the OS, required
type Disk struct {
  // Device is the full device path
  Device          Device
  // PartitionPrefix specifies which prefix is used if device is partitioned
  // e.g. device /dev/sda, first partition will be /dev/sda1, prefix is therefore /dev/sda
  // for nvme drives this is different, the prefix there is typically /dev/nvme0n1p
  PartitionPrefix string
  // Partitions to create on this device
  Partitions      []Partition
  // WipeOnReinstall, if set to true the whole disk will be erased if reinstall happens
  // during fresh install all disks are wiped
  WipeOnReinstall bool
}

// Raid is optional, if given the devices must match.
// TODO inherit GPTType from underlay device ?
type Raid struct {
  // Name of the raid device, most often this will be /dev/md0 and so forth
  Name    string
  // Devices the devices to form a raid device
  Devices []Device
  // Level the raidlevel to use, can be one of 0,1,5,10 
  // TODO what should be support
  Level   RaidLevel
  // Options required during raid creation, example: --metadata=1.0 for uefi boot partition
  Options []RaidOption
  // Spares defaults to 0
  Spares  int
}

// Partition is a single partition on a device, only GPT partition types are supported
type Partition struct {
  // Number of this partition, will be added to partitionprefix
  Number    int
  // Label to enhance readability
  Label     *string
  // Size given in kubernetes resource metrics
  // if "-1" is given the rest of the device will be used, this requires Number to be the highest in this partition
  Size      string
  // GUID of this partition
  GUID      *GUID
  // GPTType defines the GPT partition type
  GPTType   *GPTType
}

const (
  // VFAT is used for the UEFI boot partition
  VFAT = Format("vfat")
  // EXT3 is usually only used for /boot
  EXT3 = Format("ext3")
  // EXT4 is the default fs
  EXT4 = Format("ext4")
  // SWAP is for the swap partition
  SWAP = Format("swap")
  // None
  NONE = Format("none")

  // GPTBoot EFI Boot Partition
  GPTBoot = GPTType("ef00")
  // GPTLinux Linux Partition
  GPTLinux = GPTType("8300")
  // GPTLinuxRaid Linux Raid Partition
  GPTLinuxRaid = GPTType("fd00")
  // GPTLinux Linux Partition
  GPTLinuxLVM = GPTType("8e00")
  // EFISystemPartition see https://en.wikipedia.org/wiki/EFI_system_partition
  EFISystemPartition = GUID("C12A7328-F81F-11D2-BA4B-00A0C93EC93B")
)
```

Example `metalctl` outputs:

```bash
$ metalctl filesystemlayouts ls
ID        DESCRIPTION         SIZES                         IMAGES
default   default fs layout   c1-large-x86, c1-xlarge-x86   debian*, ubuntu*, centos*
ceph      fs layout for ceph  s2-large-x86, s2-xlarge-x86   debian*, ubuntu*
firewall  firewall fs layout  c1-large-x86, c1-xlarge-x86   firewall*
storage   storage fs layout   s3-large-x86                  centos*
```

The `default` layout reflects what is actually implemented in metal-hammer to guarantee backward compatibility.

```yaml
---
id: default
constraints:
  sizes:
    - c1-large-x86
    - c1-xlarge-x86
  images:
    - "debian*"
    - "ubuntu*"
    - "centos*"
filesystems:
  - path: "/boot/efi"
    device: "/dev/sda1"
    format: "vfat"
    options: "-F 32"
  - path: "/"
    device: "/dev/sda2"
    format: "ext4"
  - path: "/var/lib"
    device: "/dev/sda3"
    format: "ext4"
disks:
  - device: "/dev/sda"
    partitionprefix: "/dev/sda"
    wipe: true
    partitions:
      - number: 1
        label: "efi"
        size: 500000000
        guid: EFISystemPartition
        type: GPTBoot
      - number: 2
        label: "root"
        size: 5000000000
        type: GPTLinux
      - number: 3
        label: "varlib"
        size: -1 # to end of partition
        type: GPTLinux
```

The `firewall` layout reuses the built in nvme disk to store the logs, which is way faster and larger than what the sata-dom ssd provides.

```yaml
---
id: firewall
constraints:
  sizes:
    - c1-large-x86
    - c1-xlarge-x86
  images:
    - "firewall*"
filesystems:
  - path: "/boot/efi"
    device: "/dev/sda1"
    format: "vfat"
    options: "-F 32"
  - path: "/"
    device: "/dev/sda2"
    format: "ext4"
  - path: "/var"
    device: "/dev/nvme0n1p1"
    format: "ext4"
disks:
  - device: "/dev/sda"
    partitionprefix: "/dev/sda"
    wipe: true
    partitions:
      - number: 1
        label: "efi"
        size: 500000000
        guid: EFISystemPartition
        type: GPTBoot
      - number: 2
        label: "root"
        size: 5000000000
        type: GPTLinux
  - device: "/dev/nvme0n1"
    partitionprefix: "/dev/nvme0n1p"
    wipe: true
    partitions:
      - number: 1
        label: "var"
        size: "-1"
        type: GPTLinux
```

The `storage` layout will be used for the storage servers, which must have mirrored boot disks.

```yaml
---
id: storage
constraints:
  sizes:
    - s3-large-x86
  images:
    - "centos*"
filesystems:
  - path: "/boot/efi"
    device: "/dev/md1"
    format: "vfat"
    options: "-F32"
  - path: "/"
    device: "/dev/md2"
    format: "ext4"
disks:
  - device: "/dev/sda"
    partitionprefix: "/dev/sda"
    wipe: true
    partitions:
      - number: 1
        label: "efi"
        size: 500000000
        guid: EFISystemPartition
        type: GPTLinuxRaid
      - number: 2
        label: "root"
        size: 5000000000
        type: GPTLinuxRaid
  - device: "/dev/sdb"
    partitionprefix: "/dev/sdb"
    wipe: true
    partitions:
      - number: 1
        label: "efi"
        size: 500000000
        guid: EFISystemPartition
        type: GPTLinuxRaid
      - number: 2
        label: "root"
        size: 5000000000
        type: GPTLinuxRaid
raid:
  - name: "/dev/md1"
    level: 1
    devices:
      - "/dev/sda1"
      - "/dev/sdb1"
    options: "--metadata=1.0"
  - name: "/dev/md2"
    level: 1
    devices:
      - "/dev/sda2"
      - "/dev/sdb2"
    options: "--metadata=1.0"
```

## Components which requires modifications

- metal-hammer:
  - change implementation from build in hard coded logic
  - move logic to create fstab from install.sh to metal-hammer
- metal-api:
  - new endpoint `filesystemlayouts`
  - add optional spec of `filesystemlayout` during `allocation` with validation if given `filesystemlayout` is possible on given size.
  - add `allocation.filesystemlayout` in the response, based on either the specified `filesystemlayout` or the calculated one.
  - implement `filesystemlayouts` validation for:
    - matching to disks in the size
    - no overlapping with the sizes/imagefilter specified in `filesystemlayouts`
    - all devices specified exists from top to bottom (fs -> disks -> device || fs -> raid -> devices)
- metalctl:
  - implement `filesystemlayouts`
- metal-go:
  - adopt api changes
