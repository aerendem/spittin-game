local Types = {}

-- Can use unified types module to define types
-- And then use it in both server and client
-- This way we can avoid having to define types in both server and client

-- As an example
export type Round = {
    Player: Player,
    CurrentWave: number,
    TimeLeft: number,
    IsRoundActive: boolean,
    IsVictory: boolean,
    --Timer: Timer,
    MonsterCount: number,
    MonsterKilledCount: number,
    MonsterSpawned: BindableEvent,
    MonsterKilled: BindableEvent,
    MonsterCountChanged: BindableEvent,
    MonsterKilledCountChanged: BindableEvent,
    WaveUpdate: BindableEvent,
    TimerUpdate: BindableEvent,
}

return Types