# shellcheck shell=bash
#
# Finds paths in the persistence store that no module declares, and offers to
# delete them. Anything left behind by a module that has since been removed is
# invisible otherwise: the ephemeral root hides it, and nothing reads it again.
#
# `declared`, `persist_bases` and `host_name` are injected ahead of this script
# by the Nix wrapper's runtimeEnv, which is why shellcheck cannot see where they
# are assigned.
# shellcheck disable=SC2154

usage() {
  echo "Find paths in the persistence store that are not declared for ${host_name}"
  echo "and optionally delete them."
  echo
  echo "USAGE: persist-cleanup [OPTIONS]"
  echo
  echo "OPTIONS:"
  echo "  -n, --dry-run   List the orphaned paths without offering to delete them"
  echo "  -h, --help      Show this help message and exit"
}

DRY_RUN=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    -n | --dry-run) DRY_RUN=1 ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "Error: unknown option: $1" >&2
      echo >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

if [[ $EUID -ne 0 ]]; then
  echo "Error: must be run as root" >&2
  exit 1
fi

# A path is needed if it is declared, sits under something declared, or is a
# parent of something declared.
is_needed() {
  local path="$1" d
  for d in "${declared[@]}"; do
    [[ "$path" == "$d" ]] && return 0
    [[ "$path" == "$d/"* ]] && return 0
    [[ "$d" == "$path/"* ]] && return 0
  done
  return 1
}

is_parent_only() {
  local path="$1" d
  for d in "${declared[@]}"; do
    [[ "$d" == "$path/"* ]] && return 0
  done
  return 1
}

orphans=()

# Descend only into directories that merely lead to a declared path, so a
# declared directory is reported as one entry instead of its whole subtree.
scan() {
  local dir="$1" entry
  while IFS= read -r -d "" entry; do
    if ! is_needed "$entry"; then
      orphans+=("$entry")
    elif [[ -d "$entry" ]] && is_parent_only "$entry"; then
      scan "$entry"
    fi
  done < <(find "$dir" -mindepth 1 -maxdepth 1 -print0 2>/dev/null || true)
}

for base in "${persist_bases[@]}"; do
  [[ -d "$base" ]] && scan "$base"
done

if [[ ${#orphans[@]} -eq 0 ]]; then
  echo "Nothing to clean up — all paths in the persistence store are declared."
  exit 0
fi

echo "Orphaned paths in the persistence store not declared for ${host_name}:"
for o in "${orphans[@]}"; do
  echo "  $o"
done

if [[ "$DRY_RUN" -eq 1 ]]; then
  exit 0
fi

echo ""
read -r -p "Delete all of the above? [y/N] " confirm
if [[ "$confirm" == [yY]* ]]; then
  for o in "${orphans[@]}"; do
    rm -rf -- "$o"
    echo "Deleted: $o"
  done
  echo "Done."
else
  echo "Aborted."
fi
