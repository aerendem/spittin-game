local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Wait for game assets to load
if not game:IsLoaded() then
	game.Loaded:Wait()
end

local Knit = require(ReplicatedStorage.Packages:WaitForChild("knit"))

--Add controllers and boot up Knit
Knit.AddControllers(script.Parent:WaitForChild("Controllers"))

Knit.Start({ ServicePromises = false })
	:andThen(function()
		print("Client started!")
	end)
	:catch(warn)
