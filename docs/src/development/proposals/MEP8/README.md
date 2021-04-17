# Configurable Filesystem layout for Machine Allocation

The current implementation uses a hard coded filesystem layout depending on the specified size and image. This is done in the metal-hammer. This worked well in the past because we had a small amount of sizes and images. But we reached a point where this is to restricted for all use cases we have to fulfill. It also forces us to modify the metal-hammer source code to support a new filesystem layout.

This proposal tries to address this issue by introducing a filesystem layout struct in the metal-api which is then configurable per machine allocation.
The original behavior of automatic filesystem layout decision must still be present, because there must be no API change for existing API consumers. It should be a additional feature during machine allocation.

## API and behavior

The API will get a new endpoint `filesystemlayouts` (TODO naming) to create/update/delete a set of available `filesystemlayouts`.

A `filesystemlayout` will have the following properties

```go

type FilesystemLayout {
  ID          string
  Description string
  Filesystems []Filesystem
  Disks       []Disk
  Raid        []Raid
  Sizes       []Size
  Images      []string
}

type FilesystemOption string
type MountOption string
type RaidOption string
type RaidLevel string
type Device string

type Filesystem struct {
  Path           *string
  Device         Device
  Format         *string
  Label          *string
  MountOptions   []MountOption
  Options        []FilesystemOption
}

type Disk struct {
  Device          Device
  PartitionPrefix string
  Partitions      []Partition
  WipeTable       *bool
}

type Raid struct {
  Devices []Device
  Level   RaidLevel
  Name    string
  Options []RaidOption
  Spares  *int
}

type Partition struct {
  Number             int
  Label              *string
  Size               string
  GUID               *string
  TypeGUID           *string
}
```

Example `metalctl` outputs:

```bash
$ metalctl filesystemlayouts ls
ID        DESCRIPTION         SIZES                         IMAGES
default   default fs layout   c1-large-x86, c1-xlarge-x86   *
ceph      fs layout for ceph  s2-large-x86, s2-xlarge-x86   debian*, ubuntu*
firewall  firewall fs layout  c1-large-x86, c1-xlarge-x86   firewall*

$ metalctl filesystemlayouts describe default
---
id: default
sizes:
  - c1-large-x86
  - c1-xlarge-x86
images:
  - "*"
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
        size: "500M"
        guid: EFISystemPartition
        type: GPTBoot
      - number: 2
        label: "root"
        size: "5G"
        type: GPTLinux
      - number: 3
        label: "varlib"
        size: "-1" # to end of partition
        type: GPTLinux
```

## Components which requires modifications

- metal-hammer:
  - change implementation from build in hard coded logic
- metal-api:
  - new endpoint `filesystemlayouts`
  - add optional spec of `filesystemlayout` during `allocation` with validation if given `filesystemlayout` is possible on given size.
  - implement `filesystemlayouts` validation for:
    - matching to disks in the size
    - no overlapping with the sizes/imagefilter specified in `filesystemlayouts`
- metalctl:
  - implement `filesystemlayouts`
- metal-go:
  - adopt api changes

## TODO

- [ ] Partition UUIDs are required to be able to create fstab, make them public ?
