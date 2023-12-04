-- Roblox Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Importing the Knit framework and types
local Knit = require(ReplicatedStorage.Packages.knit)
local Round = require(ServerScriptService.ServerClasses.Round) -- Require the Round class

-- Define the GameService class
local GameService = Knit.CreateService({
	Name = "GameService",
	Client = {
		RequestRestartRound = Knit.CreateSignal(),
	},
	PlayerRounds = {}, -- Table to keep track of individual player rounds
})

-- Function to start a round for a specific player
function GameService:StartRoundForPlayer(player: Player)
	local newRound = Round.new(player)
	self.PlayerRounds[player.UserId] = newRound
	self.PlayerRounds[player.UserId]:Start()

	self.PlayerRounds[player.UserId].Completed:Connect(function(isVictory: boolean)
		--- Here we can do something with the isVictory boolean
		--- Most likely would be a nice way to send client event to do animations
		if isVictory then
			-- Handle victory logic
		else
			-- Handle defeat logic
		end
	end)
end

-- Constructor for the service
function GameService:KnitInit()
	--- Here we can do some initialization logic
	Players.PlayerAdded:Connect(function(player)
		self:StartRoundForPlayer(player)
	end)

	--Let do cleanup when player leave
	Players.PlayerRemoving:Connect(function(player)
		if self.PlayerRounds[player.UserId] then
			self.PlayerRounds[player.UserId]:Destroy()
		end
	end)
end

return GameService
