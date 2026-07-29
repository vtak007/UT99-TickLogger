# UT99 TickLogger

A lightweight, server-side **tick-rate diagnostics logger** for Unreal Tournament 99
(tested against the 469e patch). It records real elapsed tick timing to `server.log`
along with the number of active players, so you can correlate server performance with
how populated the game was — directly from the log, with no external tooling.

> **What kind of mod is this?** `TickRateLogger` is a **server-side actor** (commonly
> just called a **ServerActor**) — `class TickRateLogger expands Info`, spawned at server
> startup via the `[Engine.GameEngine] ServerActors=` list. It is **not** a mutator: it
> doesn't hook the mutator (`Mutator=`) chain and has no gameplay effect. Because it's
> `RemoteRole=ROLE_None` it runs entirely on the server, so it's safe to run alongside any
> gametype or mutators and clients need nothing to connect.

## Capabilities

- **Real tick-delta measurement.** Every tick it measures the actual elapsed time
  (`Level.TimeSeconds` delta), not the engine-reported `DeltaTime`, giving you a true
  picture of server hitching and frame pacing.
- **Active player count.** Each logged line includes a live count of `PlayerPawn`s, so
  populated periods are obvious when reading back the log.
- **Rolling statistics.** Tracks average delta, min delta, max delta, average tick rate
  (ticks/second), and total elapsed time since startup.
- **Two log modes, independently controllable:**
  - *Summary lines* — periodic aggregate stats (default every 500 ticks).
  - *Individual samples* — per-tick snapshots (default every 100 ticks, **off** by default).
- **Low overhead.** Logging is throttled to the configured intervals so it stays cheap
  enough to leave running on a live server.
- **Runtime toggle.** Can be disabled entirely via config without recompiling — when
  disabled it destroys itself at startup and logs a single notice.

### Log output format

Summary line (example):

```
TickLogger: Summary Players=6 Ticks=500 Elapsed=18.34 AvgDelta=0.0367 AvgTickRate=27.25 MinDelta=0.0281 MaxDelta=0.1120
```

Individual sample line (only when `bLogIndividualSamples=True`):

```
TickLogger: Sample Players=6 Tick=100 Delta=0.0355 TickRate=28.17
```

All lines are tagged with the `TickLogger` log category, so you can filter the server
log with e.g. `findstr TickLogger server.log`.

## Configuration

Settings live under the `[TickLogger.TickRateLogger]` section (see `Classes/TickLogger.ini`)
and are read from the server's `.ini` at startup:

| Setting | Default | Meaning |
|---|---|---|
| `bEnabled` | `True` | Master on/off. If `False`, the actor destroys itself at startup. |
| `LogEveryNTicks` | `100` | Interval (in ticks) for individual sample lines. |
| `SummaryEveryNTicks` | `500` | Interval (in ticks) for summary stat lines. |
| `bLogIndividualSamples` | `False` | Enable per-tick sample logging. Leave off for lower log volume. |

Set an interval to `0` to disable that log type entirely.

## Installation

1. **Compile the class into a package.** Place `Classes/TickRateLogger.uc` under a
   `TickLogger\Classes\` folder in your UT99 directory and build it into `TickLogger.u`
   (via `ucc make`, using an `EditPackages=TickLogger` entry in your build config).
   Put the resulting `TickLogger.u` in the server's `System\` folder.

2. **Register it as a ServerActor.** In the server's `UnrealTournament.ini` (or the
   `.ini` the server is launched with), under `[Engine.GameEngine]`, add:

   ```ini
   ServerActors=TickLogger.TickRateLogger
   ```

3. **Add the config section.** Add the contents of `Classes/TickLogger.ini` to the same
   server `.ini` (or ensure the `[TickLogger.TickRateLogger]` section exists):

   ```ini
   [TickLogger.TickRateLogger]
   bEnabled=True
   LogEveryNTicks=100
   SummaryEveryNTicks=500
   bLogIndividualSamples=False
   ```

4. **(Optional) Add to `ServerPackages`.** Because this actor is server-side only with
   `RemoteRole=ROLE_None` and no replicated content, clients do **not** need the package,
   so a `ServerPackages=` entry is not required.

## Usage

1. Start the server. On startup you should see:

   ```
   TickLogger: TickRateLogger Rev 2 started.
   TickLogger: Settings: LogEveryNTicks=100 SummaryEveryNTicks=500 bLogIndividualSamples=False
   ```

   (or `TickRateLogger Rev 2 disabled via config.` if `bEnabled=False`).

2. Let the server run. Summary lines accumulate in `server.log` at the configured
   interval. Filter them out for analysis:

   ```
   findstr TickLogger server.log
   ```

3. To capture fine-grained per-tick data during an investigation, set
   `bLogIndividualSamples=True` and restart the server. Turn it back off afterwards to
   keep log size manageable.

## Files

| File | Purpose |
|---|---|
| `Classes/TickRateLogger.uc` | The ServerActor source — tick timing, player counting, and logging. |
| `Classes/TickLogger.ini` | Default config values for the `[TickLogger.TickRateLogger]` section. |
