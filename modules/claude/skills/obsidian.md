---
name: obsidian
description: Read, search, create, and edit notes in the Obsidian vault.
version: 1.0.0
author: Teknium (teknium1), Hermes Agent
license: MIT
---

# Obsidian Vault

Use this skill for filesystem-first Obsidian vault work: reading notes, listing notes, searching note files, creating notes, appending content, and adding wikilinks.

## Vault path

The vault is at `@vaultPath@`. Pass that concrete absolute path to `Read`, `Write`, `Edit`, `Glob`, and `Grep`.

Vault paths may contain spaces, which is another reason to prefer file tools over shell commands.

## Read a note

Use `Read` with the absolute path to the note. Prefer this over `cat` because it provides line numbers and pagination.

## List notes

Use `Glob` with the vault path as `path`. Prefer this over `find` or `ls`.

- To list all markdown notes, use `pattern: "**/*.md"` under the vault path.
- To list a subfolder, search under that subfolder's absolute path.

## Search

Use `Glob` and `Grep` for both filename and content searches. Prefer these over `grep`, `find`, or `ls`.

- For filenames, use `Glob` with a filename `pattern`.
- For note contents, use `Grep` with the content regex as `pattern` and `glob: "*.md"` when you want to restrict matches to markdown notes.

## Create a note

Use `Write` with the absolute path and the full markdown content. Prefer this over shell heredocs or `echo` because it avoids shell quoting issues and returns structured results.

## Append to a note

Prefer a native file-tool workflow when it is not awkward:

- Read the target note with `Read`.
- Use `Edit` for an anchored append when there is stable context, such as adding a section after an existing heading or appending before a known trailing block.
- Use `Write` when rewriting the whole note is clearer than constructing a fragile edit.

For an anchored append with `Edit`, replace the anchor with the anchor plus the new content.

For a simple append with no stable context, `Bash` is acceptable if it is the clearest safe option.

## Targeted edits

Use `Edit` for focused note changes when the current content gives you stable context. Prefer this over shell text rewriting.

## Wikilinks

Obsidian links notes with `[[Note Name]]` syntax. When creating notes, use these to link related content.
