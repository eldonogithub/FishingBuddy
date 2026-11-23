# Fishing Buddy Eldon for Forever

Original author: Sutorix (Bob Schumaker). Retail upstream: https://github.com/r-log/FishingBuddy.
Forever compatibility baseline: crediar's Fishing Buddy Forever 1.0.11, CurseForge file 9656597.
Original author notices and bundled library licenses remain in their source files.

## Branches

- `main` mirrors `upstream/main` without local patches.
- `vendor/forever-1.0.11` records the installed Forever release separately from Retail upstream.
- `fixes/forever-eldon` contains our location statistics fix and renamed packaging.

The Retail repository is an upstream reference, not the source of crediar's releases.
Review incoming Retail changes for Forever compatibility before merging into the patch branch.
Future Forever release snapshots should be imported separately and merged into our branch.

## Build

Stage new files with Git before running the packaging script, which packages tracked files:

```powershell
./scripts/package-eldon.ps1 -OutputPath ../FishingBuddyEldon-build/FishingBuddyEldon
```

The generated addon uses FishingBuddyEldon filenames, paths, globals, and saved-variable
names. Its title is Fishing Buddy Eldon (Forever). Disable or remove the original addon
when installing. Copy account and character FishingBuddy.lua saved-variable files to
FishingBuddyEldon.lua, replacing FishingBuddy with FishingBuddyEldon in their contents,
while the game is closed. Back up the originals first.

Location rows show local catch counts. Fish percentages use their enclosing location's
total; subzones use their parent zone's total. In the fish-first view, locations show
their share of that fish's catches. Root rows show counts without a misleading global
percentage. Percentages describe recorded catches, not guaranteed future drop rates.

Renaming removes the original addon folder identity. CurseForge content fingerprinting
can still recognize forks; leave this addon unmanaged if the app associates it with the
original project.
