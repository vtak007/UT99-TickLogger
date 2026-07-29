// TickRateLogger.uc
// Rev 2
//
// Purpose:
//   Lightweight server-side tick logger for UT99 / 469e.
//   Logs real elapsed tick timing and includes active player count
//   so you can identify populated periods directly from server.log.
//
// Install target:
//   Compile into TickLogger.u and load as a ServerActor.
//
// Notes:
//   This actor is intended for diagnostics only.
//   It keeps overhead low by batching log writes.

class TickRateLogger expands Info
    config(TickLogger);

var config bool bEnabled;
var config int  LogEveryNTicks;
var config int  SummaryEveryNTicks;
var config bool bLogIndividualSamples;

var int   TickCount;
var float StartTime;
var float LastTime;
var float DeltaSum;
var float MinDelta;
var float MaxDelta;

event PreBeginPlay()
{
    Super.PreBeginPlay();

    if (!bEnabled)
    {
        Log("TickRateLogger Rev 2 disabled via config.", 'TickLogger');
        Destroy();
        return;
    }

    TickCount = 0;
    StartTime = Level.TimeSeconds;
    LastTime  = Level.TimeSeconds;
    DeltaSum  = 0.0;
    MinDelta  = 999999.0;
    MaxDelta  = 0.0;

    Log("TickRateLogger Rev 2 started.", 'TickLogger');
    Log("Settings:"
        @ "LogEveryNTicks=" $ string(LogEveryNTicks)
        @ "SummaryEveryNTicks=" $ string(SummaryEveryNTicks)
        @ "bLogIndividualSamples=" $ string(bLogIndividualSamples),
        'TickLogger');
}

event Tick(float DeltaTime)
{
    local float NowTime;
    local float RealDelta;
    local float AvgDelta;
    local float AvgTickRate;
    local float Elapsed;

    Super.Tick(DeltaTime);

    TickCount++;
    NowTime = Level.TimeSeconds;
    RealDelta = NowTime - LastTime;
    LastTime = NowTime;

    DeltaSum += RealDelta;

    if (RealDelta < MinDelta)
        MinDelta = RealDelta;

    if (RealDelta > MaxDelta)
        MaxDelta = RealDelta;

    if (bLogIndividualSamples && LogEveryNTicks > 0 && (TickCount % LogEveryNTicks) == 0)
    {
        Log("Sample"
            @ "Players=" $ string(CountActivePlayers())
            @ "Tick=" $ string(TickCount)
            @ "Delta=" $ string(RealDelta)
            @ "TickRate=" $ string(SafeRate(RealDelta)),
            'TickLogger');
    }

    if (SummaryEveryNTicks > 0 && (TickCount % SummaryEveryNTicks) == 0)
    {
        AvgDelta = DeltaSum / float(TickCount);
        AvgTickRate = SafeRate(AvgDelta);
        Elapsed = NowTime - StartTime;

        Log("Summary"
            @ "Players=" $ string(CountActivePlayers())
            @ "Ticks=" $ string(TickCount)
            @ "Elapsed=" $ string(Elapsed)
            @ "AvgDelta=" $ string(AvgDelta)
            @ "AvgTickRate=" $ string(AvgTickRate)
            @ "MinDelta=" $ string(MinDelta)
            @ "MaxDelta=" $ string(MaxDelta),
            'TickLogger');
    }
}

function float SafeRate(float Delta)
{
    if (Delta <= 0.0)
        return 0.0;

    return 1.0 / Delta;
}

function int CountActivePlayers()
{
    local Pawn P;
    local int Count;

    Count = 0;

    ForEach AllActors(class'Pawn', P)
    {
        if (PlayerPawn(P) != None && !P.bDeleteMe)
            Count++;
    }

    return Count;
}

defaultproperties
{
    bHidden=True
    RemoteRole=ROLE_None

    bEnabled=True
    LogEveryNTicks=100
    SummaryEveryNTicks=500
    bLogIndividualSamples=False
}