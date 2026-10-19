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

   To redeploy an existing host without overwriting its committed hardware report:

   ```bash
   just deploy-keep-facter <hostname> <user@target>
   ```

   `just deploy` regenerates `modules/hosts/<hostname>/facter.json` from the machine
   it runs against, so it picks up whatever hardware is attached at that moment —
   including transient devices such as an installer USB stick.

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

### Tang server

The `tang` module runs a Tang server for network-bound disk encryption. It
handles everything: on first boot Tang auto-generates its keys in
`/var/lib/private/tang` (persisted via impermanence). Retrieve the server
advertisement with:

```bash
curl http://<tang-host>:7654/adv
```

**Note:** Use the Tang server's IP address rather than its hostname in client
bindings if they need to run before DNS is available.

No host currently binds to it. It is kept for post-boot ZFS key delivery.

### Wi-Fi

loki and tyr run NetworkManager. Shrimphouse is declared in
`modules/networkmanager.nix` with its PSK from sops. Other networks are joined
imperatively with `nmcli` (no sudo needed) and survive reboots, since
`/etc/NetworkManager/system-connections` is persisted:

```bash
nmcli device wifi list
nmcli device wifi connect "<SSID>" --ask
nmcli connection delete "<SSID>"   # forget a network
```

### Home VPN (loki)

loki has a WireGuard profile, `shrimphouse-vpn-01`, for the gateway at
`vpn.shrimphouse.xyz`, declared in `modules/hosts/loki/vpn.nix`. It never
connects on its own; bring it up when something at home is needed:

```bash
nmcli connection up shrimphouse-vpn-01
nmcli connection down shrimphouse-vpn-01
```

It is an IPv4-only split tunnel: only `10.0.20.0/24` and the tunnel's DNS
server (`10.0.200.1`) go through it. Everything else, including IPv6, keeps
using the local network. While it is up, DNS lookups go to `10.0.200.1`.

Setting up the peer:

```bash
wg genkey | tee loki.key | wg pubkey   # public key goes to the gateway
wg genpsk > loki.psk                   # preshared key goes to the gateway too
sops modules/hosts/loki/secrets/nixos.yaml
```

In the sops file, add both keys under `services.wireguard`:

```yaml
services:
  wireguard:
    shrimphouse-vpn-01: <contents of loki.key>
    shrimphouse-vpn-01-psk: <contents of loki.psk>
```

Register loki's public key, the preshared key and loki's tunnel address as a
peer on the gateway, fill in the gateway values at the top of `vpn.nix`, and
delete `loki.key` and `loki.psk`.

To check the state: `nmcli connection show --active` and
`sudo wg show wg-shrimphouse` (look for `latest handshake`).

### ZFS encryption keys

Generate raw encryption keys for ZFS pools:

```bash
just gen-zfs-keys <hostname> <pool1> [pool2] ...
```

Keys are placed in `/tmp/extra-files/<hostname>/persistent/secrets/zfs/` for
deployment with nixos-anywhere.

No host currently uses encrypted datasets.

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
