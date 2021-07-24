# Surfshark-nm
Simple script to download OpenVPN configuration files and import them into NetworkManager. This allows to control the VPN connection state for various location directly from the NetworkManager applet.

## Requirements
- **Network Manager**
- **OpenVPN**
- **OpenVPN plugin** for the Network Manager (`networkmanager-openvpn` on Arch-based system or `network-manager-openvpn` on Debian-based systems)
- `wget` and `unzip`

## Installation
The script can be run from everywhere in the system so you can install it however you want. Two simple ways are:
1. **Symlink** it in a PATH folder with
  ```bash
  ln -s /path/Surfshark-nm/surfshark-nm.sh /usr/bin/surfshark-nm
  ```
2. Just **alias** it by adding
  ```bash
  alias surfshark-nm='/path/Surfshark-nm/surfshark-nm.sh'
  ```
  to `.bashrc` or other bash configuration files.

## Usage
At the moment, no configuration files or flags are used. To edit settings and add your VPN credentials, the first few lines of the bash script must be directly edited. Your Surfshark OpenVPN credentials can be found at https://my.surfshark.com/vpn/manual-setup/main.

The script actually supports just two actions:
- `surfshark-nm list` lists all the possible VPN locations. These are the strings you want to use in the LOCATIONS list in the script.
- `surfshark-nm update` removes the old VPN configurations and replaces them with new ones.
