# List disk IDs on remote target
disk-id target:
    ssh nixos@{{target}} -- ls /dev/disk/by-id/

# Generate facter report from remote target
facter host target:
    ssh nixos@{{target}} -- "sudo nix run nixpkgs#nixos-facter -- -o /tmp/facter.json && sudo chmod 644 /tmp/facter.json"
    scp nixos@{{target}}:/tmp/facter.json modules/hosts/{{host}}/facter.json

# Generate SSH host key for a new host
gen-host-key host:
    mkdir -p /tmp/extra-files/persistent/etc/ssh
    ssh-keygen -t ed25519 -f /tmp/extra-files/persistent/etc/ssh/ssh_host_ed25519_key -N "" -C "root@{{host}}"
    cp /tmp/extra-files/persistent/etc/ssh/ssh_host_ed25519_key.pub modules/hosts/{{host}}/

# Generate secure boot signing keys
gen-sbctl-keys:
    mkdir -p /tmp/extra-files/persistent/var/lib/sbctl
    sbctl create-keys --disable-landlock --export /tmp/extra-files/persistent/var/lib/sbctl/keys --database-path /tmp/extra-files/persistent/var/lib/sbctl/GUID

# Show age key derived from host SSH key
age-key host:
    cat modules/hosts/{{host}}/ssh_host_ed25519_key.pub | ssh-to-age

# Re-encrypt all sops secrets after updating .sops.yaml
sops-rekey:
    find modules -name 'secrets.yaml' -exec sops updatekeys {} \;

# Deploy a host using nixos-anywhere
deploy host target:
    nix run github:nix-community/nixos-anywhere -- --flake .#{{host}} --extra-files /tmp/extra-files nixos@{{target}}

# Clean up temporary key material
clean-keys:
    rm -rf /tmp/extra-files

# Update a deployed host remotely
update host user target:
    nixos-rebuild switch --flake .#{{host}} --build-host {{user}}@{{target}} --target-host {{user}}@{{target}} --ask-sudo-password
