# nix-config

NixOS configuration using the dendritic flake pattern

## Hosts

| Host | Type | Description |
|------|------|-------------|
| installer | ISO | Minimal installer with SSH access |
| loki | Laptop | Framework 13 |
| tyr | Desktop | Workstation |

## Deployment

All hosts are deployed remotely using [nixos-anywhere](https://github.com/nix-community/nixos-anywhere).
Common tasks are automated with [just](https://github.com/casey/just). Run `just --list` for available recipes.

### Building the installer ISO

```bash
nix build .#installer-iso
```

### New host setup

1. Boot the target from the installer ISO or any Linux environment with SSH access.

2. Identify the target disk:

   ```bash
   just disk-id <user@target>
   ```

3. Create the host directory and disko configuration:

   ```bash
   just init-host <hostname>
   ```

   Create `modules/hosts/<hostname>/disko.nix` using an existing host as a template.

4. Generate an SSH host key:

   ```bash
   just gen-host-key <hostname>
   ```

5. Derive the age key and update `.sops.yaml`:

   ```bash
   just age-key <hostname>
   ```

   Add the age key to `.sops.yaml`, then re-encrypt secrets:

   ```bash
   just sops-rekey
   ```

6. Generate secure boot signing keys (optional):

   ```bash
   just gen-sbctl-keys <hostname>
   ```

7. Create the host configuration in `modules/hosts/<hostname>/default.nix`.

8. Deploy (also generates the facter report):

   ```bash
   just deploy <hostname> <user@target>
   ```

9. Enroll secure boot keys (optional, requires UEFI Setup Mode):

    Boot the target in UEFI Setup Mode, then SSH in and run:

    ```bash
    sbctl enroll-keys
    ```

    After enrollment, enable Secure Boot in the UEFI firmware settings.

10. Rebuild once for limine to sign the boot files (optional, secure boot only):

    ```bash
    just update <hostname> <user@target>
    ```

11. Clean up temporary key material:

    ```bash
    just clean-keys
    ```

### TPM LUKS unlock

Hosts with the `secure-boot` module include the `cryptenroll` helper script
for enrolling a TPM2 key slot on LUKS volumes. This allows the disk to unlock
automatically when the TPM PCR state matches (PCRs 0, 2, 7).

On the target host:

```bash
sudo cryptenroll /dev/<luks-device>
```

The script wraps `systemd-cryptenroll` with `--tpm2-device=auto --tpm2-pcrs=0,2,7`.
You will be prompted for the existing LUKS passphrase.

To re-enroll after a firmware or bootloader change (e.g. secure boot key rotation):

```bash
sudo cryptenroll --wipe-slot=tpm2 /dev/<luks-device>
```

### Clevis Tang unlock

Hosts with the `clevis` module use network-bound disk encryption (NBDE) to
unlock the LUKS boot partition at boot via a Tang server. The Tang server runs
on a host with the `tang` module.

#### Tang server setup

The `tang` module handles everything. On first boot, tang auto-generates its
keys in `/var/lib/private/tang` (persisted via impermanence). Retrieve the
server advertisement for clevis binding:

```bash
curl http://<tang-host>:7654/adv
```

#### ZFS encryption keys

Generate raw encryption keys for ZFS pools:

```bash
just gen-zfs-keys <hostname> <pool1> [pool2] ...
```

Keys are placed in `/tmp/extra-files/<hostname>/persistent/secrets/zfs/` for
deployment with nixos-anywhere.

#### Binding a device with clevis

Generate a JWE file for the LUKS device:

```bash
just gen-clevis-jwe <hostname> <tang-ip>
```

**Important:** Use the Tang server's IP address, not its hostname. DNS is not available in the initrd during early boot.

The JWE file is placed in `/tmp/extra-files/<hostname>/persistent/secrets/clevis/`
for deployment with nixos-anywhere. Then reference it in the host config:

```nix
boot.initrd.clevis.devices."<device>".secretFile = "/persistent/secrets/clevis/<device>.jwe";
```

#### Verifying

After deployment, reboot the client. It should obtain a network address in
initrd via DHCP and contact the Tang server to unlock the device automatically.
If the Tang server is unreachable, the boot process falls back to interactive
passphrase entry.

### Updating flake inputs

To update all flake inputs:

```bash
nix flake update
```

To update a specific input:

```bash
nix flake update <input>
```

### Updating a deployed host

```bash
just update <hostname> <user@target>
```

### Rebuilding locally

To apply configuration changes on the local system:

```bash
nixos-rebuild switch --flake . --sudo
```
