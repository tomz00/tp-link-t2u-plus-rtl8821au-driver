#!/bin/bash

finish_installation() {
   idVendor=$(lsusb | grep "T2U PLUS" | cut -d " " -f 6 | cut -d ":" -f 1)
   idProduct=$(lsusb | grep "T2U PLUS" | cut -d " " -f 6 | cut -d ":" -f 2)

   usb_id=$(sudo dmesg | grep "idVendor=$idVendor, idProduct=$idProduct" | cut -d " " -f 3 | tr -d ":")

   if [ -n "usb_id" ]; then
      read -p "[+] TP-Link Archer T2U PLUS [RTL8821AU] was detected, do you want to replug it automatically? [Y/N]: " -r answer
      if [[ $answer =~ ^[Yy]$ ]]; then
         echo "[+] Unbinding the USB adapter..."
         echo "$usb_id" >/sys/bus/usb/drivers/usb/unbind
         sleep 1
         echo "[+] Binding the USB adapter..."
         echo "$usb_id" >/sys/bus/usb/drivers/usb/bind
         echo "[+] Installation is done."
      elif [[ $answer =~ ^[Nn]$ ]]; then
           echo "[+] Installation is done."
      else
           echo "Invalid input. Please enter either Y or N."
      fi

   else
      echo "[-] It appears that the wireless adapter is not plugged in, finishing the installation."
   fi
}

debian_based_install() {
   sudo apt-get install git bc dkms build-essential libelf-dev aircrack-ng linux-headers-`uname -r` -y
   git clone -b v5.6.4.2 https://github.com/aircrack-ng/rtl8812au.git
   cd rtl8812au
   sudo make dkms_install
   finish_installation
}

kali_linux_install() {
   sudo apt-get install git aicrack-ng realtek-rtl88xxau-dkms -y
   finish_installation
}

raspberrypi_install() {
   sudo apt-get install dkms git raspberrypi-kernel-headers aircrack-ng -y
   git clone -b v5.6.4.2 https://github.com/aircrack-ng/rtl8812au.git
   cd rtl8812au
   sudo make dkms_install
   finish_installation
}

if grep -q 'BCM2' /proc/cpuinfo; then
    echo "[+] OS Detected: Raspberry Pi."
    echo "[+] Starting installation for Raspberry Pi."
    raspberrypi_install
elif grep -q "Kali Linux" /etc/os-release; then
    echo "[+] OS Detected: Kali Linux."
    echo "[+] Starting installation for Kali Linux."
    kali_linux_install
elif grep -Eqi 'debian|buntu|mint' /etc/*release; then
    echo "[+] OS Detected: Debian based."
    echo "[+] Starting installation for Debian based distribution."
    debian_based_install
else
    echo "[-] No supported OS was detected. Aborting the installation."
fi

