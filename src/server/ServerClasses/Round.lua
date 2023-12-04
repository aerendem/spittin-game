-- Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Dependencies
local Signal = require(ReplicatedStorage.Packages.signal)
local Map = require(script.Parent.Map)
local Monster = require(script.Parent.Monster)
local Floppa = require(script.Parent.Floppa)
local Timer = require(ReplicatedStorage.Packages.timer)

-- Definitions
local Events = ReplicatedStorage.Events
local GameRoundUpdate = Events.GameRoundUpdate
local WaveUpdate = Events.WaveUpdate
local TimerUpdate = Events.TimerUpdate

-- Define the Round class
local Round = {}
Round.__index = Round

local VICTORY_WAVE = 10

-- Round constructor
function Round.new(player: Player)
	local self = setmetatable({}, Round)
	self.Player = player
	self.CurrentWave = 0
	self.IsRoundActive = false
	self.Completed = Signal.new() -- Signal to fire when the round is completed
	self.Timer = nil
	self.TimeLeft = 0
	self.Monsters = {}
	self.MonstersDestroyed = 0
	self.Score = 0
	self.IsVictory = false

	--Create(choose empty map)
	self.GameMap = Map.new(player.UserId)

	print("Round created for player " .. player.Name)
	return self
end

function Round:Start()
	self.IsRoundActive = true

	--Spawn floppa (vip)
	self.Floppa = Floppa.new(self.GameMap.folder:WaitForChild("FloppaSpawn"), self.GameMap.folder, self.Player.UserId)

	self.FloppaDeathConnection = self.Floppa.OnFloppaDeath:Connect(function()
		self.IsVictory = false
		self:RestartRound()
	end)

	self:StartNewWave()

	GameRoundUpdate:FireClient(self.Player, "START", self.CurrentWave, self.TimeLeft, self.MonstersDestroyed)
end

function Round:End()
	self.IsRoundActive = false
end

function Round:StartNewWave()
	print("Starting new wave for player " .. self.Player.Name)

	self.CurrentWave = self.CurrentWave + 1

	if self.CurrentWave > VICTORY_WAVE then
		self.IsVictory = true
		self:RestartRound()
		return
	end

	self.TimeLeft = self.CurrentWave * 5 -- 5 seconds per wave

	-- Wave update to client
	WaveUpdate:FireClient(self.Player, self.CurrentWave)

	local monsterSpawnTimestamps = {}

	local numberOfMonsters = self.CurrentWave
	local spawnInterval = self.TimeLeft / numberOfMonsters -- Adjust the total time of 5 seconds as needed

	for i = 1, numberOfMonsters do
		monsterSpawnTimestamps[i] = spawnInterval * (i - 1)
	end

	self.Timer = Timer.new(1)
	local connection

	connection = self.Timer.Tick:Connect(function()
		if self.IsRoundActive == false then
			self.Timer:Stop()
			self.Timer:Destroy()
		end

		self.TimeLeft -= 1

		TimerUpdate:FireClient(self.Player, self.TimeLeft)

		if monsterSpawnTimestamps[1] and self.TimeLeft >= monsterSpawnTimestamps[1] then
			table.remove(monsterSpawnTimestamps, 1)
			self:SpawnMonster()
		end

		if self.TimeLeft <= 0 then
			self.Timer:Stop()
			self.Timer:Destroy()
			connection:Disconnect()
			self:StartNewWave()
		end
	end)

	self.Timer:Start()
end

function Round:SpawnMonster()
	--Get random spawn point
	local spawnPoints = self.GameMap.folder:WaitForChild("MonsterSpawns"):GetChildren()
	local spawn = spawnPoints[math.random(1, #spawnPoints)]

	-- Example spawning logic
	local monster = Monster.new(spawn.CFrame, self.Floppa.Model) -- Pass the floppa model to the monster so it can spit at it

	table.insert(self.Monsters, monster)
end

function Round:RestartRound()
	print("Restarting round for player " .. self.Player.Name)

	-- Clean up the current round state
	self:End()

	-- Ensure all cleanup operations are complete before restarting
	task.wait(1) -- Adjust delay as needed for cleanup completion

	if self.FloppaDeathConnection then
        self.FloppaDeathConnection:Disconnect()
        self.FloppaDeathConnection = nil
    end

	self.Completed:Fire(self.IsVictory)

	-- Reinitialize round-related variables
	self.CurrentWave = 0
	self.IsRoundActive = false
	self.MonstersDestroyed = 0
	self.Score = 0
	self.IsVictory = false

	self.GameMap:Destroy()
	self.Floppa:Destroy()

	if self.Timer then
		self.Timer:Stop()
		self.Timer:Destroy()
	end

	-- Destroy all monsters in the round
	for _, monster in ipairs(self.Monsters) do
		monster:Destroy()
	end

	self.Monsters = {}

	-- Recreate the map and floppa
	self.GameMap = Map.new(self.Player.UserId)

	-- Start the round again
	self:Start()
end

-- Destroy function for the Round
function Round:Destroy()
	print("Round destroyed for player " .. self.Player.Name)
	self.IsRoundActive = false

	self.GameMap:Destroy()
	self.Floppa:Destroy()

	-- Destroy all monsters in the round
	for _, monster in ipairs(self.Monsters) do
		monster:Destroy()
	end

	self.Monsters = {}

	-- Clean up any additional resources or connections
	self.Completed:Destroy()
end

return Round
