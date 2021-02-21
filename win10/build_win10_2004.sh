#!/bin/bash -x

echo "Setting some environment variables"
export PACKER_CACHE_DIR=${HOME}/Code/scripting/packer_cache
export WIN10_ISO_PATH=/Users/kandasamyp/Code/bits/msft

echo "Building Windows 10 2004 OVA Appliance ..."
rm -rf output-vmware-iso

if [[ "$1" -gt "-1" ]] && [[ $1 == "dev" ]]; then
    echo "Applying packer debug build to windows_10.json ..."
    PACKER_LOG=1 packer build -force --only=vsphere-iso -on-error=ask \
    --var-file=var-builder.json \
    --var-file=var-appliance.json \
    --var iso_url=${WIN10_ISO_PATH}/en_windows_10_business_editions_version_2004_x64_dvd_d06ef8c5.iso \
    --var vm_name="Windows10_2004" \
    windows_10.json
else
    echo "Applying packer build to windows_10.json ..."
    packer build --only=vsphere-iso \
    --var-file=var-builder.json \
    --var-file=var-appliance.json \
    --var iso_url=${WIN10_ISO_PATH}/en_windows_10_business_editions_version_2004_x64_dvd_d06ef8c5.iso \
    --var vm_name="Windows10_2004" \
    windows_10.json
fi


