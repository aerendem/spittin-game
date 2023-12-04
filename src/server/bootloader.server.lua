local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.knit)

Knit.AddServices(script.Parent.Services)
Knit.Start():andThen(function()
    print("Server started")
end):catch(warn)
