#!/bin/bash

vfio_bind() {
	modprobe vfio-pci

    for address in $1; do
        echo "bind ${address}"
        vendor=$(cat /sys/bus/pci/devices/$address/vendor)
        device=$(cat /sys/bus/pci/devices/$address/device)
        if [[ -e /sys/bus/pci/devices/$address/driver ]]; then
                echo $address > /sys/bus/pci/devices/$address/driver/unbind
        fi
        echo $vendor $device > /sys/bus/pci/drivers/vfio-pci/new_id
    done
}

vfio_unbind() {
    for address in $1; do
        vendor=$(cat /sys/bus/pci/devices/$address/vendor)
        device=$(cat /sys/bus/pci/devices/$address/device)
        echo "Removing ${address} from vfio-pci id list"
            echo "${vendor} ${device}" > /sys/bus/pci/drivers/vfio-pci/remove_id
        sleep 0.1
        echo "Remove PCI device"
        echo 1 > /sys/bus/pci/devices/${address}/remove
        while [[ -e "/sys/bus/pci/devices/${address}" ]]; do
            sleep 0.1
        done
        echo "Rescanning..."
        echo 1 > /sys/bus/pci/rescan
        while [[ ! -e "/sys/bus/pci/devices/${address}" ]]; do
            sleep 0.1
        done
    done

    rmmod vfio-pci
}

console_framebuffer_bind() {
    echo 1 > /sys/class/vtconsole/vtcon0/bind
    nvidia-xconfig --query-gpu-info > /dev/null 2>&1
    echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/bind
}

console_framebuffer_unbind() {
    echo 0 > /sys/class/vtconsole/vtcon0/bind
    echo 0 > /sys/class/vtconsole/vtcon1/bind
    echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind
}

modprobe_nvidia() {
    modprobe snd_hda_intel
    modprobe nvidia_drm
    modprobe nvidia_modeset
    modprobe nvidia
}

rmmod_nvidia() {
    rmmod nvidia-drm --force
    rmmod nvidia-modeset
    rmmod nvidia
    rmmod snd_hda_intel --force
}