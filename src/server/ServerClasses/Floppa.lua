-- Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Dependencies
local Signal = require(ReplicatedStorage.Packages.signal)

-- Definitions
local Assets = ReplicatedStorage.Assets

-- Define the Floppa class
local Floppa = {}
Floppa.__index = Floppa

-- Constructor function
function Floppa.new(spawnLocation: BasePart, parentTo: Instance, ownerId: number)
	local self = setmetatable({}, Floppa)
	self.Model = Assets:WaitForChild("Floppa"):Clone()
	self.Model:PivotTo(spawnLocation.CFrame)

	--- Setting the floppa's attributes
	local health = 1000
	self.Model:SetAttribute("Health", health)
	self.Model:SetAttribute("Damageable", true)
	self.MaxHealth = health
	self.IsAlive = true
	self.OwnerId = ownerId

	--- Fires when the floppa dies
	self.OnFloppaDeath = Signal.new()

	--- Setting the health label
	self.Model:FindFirstChild("HealthLabel", true).Text =  "Health: " .. tostring(health)

	-- Listening for health changes
	self.Model:GetAttributeChangedSignal("Health"):Connect(function()
		self:CheckHealth()
	end)

	--- Anchoring the floppa
    for _,v: BasePart in pairs(self.Model:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Anchored = true
        end
    end

    self.Model.Parent = parentTo

	return self
end

--- Applies damage to the floppa
function Floppa:TakeDamage(amount)
	if not self.IsAlive then
		return
	end

	local currentHealth = self.Model:GetAttribute("Health")
	self.Model:SetAttribute("Health", currentHealth - amount)
end

--- Checks if the floppa is dead
function Floppa:CheckHealth()
	local health = self.Model:GetAttribute("Health")

	self.Model:FindFirstChild("HealthLabel", true).Text =  "Health: " .. tostring(health)
	if health <= 0 then
		self.IsAlive = false
		self:OnDeath()
	end
end

--- Fires when the floppa dies
function Floppa:OnDeath()
	self.OnFloppaDeath:Fire()

	self:Destroy()
end

--- Regenerates the floppa's health
function Floppa:RegenerateHealth()
	self.Model:SetAttribute("Health", self.MaxHealth)
end

--- Destroys the floppa
function Floppa:Destroy()
	if self.OnFloppaDeath then
		self.OnFloppaDeath:Destroy()
	end

	self.Model.Parent = nil
	self = nil
end

return Floppa
