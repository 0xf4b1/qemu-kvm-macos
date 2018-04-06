#!/bin/bash

# See https://www.mail-archive.com/qemu-devel@nongnu.org/msg471657.html thread.
#
# The "pc-q35-2.4" machine type was changed to "pc-q35-2.9" on 06-August-2017.
#
# The "media=cdrom" part is needed to make Clover recognize the bootable ISO
# image.

##################################################################################
# NOTE: Comment out the "MY_OPTIONS" line in case you are having booting problems!
##################################################################################

MY_OPTIONS="+aes,+xsave,+avx,+xsaveopt,avx2,+smep"

qemu-system-x86_64 -enable-kvm -m 8192 -cpu Penryn,kvm=on,vendor=GenuineIntel,+invtsc,vmware-cpuid-freq=on,$MY_OPTIONS\
	  -machine pc-q35-2.9 \
	  -smp 4,cores=4 \
	  -usb -device usb-kbd -device usb-tablet \
	  -device isa-applesmc,osk="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc" \
	  -drive if=pflash,format=raw,readonly,file=ovmf/OVMF_CODE-pure-efi.fd \
	  -drive if=pflash,format=raw,file=ovmf/OVMF_VARS-pure-efi-1024x768.fd \
	  -smbios type=2 \
	  -device ide-drive,bus=ide.2,drive=Clover \
	  -drive id=Clover,if=none,snapshot=on,format=qcow2,file=boot/clover.qcow2 \
          -device ide-drive,bus=ide.1,drive=MacHDD \
          -drive id=MacHDD,if=none,file=macosx.qcow2,format=qcow2 \
	  -device ide-drive,bus=ide.0,drive=MacDVD \
	  -drive id=MacDVD,if=none,snapshot=on,media=cdrom,file=macOS_High_Sierra_10_13_1_Official.iso \
          -device ide-drive,bus=ide.3,drive=MacDATA \
          -drive id=MacDATA,if=none,file=data.qcow2,format=qcow2 \
	  -netdev tap,id=net0,ifname=tap0,script=no,downscript=no -device e1000-82545em,netdev=net0,id=net0,mac=52:54:00:c9:18:27 \
	  -device vfio-pci,host=01:00.0,bus=pcie.0,multifunction=on \
	  -device vfio-pci,host=01:00.1,bus=pcie.0 \
	  -usb -device usb-host,hostbus=3,hostaddr=6 \
	  -usb -device usb-host,hostbus=3,hostaddr=4 \
	  -vga none \
	  -nographic
