#!/bin/bash
for dev in "$@"; do
    vendor=$(cat /sys/bus/pci/devices/$dev/vendor)
    device=$(cat /sys/bus/pci/devices/$dev/device)
    echo "Removing ${dev} from vfio-pci id list"
        echo "${vendor} ${device}" > /sys/bus/pci/drivers/vfio-pci/remove_id
    sleep 0.1
    echo "Remove PCI device"
    echo 1 > /sys/bus/pci/devices/${dev}/remove
    while [[ -e "/sys/bus/pci/devices/${dev}" ]]; do
        sleep 0.1
    done
    echo "Rescanning..."
    echo 1 > /sys/bus/pci/rescan
    while [[ ! -e "/sys/bus/pci/devices/${dev}" ]]; do
        sleep 0.1
    done
done
