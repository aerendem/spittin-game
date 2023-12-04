-- Roblox Service
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Dependencies
local Knit = require(ReplicatedStorage.Packages.knit)
local MainUI = require(script.MainUI)

-- Definitions
local Player = game.Players.LocalPlayer
local InterfaceController = Knit.CreateController({ Name = "InterfaceController" })
InterfaceController.UI = nil

local Events = ReplicatedStorage.Events
local GameRoundUpdate = Events.GameRoundUpdate
local WaveUpdate = Events.WaveUpdate
local TimerUpdate = Events.TimerUpdate

--- Listens to events from server and updates UI accordingly
function InterfaceController:ListenEvents()
	GameRoundUpdate.OnClientEvent:Connect(function(action, waveNumber, time, monstersDestroyed)
		--Maybe could do more animations here
		--Not gonna do as it's past 8 hour mark
		--Just putting as to show have more options
	end)
	TimerUpdate.OnClientEvent:Connect(function(time)
		self.UI:UpdateTimeCounter(time)
	end)
	WaveUpdate.OnClientEvent:Connect(function(waveNumber)
		self.UI:AnimateWaveStarts()
		self.UI:UpdateWaveCounter(waveNumber)
	end)
end

function InterfaceController:KnitStart()
	-- When the game UI is loaded and ready
	self.UI = MainUI.new(Player.PlayerGui:WaitForChild("Main")) -- Replace 'YourGameUI' with your actual UI name

	InterfaceController:ListenEvents()
end

return InterfaceController
