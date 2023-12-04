-- Roblox Services
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

-- Dependencies
local Knit = require(ReplicatedStorage.Packages.knit)

-- Definitions
local Assets = ReplicatedStorage.Assets
local PlayerSpitService = Knit.CreateService({ Name = "PlayerSpitService" })

-- Methods

function PlayerSpitService.Client:Spit(player, spitPosition, targetPosition)
	--Check distance between character and spitposition to prevent spitting through walls
	local distance = (player.Character.Head.Position - spitPosition).magnitude
	if distance > 10 then
		return
	end

	-- Create a spit projectile
	local spit = Assets:FindFirstChild("PlayerSpit"):Clone()
	spit.Position = spitPosition
	spit.Anchored = false
	spit.CanCollide = false
	spit.Parent = workspace

	-- Apply physics to the spit (example: simple linear motion towards target)
	local direction = (targetPosition - spitPosition).unit
	local speed = 500 -- Adjust speed as needed
	spit.Velocity = direction * speed

	-- Handle collision detection
	spit.Touched:Connect(function(hit)
		self.Server:OnSpitHit(hit, spit)
	end)

	-- Cleanup the spit after some time
	Debris:AddItem(spit, 5) -- Adjust time as needed
end

function PlayerSpitService:OnSpitHit(hit, spit)
	if hit:IsA("BasePart") and CollectionService:HasTag(hit.Parent, "Monster") then
		-- Apply damage to the monster
		hit.Parent:SetAttribute("Health", hit.Parent:GetAttribute("Health") - 100)
        spit:Destroy()
	end
end

function PlayerSpitService:KnitStart()
	-- Initialization...
end

return PlayerSpitService
