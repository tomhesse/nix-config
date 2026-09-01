# nix-config

NixOS configuration using the dendritic flake pattern

## Hosts

| Host | Type | Description |
|------|------|-------------|
| installer | ISO | Minimal installer with SSH access |
| loki | Laptop | Framework 13 |
| mimir | Server | Home server |
| tyr | Desktop | Workstation |
| fenrir | Non-NixOS workstation (Ubuntu/WSL) | Home-manager only |

## Development

Enter the dev shell to get all required tools (`just`, `sops`, `home-manager`, `nix-diff`, etc.):

```bash
nix develop
```

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

   Hosts with a persistent root (no impermanence, e.g. `mimir`) keep the key at the
   standard location instead:

   ```bash
   just gen-host-key <hostname> etc/ssh
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

10. Rebuild once for Limine to sign the boot files (optional, secure boot only):

    ```bash
    just update <hostname> <user@target>
    ```

11. Clean up temporary key material:

    ```bash
    just clean-keys
    ```

### TPM LUKS unlock

Hosts with the `secure-boot` module include the `cryptenroll` helper script
for enrolling a TPM2+PIN key slot on LUKS volumes. This allows the disk to
unlock when the TPM PCR state matches (PCRs 0, 2, 7) and the correct PIN is
entered at boot.

On the target host:

```bash
sudo cryptenroll /dev/<luks-device>
```

The script wraps `systemd-cryptenroll` with `--tpm2-device=auto --tpm2-pcrs=0,2,7 --tpm2-with-pin=yes`.
You will be prompted for the existing LUKS passphrase and a new TPM2 PIN.

To re-enroll after a firmware or bootloader change (e.g. secure boot key rotation):

```bash
sudo cryptenroll --wipe-slot=tpm2 /dev/<luks-device>
```

### Bootloaders

Bootloader choice is per host, not part of `base`:

| Module | Hosts | Notes |
|--------|-------|-------|
| `limine` | loki, tyr | Signs its own boot files for Secure Boot |
| `grub` | mimir | UEFI, mirrored ESPs across the ZFS root mirror |

`mimir` uses GRUB solely because `boot.loader.grub.mirroredBoots` handles a
redundant ESP natively — a ZFS root mirror gives redundant data but not a
redundant EFI partition, and Limine has no equivalent. Each SSD carries its own
ESP (`/boot1`, `/boot2`) with its own GRUB core image, `grub.cfg` and copied
kernels, so either disk boots on its own.

`efiInstallAsRemovable = true` with `canTouchEfiVariables = false` installs to
the removable path (`EFI/BOOT/BOOTX64.EFI`) rather than writing an NVRAM entry,
which would point at one specific disk and defeat the mirror.

#### Verifying the mirror

Do not trust the redundancy until it has been tested. With the host powered off,
pull one SSD and boot; the box must come up with `zpool status` reporting
DEGRADED. Reinsert, let the pool resilver, then repeat with the other disk.

The ESPs are mounted `nofail`, so a missing disk does not hang boot. The
trade-off is that `nixos-rebuild` fails at `grub-install` while a disk is
absent, which is intentional — a loud failure is preferable to a silent one.

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

Hosts using the `clevis` module use `clevisLuksAskpass`, which stores the
binding directly in the LUKS header rather than a JWE file. Bind after the
host is deployed and running:

```bash
sudo clevis luks bind -d /dev/<luks-device> tang '{"url":"http://<tang-ip>:<tang-port>"}'
```

**Important:** Use the Tang server's IP address, not its hostname. DNS is not
available in the initrd during early boot.

Verify the binding was written to the header:

```bash
sudo clevis luks list -d /dev/<luks-device>
```

#### Verifying

After binding, reboot the host. It should obtain a network address in initrd
via DHCP and contact the Tang server to unlock the device automatically.
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
