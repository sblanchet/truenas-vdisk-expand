# vdisk-expand.sh for TrueNAS Core

This script expands ZFS pool after increasing the size of a virtual disk
 in VMware ESXi, VirtualBox or BHyve.

## Typical usage

When running TrueNAS as a virtual machine with virtual disks
when you run out of space, you can increase the size of the virtual disks
and then expand the associated ZFS pool with this shell script.

## Example with VMware ESXi

* In VMware ESXi, increase the virtual disk size. It can be done while the
TrueNAS vm is running.

* Go the the TrueNAS shell and run:

```bash
vdisk-expand.sh /dev/da1
```

## Example with VirtualBox

* Power off the FreeNAS vm because VirtualBox does not support online
modification of virtual disks.

* Increase the virtual disk size to 16 GB with VBoxManage.

```bash
VBoxManage modifyhd freenas-disk1.vdi  --resize 16384
```

* Power on the TrueNAS virtual machine.

* Go the the TrueNAS shell and run:

```bash
vdisk-expand.sh /dev/ada1
```

## Example with BHyve and virtio disks

* Increase the zvol to 200 GB
```bash
zfs set volsize=200G tank1/vm/my_zvol
```

You have to poweroff/poweron the VM to redetect the new size of the disk.

Then run the script:

```bash
vdisk-expand.sh /dev/vtbd1
```

## Compatibility
This script is compatible with FreeNAS 11.x and [TrueNAS Core](https://truenas.com) 12.0
