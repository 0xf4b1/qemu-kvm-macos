# qemu-kvm-macos

QEMU/KVM setup with GPU passthrough for MacOS on an Arch Linux host

The script should make it comfortable and easy to launch a VM with QEMU/KVM with common and configurable parameters.

If you want to use your GPU inside the VM with PCI passthrough, it cares about driver loading/unloading with no reboot required, so if you are using the GPU on the host OS, you only have to save your work and stop the xserver and when you shutdown the VM, you can continue using the GPU on the host by restarting the xserver. If you have a secondary GPU, you can additionally start another xserver for the host OS while the VM is running.

If you take the cost of partitioning your hard disks, it has the advantage that you can use one single OS installation to natively boot into it (dual-boot) with full performance and use that installation also for the VM. For the VM, it additionally results in having much better IO performance compared with having large file system images on your host linux partition.

## System

|          |                            |
|----------|----------------------------|
|Mainboard | ASRock H87 Pro4            |
|CPU       | Intel(R) Core(TM) i5-4570  |
|GPU       | GeForce GTX 760            |
|OS        | Arch Linux                 |

## Host setup

In the BIOS settings of the mainboard, enable `VT-d` and set the primary GPU to `Onboard`.

Install QEMU and OVMF UEFI firmware files:

    # pacman -S qemu ovmf

Add `intel_iommu=on` to the linux command line. If your bootloader is GRUB, edit `/etc/default/grub` and add it to `GRUB_CMDLINE_LINUX` and regenerate `grub.cfg`:

    # grub-mkconfig -o /boot/grub/grub.cfg

## Configuration

The script loads some configuration parameters from the `config` file.

### File systems

The `DRIVES` parameter contains the paths of file-systems that should be available inside the VM. It can contain file-system images or physical drives, e.g.:

    DRIVES="/dev/sda \
            /path/to/filesystem.img"

### Input

Mouse and keyboard are passed via `evdev`, which allows you to easily switch between host and guest by pressing both control keys. The `INPUTS` parameter contains the paths of input devices, e.g.:

    INPUTS="/dev/input/by-id/usb-Logitech_Gaming_Mouse_G402_6D91317A5254-event-mouse \
            /dev/input/by-id/usb-Logitech_G413_Carbon_Mechanical_Gaming_Keyboard_138736523537-event-kbd,grab_all=on,repeat=on"

### File share

A SMB share is accessible from within the VM via ``\\10.0.2.4\qemu`` and allows access to the path defined in `SHARE` on your host OS.

### VGA

#### QXL

The default mode uses the virtual GPU `qxl` on the guest. The VM is accessible via the QEMU window, can be maximized and scaled to fit the screen size and performs great for non intensive rendering tasks, as showing desktop and some UI applications.

Since it is the default, run the VM with:

    $ sudo ./start-macos-vm.sh

#### GPU passthrough

The primary GPU is passed to the guest OS and gives native rendering performance. If the GPU is used by the host, e.g. by a running xserver, the session must be closed before using any of the following modes and can be restarted when the VM is shut down.

##### Secondary GPU

If you have a second GPU (including Intel Integrated Graphics), you can restart the xserver with an alternate xorg.conf.

To use Intel Integrated Graphics, it could look like this:

    Section "Device"
      Identifier "intel"
      Driver "intel"
      Option "TearFree" "true"
    EndSection

    Section "Screen"
      Identifier "intel"
      Device "intel"
    EndSection

Save the config file as `/etc/X11/xorg.intel.conf` and start a new xserver:

    $ startx -- -config xorg.intel.conf

Then run the VM:

    $ sudo VGA=passthrough ./start-macos-vm.sh

##### Single GPU passthrough

Here, the single GPU is passed to the guest VM which leaves the host OS with no display output. It requires to dump the VBIOS of your GPU and patch it according to this [guide](https://gitlab.com/YuriAlek/vfio/-/wikis/vbios). Place it as `VBIOS.rom` in the directory of this script.

Run the VM:

    $ sudo VGA=passthrough-single ./start-macos-vm.sh

## Resources

- https://wiki.archlinux.org/index.php/PCI_passthrough_via_OVMF
- https://github.com/kholia/OSX-KVM