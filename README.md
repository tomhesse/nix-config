# nix-config

NixOS configuration using the dendritic flake pattern

## Hosts

| Host | Type | Description |
|------|------|-------------|
| installer | ISO | Minimal installer with SSH access |

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

10. Clean up temporary key material:

    ```bash
    just clean-keys
    ```

### Updating a deployed host

```bash
just update <hostname> <user@target>
```
