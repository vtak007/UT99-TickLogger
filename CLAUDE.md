# UT99 TickLogger — Project Instructions

Server-side tick-rate diagnostics logger for UT99 (469e). See `readme.md` for full details.
Follow the shared rules in `../CLAUDE.md` and the global `~/.claude/CLAUDE.md`; do not
duplicate them here.

## Key Files

| File | Purpose |
|---|---|
| `Classes/TickRateLogger.uc` | The ServerActor source — measures real tick deltas, counts active players, writes summary/sample lines to `server.log`. |
| `Classes/TickLogger.ini` | Default config values for the `[TickLogger.TickRateLogger]` section. |
| `readme.md` | Capabilities, configuration, install, and usage documentation. |
| `MEMORY.md` | Persistent project memory (root causes, ruled-out theories, conventions). |

## Project Notes

- This is a **ServerActor** (`expands Info`), loaded via `ServerActors=TickLogger.TickRateLogger`
  under `[Engine.GameEngine]` — **not** a mutator, and no `ServerPackages` entry is needed
  (`RemoteRole=ROLE_None`, server-side only).
- Compile `Classes/TickRateLogger.uc` into `TickLogger.u` with `ucc make`
  (`EditPackages=TickLogger`) and place the package in the server's `System\` folder.
