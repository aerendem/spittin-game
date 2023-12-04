-- Roblox Service
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Dependencies
local Knit = require(ReplicatedStorage.Packages.knit)
local PlayerSpitService

-- Definitions
local SpitController = Knit.CreateController({ Name = "SpitController" })

SpitController.Cooldown = 3 -- Cooldown in seconds
SpitController.LastSpitTime = 0

function SpitController:KnitStart()
	PlayerSpitService = Knit.GetService("PlayerSpitService")

	UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then
			return
		end

		if input.KeyCode == Enum.KeyCode.Q and time() - self.LastSpitTime >= self.Cooldown then
			self.LastSpitTime = time()
			self:SendSpitRequest()
		end
	end)
end

function SpitController:SendSpitRequest()
	local player = game.Players.LocalPlayer
	if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
		return
	end

	local spitPosition = player.Character.HumanoidRootPart.Position
	local targetPosition = player:GetMouse().Hit.p

	PlayerSpitService:Spit(spitPosition, targetPosition)
end

return SpitController
