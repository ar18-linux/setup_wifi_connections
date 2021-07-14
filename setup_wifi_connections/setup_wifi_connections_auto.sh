#! /usr/bin/env bash

ar18_installed_target="$(cat "/home/nulysses/.config/ar18/deploy/installed_target")"
. "/home/nulysses/.config/ar18/setup_wifi_connections/${ar18_installed_target}"

# Clear old connections
rm -f "/etc/NetworkManager/system-connections/"*
for network in "${ar18_wifi_networks[@]}"; do    
  iter=""
  iter_var="0"
  ip link | grep ': w' | while read -r dev ; do
    dev="$(echo "${dev}" | xargs | cut -d ' ' -f2)"
    dev="${dev/:/}"
    echo "${dev}"
    uuid=$(uuidgen)
    password="$(cat "/home/nulysses/.config/ar18/secrets/wifi_passwords" | grep "${network}" | cut -d $'\t' -f2)"
    file_path="/etc/NetworkManager/system-connections/${network}${iter}.nmconection"
    cp "/home/nulysses/.config/ar18/setup_wifi_connections/${network}.nmconnection" "${file_path}"
    sed -i "s/{{UUID}}/${uuid}/g" "${file_path}"
    sed -i "s/{{PASSWORD}}/${password}/g" "${file_path}"
    sed -i "s/{{INTERFACE}}/${dev}/g" "${file_path}"
    chmod 0600 "${file_path}"
    iter_var=$((iter_var + 1))
    iter=" ${iter_var}"
  done
done

nmcli con reload
