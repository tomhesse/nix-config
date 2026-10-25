# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A NixOS + home-manager flake for five machines, built with the **dendritic pattern**:
every file under `modules/` is a flake-parts module, auto-imported by `import-tree`.
There is no central module list — adding a file to `modules/` is enough to load it.

Hosts: `loki` (Framework 13 laptop), `tyr` (desktop), `mimir` (home server),
`installer` (ISO), `fenrir` (home-manager only, on Ubuntu/WSL).

## Commands

Everything needs the dev shell (`direnv` loads it automatically; otherwise `nix develop`).

```bash
pre-commit run --all-files          # format + lint (nixfmt, deadnix, statix, typos, shellcheck, ripsecrets, …)
nix fmt                             # nixfmt-tree only
nix run .#write-flake               # regenerate flake.nix after changing any flake-file.inputs
nix build .#checks.x86_64-linux.pre-commit .#checks.x86_64-linux.check-flake-file

# Evaluate configurations without building them (what CI does)
nix eval --json .#nixosConfigurations --apply 'cs: builtins.mapAttrs (_: c: c.config.system.build.toplevel.drvPath) cs'
nix eval --json .#homeConfigurations --apply 'cs: builtins.mapAttrs (_: c: c.activationPackage.drvPath) cs'

# Build a single host
nix build .#checks.x86_64-linux."configurations/nixos/loki"
nix build .#installer-iso

# Apply a configuration
nixos-rebuild switch --flake . --sudo       # local host
nixos-rebuild switch --flake .#<host> --build-host <user@target> \
  --target-host <user@target> --ask-sudo-password    # remote host, built there

just --list                                 # deployment/key recipes (see README.md)
```

`nix flake check` builds every host and is rarely what you want; prefer the `nix eval`
commands or a single-host build.

## Architecture

### Module classes

Each file declares modules under `flake.modules.<class>.<name>`, where class is
`nixos` or `homeManager`. They are consumed elsewhere as `self.modules.nixos.<name>` /
`self.modules.homeManager.<name>`. A single file commonly defines both classes for the
same concern (see `modules/sops/default.nix`, `modules/home-manager.nix`) — keep the
NixOS and home-manager halves of a feature in one file.

### Module ownership

The module is the unit of a **feature**, not of a program: configuration that exists
because of a feature lives in that feature's module, even when it sets options owned by
another program. `delta.nix` sets the pager for gh, gh-dash and lazygit;
`modules/claude/default.nix` sets the VS Code extension and its settings. Ask "why does
this line exist?", not "whose option is this?" — the test is whether the foreign lines
should disappear when the module is deleted.

Corollaries:

- **The owner never mentions its guests.** `vscode.nix` knows nothing about Claude,
  `git.nix` nothing about delta, `authelia.nix` nothing about immich.
- **A shared mechanism is used, it does not reach in.** Authelia, `notify-failure` and
  the unfree allowlist expose something others opt into (`authelia.oidc.clients.immich`,
  `onFailure = [ "notify-failure@%N.service" ]`, `allowedUnfree = [ "steam" ]`). The
  mechanism never lists its users, so it has to expose a mergeable option or attribute.
  Ask who decides: delta decides gh's pager; restic decides it wants alerts.
- **Host files stay thin.** A host sets what is specific to the machine (hostname,
  monitors, disks, which offsite account). Wiring that holds for every host running a
  feature belongs in the feature.
- **Reading is fine.** Reading another module's config is not a violation; only setting
  its options for reasons it does not own.

### Dependency imports

A module imports what it references by name and cannot run without: every container on
the `edge` network imports `self.modules.nixos.podman`, Authelia imports `nixos.lldap`,
Traefik imports `nixos.socket-proxy`, each Authelia-protected service imports
`nixos.authelia`. Soft references (Traefik labels) are not imports.

This only works because `modules/flake/modules.nix` gives every `flake.modules.*` a
module-system `key`, so repeated imports deduplicate instead of declaring the same
options twice. It is a local replacement for flake-parts' `flakeModules.modules`, which
leaves the key unset (`# TODO: set key?` upstream) — do not import both, and do not drop
the key.

### Role aggregation

Modules compose into roles, which hosts import:

```
base ← desktop ← (loki, tyr)
base ← server  ← mimir
base ← cli     ← fenrir (homeManager only)
```

`modules/base.nix`, `desktop.nix`, `server.nix`, `cli.nix` are pure import lists.
Put a new feature module in its own file, then add it to the right role — hosts should
only import roles plus host-specific modules.

### Hosts

`modules/hosts/<host>/default.nix` sets `configurations.nixos.<host>.module` (or
`configurations.home-manager.<host>.module` for `fenrir`). Those options are defined in
`modules/flake/configurations/`, which turn them into `nixosConfigurations` /
`homeConfigurations` and register per-host `checks`. A host file holds only: role
imports, host-specific module imports, `home-manager.users.<user>.imports`,
`hardware.facter.reportPath`, hostname, timezone, `system.stateVersion`.

Hardware is declared via `nixos-facter` (`facter.json`, regenerated by `just deploy`),
not `hardware-configuration.nix`. Disk layout lives in
`flake.diskoConfigurations.<host>` in `modules/hosts/<host>/disko.nix` and is imported
by the host as `self.diskoConfigurations.<host>`.

### Flake inputs

`flake.nix` is **generated** — never edit it. Each module declares the inputs it needs
inline via `flake-file.inputs.<name>`, colocated with the module that uses it (e.g.
`modules/sops/default.nix` declares `sops-nix`). After changing those, run
`nix run .#write-flake`; CI fails on drift via the `check-flake-file` check.

`nixpkgs` is the `nixos-26.05` release.

### Unfree packages

There is no global `allowUnfree`. A module that needs an unfree package adds the
package name to the flake-level `allowedUnfree` list at the top of its own file
(`modules/vscode.nix`, `modules/steam.nix`); `modules/nixpkgs.nix` turns that list into
`allowUnfreePredicate`.

### Secrets

sops-nix with age keys derived from SSH host keys (`just age-key`), plus a GPG key for
the human. Three scopes, each with its own rule in `.sops.yaml`:

- `modules/sops/secrets/nixos.yaml` — shared across all hosts
- `modules/sops/secrets/thesse.yaml` — shared user secrets (home-manager)
- `modules/hosts/<host>/secrets/nixos.yaml` — host-specific

Host-specific secrets are referenced with an explicit
`sopsFile = ./hosts/${config.networking.hostName}/secrets/nixos.yaml` (see
`modules/traefik.nix`). After editing `.sops.yaml`, run `just sops-rekey`.

### Impermanence

`loki` and `tyr` have an ephemeral btrfs root: the initrd rotates `@` into
`@old_roots/<timestamp>` on every boot (`modules/impermanence/default.nix`), so anything
not declared in `environment.persistence."/persistent"` or
`home.persistence."/persistent"` is lost. A new module that stores state must declare its
paths. Helpers on those hosts: `persist-cleanup --dry-run` (finds undeclared paths in the
store) and `btrfs-diff`. `mimir` has a persistent root and does not import
`self.modules.nixos.impermanence`.

### Server services (mimir)

Services are podman containers under `virtualisation.oci-containers.containers.<name>`,
on the `edge` network, routed by Traefik via docker labels, and fronted by Authelia +
lldap for SSO. Conventions visible across `modules/jellyfin.nix`, `arr.nix`,
`traefik.nix`:

- `domain = "shrimphouse.xyz"` as a local `let` binding per module
- a fixed `uid`, with a matching system user/group, and `tmpfiles.rules` for state dirs
- `systemd.services.podman-<name>` gets `after = [ "zfs-mount.service" ]` and
  `unitConfig.AssertPathIsMountPoint` for its `/srv` paths
- hardening: `capabilities.ALL = false`, `--read-only`, `--security-opt=no-new-privileges`
- `authelia.adminDomains = [ "<app>.${domain}" ]` to put a service behind SSO
- secrets reach containers through `sops.templates.*` + `environmentFiles`, with
  `restartUnits`

Image tags are plain pinned strings so Renovate's regex manager can bump them, and CI
verifies every tag still exists with skopeo. Keep the literal `"host/path:tag"` shape.

## Conventions

- Shared cross-host settings (monitor layout, unfree lists, persistence) go through
  custom flake-level or NixOS options rather than being repeated — see
  `modules/monitors.nix`, `modules/nixpkgs.nix`.
- `.pre-commit-config.yaml` is a store symlink; change hooks in
  `modules/flake/git-hooks.nix`.
- Claude Code's own settings for this machine are declared in `modules/claude/default.nix`
  (home-manager), not in `.claude/settings.json`.
- Commits are conventional with a module-name scope: `feat(claude): …`,
  `fix(networkmanager): …`, `chore(jellyfin): …`. Scope matches the module file name.
