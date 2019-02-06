#!/usr/local/bin/bash

#============================================================================
# vdisk-expand.sh : expand ZFS pool after increasing a vdisk size for FreeNAS
#
# Copyright (C) 2019  Sebastien BLANCHET
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or any later
# version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#
# USAGE
#       vdisk-expand.sh device
#
# EXAMPLE
#       vdisk-expand /dev/da1
#
## REQUIREMENTS
#        FreeNAS 11.x
#
#==========================================================================

PATH=/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/bin

trap "exit 1" TERM
TOP_PID=$$

function alert()
{
    echo "An error has occurred!"
    kill -s TERM $TOP_PID
}


function expand_vdisk() {
    # expand the partition 'freebsd-zfs' on disk $DEVICE
    # then update the associated ZFS pool

    # parameter: $1 -> path to physical disk. For example /dev/da1

    DEVICE=$1

    # check that device exists
    if [ ! -c $DEVICE ]; then
        echo "Error: device $DEVICE does not exist"
        alert
    fi

    DEVICE=`readlink -f $DEVICE`
    echo "Try to expand $DEVICE"

    # sanitize input to remove '/dev/'
    DEVICE=`readlink -f $DEVICE | sed -e 's|/dev/||'`

    # probe device
    camcontrol reprobe $DEVICE || alert

    # allow online partition editing
    sysctl kern.geom.debugflags=16 >/dev/null

    # recover gpt if needed
    gpart recover $DEVICE

    # resize the freebsd-zfs partition (#2)
    gpart resize -i 2 $DEVICE


    # Get ZFS partition name
    gpart show $DEVICE | grep -q -- "-boot"
    if [ $? -eq 0 ] ; then
        # boot device:  use regular partition name
        GPTID="${DEVICE}p2"
    else
        # data device: use GPTID
        GPTID=`glabel list ${DEVICE}p2|grep gptid|cut -f 2 -d :`
    fi


    # get list of pools
    POOL_LIST=`zpool list -H -o name`

    # find pool that contains GPTID
    for p in $POOL_LIST ; do
        zpool status $p |grep -q $GPTID
        if [ $? -eq 0 ]; then
            POOL=$p
            zpool online -e $POOL $GPTID
            echo "OK: $DEVICE has been expanded in pool '$POOL'"
            break
        fi
    done

    # disallow online partition editing
    sysctl kern.geom.debugflags=0 >/dev/null
}


function show_help() {
    # Print help for program
    # Parameters: none

    echo "Expand ZFS pool after increasing a vdisk size"
    echo "Usage:"
    echo " $0 DEVICE"
    echo ""
    echo "Example:"
    echo " $0 /dev/da1"
}


# main routine

# parse options
OPTIND=1         # Reset in case getopts has been used previously in the shell.
while getopts "h?" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    esac
done
shift $((OPTIND-1))

# parse arguments
if [ $# -ne 1 ] ; then
    echo "Error: DEVICE is missing"
    alert
fi

expand_vdisk $1
