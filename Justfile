# List disk IDs on remote target
disk-id target:
    ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no {{target}} -- ls /dev/disk/by-id/

# Create host directory
init-host host:
    mkdir -p modules/hosts/{{host}}

# Generate SSH host key for a new host (pass "etc/ssh" for a persistent root)
gen-host-key host dir="persistent/etc/ssh":
    mkdir -p /tmp/extra-files/{{host}}/{{dir}}
    ssh-keygen -t ed25519 -f /tmp/extra-files/{{host}}/{{dir}}/ssh_host_ed25519_key -N "" -C "root@{{host}}"
    cp /tmp/extra-files/{{host}}/{{dir}}/ssh_host_ed25519_key.pub modules/hosts/{{host}}/

# Generate secure boot signing keys
gen-sbctl-keys host:
    mkdir -p /tmp/extra-files/{{host}}/persistent/var/lib/sbctl
    sbctl create-keys --disable-landlock --export /tmp/extra-files/{{host}}/persistent/var/lib/sbctl/keys --database-path /tmp/extra-files/{{host}}/persistent/var/lib/sbctl/GUID

# Generate ZFS encryption keys
gen-zfs-keys host +pools:
    mkdir -p /tmp/extra-files/{{host}}/persistent/secrets/zfs
    for pool in {{pools}}; do \
        dd if=/dev/urandom of=/tmp/extra-files/{{host}}/persistent/secrets/zfs/${pool}.key bs=32 count=1; \
    done

# Show age key derived from host SSH key
age-key host:
    cat modules/hosts/{{host}}/ssh_host_ed25519_key.pub | ssh-to-age

# Re-encrypt all sops secrets after updating .sops.yaml
sops-rekey:
    find modules -path '*/secrets/*.yaml' -exec sops updatekeys {} \;

# Deploy a host using nixos-anywhere, regenerating its facter report
deploy host target: (_deploy host target "regenerate")

# Deploy a host using nixos-anywhere, reusing the committed facter report
deploy-keep-facter host target: (_deploy host target "keep")

[private]
_deploy host target facter:
    #!/usr/bin/env bash
    args=(--flake .#{{host}} --extra-files /tmp/extra-files/{{host}})
    if [ "{{facter}}" = "regenerate" ]; then
        args+=(--generate-hardware-config nixos-facter modules/hosts/{{host}}/facter.json)
    fi
    for key in /tmp/extra-files/{{host}}/persistent/secrets/zfs/*.key; do
        [ -f "$key" ] && args+=(--disk-encryption-keys "${key#/tmp/extra-files/{{host}}}" "$key")
    done
    args+=({{target}})
    nix run github:nix-community/nixos-anywhere -- "${args[@]}"

# Clean up temporary key material
clean-keys:
    rm -rf /tmp/extra-files

# Update a deployed host remotely
update host target:
    nixos-rebuild switch --flake .#{{host}} --build-host {{target}} --target-host {{target}} --ask-sudo-password
