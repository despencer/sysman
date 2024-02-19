# Unattended Arch Linux installation in VirtualBox

## Preparation of installation media

The installation process is based on **archiso** package. It prepares the ISO image with bootable ArchLinux live environment
and minimal set of utilites for creating new ArchLinux site. It is highly configurable.

In order to automatically create default user with the password and user settings (for *git*, *mc*, etc) one has to provide
these settings. This data is personal and could not be shared via github.

It is the chicken and egg problem, but in order to obtain custom installation media one has to have an Arch Linux machine at
hand. Let's name it *Preparation site*.

So the preparation process consists of the following:

- **Obtain the preparation site**. It could be created from standard Arch Linux ISO installation image.
- **Clone this sysman repo**. It has default *archiso* source embedded. Yes, it should be updated periodically, but it is out
of scope now.
- **Get default credentials**. Run `linux/prepcred.sh` in order to collect the settings from *Preparation site* to place them
into *archiso* sources.
- **Make the installation image**. Follow the instructions provided by the *archiso*: create working directory and run
`sudo mkarchiso -w workdir -o isodir profile`. In this installation custom profile *archiso* is used. It is based on
standard *baseline* profile.

Now you get the ISO image and can proceed to serial ArchLinux installations.

## Making the machine itself

In Windows environment run `windows\makevm.bat` script to create virtual machine under VirtualBox. The ISO image should be in place.

## Doing the installation

Boot the created fresh machine with ISO image supplied and do the following:

- Run `root/install.sh` with parameters (machine name and IP address). It partitions the virtual hard disk, makes file system,
installs core packages, and prepares a new born system for the first boot.
- After reboot login using early provided credentials and run `sudo /root/config/configure.sh` for setting various parameters
(network, console, host access, etc).
- Again clone *this sysman repo*, navigate to *linux* directory and run one of server role scripts (for example, `embedded\install.sh`).

That's all. The Arch Linux machine is ready for work.