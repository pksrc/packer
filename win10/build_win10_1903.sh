#!/bin/bash -x

echo "Setting some environment variables"
#export PACKER_CACHE_DIR=${HOME}/Code/scripting/packer_cache
#export WIN10_ISO_PATH=/Users/kandasamyp/Code/homelab-bits/msft

echo "Building Windows 10 1903 OVA Appliance ..."
rm -rf output-vmware-iso

if [[ "$1" -gt "-1" ]] && [[ $1 == "dev" ]]; then
    echo "Applying packer debug build to windows_10.json ..."
    PACKER_LOG=1 packer build -force --only=vsphere-iso \
    --var-file=var-builder.json \
    --var-file=var-appliance.json \
    --var iso_url=packer_cache/en_windows_10_business_editions_version_1903_x64_dvd_37200948.iso \
    --var vm_name="Windows10_1903" \
    windows_10.json
else
    echo "Applying packer build to windows_10.json ..."
    packer build --only=vsphere-iso \
    --var-file=var-builder.json \
    --var-file=var-appliance.json \
    --var iso_url=packer_cache/en_windows_10_business_editions_version_1903_x64_dvd_37200948.iso \
    --var vm_name="Windows10_1903" \
    windows_10.json
fi


