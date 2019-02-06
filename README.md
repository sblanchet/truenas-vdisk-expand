# vdisk-expand.sh for FreeNAS

This script expands ZFS pool after increasing the size of a virtual disk.

## Typical usage

When running FreeNAS as a virtual machine with virtual disks
when you run out of space, you can increase the size of the virtual disks
and then run this script in the FreeNAS shell to expand the associated ZFS pool.

## Example with VMware ESXi

* In VMware ESXi, increase the virtual disk size. It can be done while the
FreeNAS vm is running.

* Go the the FreeNAS shell and run:

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

* Power on the FreeNAS virtual machine.

* Go the the FreeNAS shell and run:

```bash
vdisk-expand.sh /dev/ada1
```


## Compatibility
This script is compatible with [FreeNAS](https://freenas.org) 11.1 and 11.2
