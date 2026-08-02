# UT99 TickLogger — Project Memory

## CONFIRMED ROOT CAUSES
- (none yet)

## RULED-OUT THEORIES
- (none yet)

## PROJECT CONVENTIONS
- `TickRateLogger` is a **ServerActor** (`class TickRateLogger expands Info`), loaded via
  `ServerActors=TickLogger.TickRateLogger` under `[Engine.GameEngine]`. It is NOT a mutator.
- No `ServerPackages` entry required — `RemoteRole=ROLE_None`, server-side only, clients need nothing.
- Config lives in `[TickLogger.TickRateLogger]`; defaults mirror `Classes/TickLogger.ini`
  (bEnabled=True, LogEveryNTicks=100, SummaryEveryNTicks=500, bLogIndividualSamples=False).
- Build: `ucc make` with `EditPackages=TickLogger` → `TickLogger.u` into server `System\`.
- Pre-commit doc-update rule (global CLAUDE.md): update `readme.md`/`CLAUDE.md` only after
  the user has tested and approved the change.

## CHANGE LOG

Newest first. Format: `- YYYY-MM-DD — what changed`.

- 2026-08-02 — Added this Change Log section (UT99 convention).
