#!/bin/bash -x
echo "Setting some environment variables"
export PACKER_CACHE_DIR=${HOME}/homelab/packer_cache

echo "Building PhotonOS OVA Appliance ..."
rm -f output_vsphere/*
rm -f toupload/*

if [[ "$1" -gt "-1" ]] && [[ $1 == "dev" ]]; then
    echo "Applying packer build to photon-dev.json ..."
    PACKER_LOG=1 packer build -force --only=vsphere-iso\
    -var-file=photon-builder.json \
    -var-file=photon-vars.json \
    photon-dev.json
else
    echo "Applying packer build to photon.json ..."
    packer build --only=vsphere-iso\
    -var-file=photon-builder.json \
    -var-file=photon-vars.json \
    photon.json
fi
