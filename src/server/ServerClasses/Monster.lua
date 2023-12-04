-- Roblox Services
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Dependencies
local Spit = require(script.Parent.Spit)
Spit.InitializePool(50) -- Initialize with 50 spit objects in the pool

-- Definitions
local Assets: Folder = ReplicatedStorage:WaitForChild("Assets")

local Monster = {}
Monster.__index = Monster

export type Monster = {
	Model: Model,
	IsAlive: boolean,
	HealthChanged: RBXScriptSignal,
}

local SPIT_INTERVAL: number = 3 -- Spit every 3 seconds

-- Methods

--- Creates a new monster
function Monster.new(spawnCFrame: CFrame, target: Model): Monster
	local self = setmetatable({}, Monster)
	self.Model = Assets:WaitForChild("SpittingMonster"):Clone() :: Model
	self.IsAlive = true
	self.SpittingEnabled = false
	self.SpittingRoutine = nil
	self.SpitTarget = target
	self.MovingEnabled = false
	self.MoveRoutine = nil

	self.Model:SetAttribute("Health", 100)
	CollectionService:AddTag(self.Model, "Monster")

	self.Model:PivotTo(spawnCFrame)

	self.Model.Parent = workspace:FindFirstChild("SpawnedMonsters")

	-- Listen for changes in the Health attribute
	self.HealthChanged = self.Model:GetAttributeChangedSignal("Health"):Connect(function()
		self:CheckHealth()
	end)

	self:StartSpitting()
	self:MoveToTarget(0.01)
	return self
end

-- Method to start moving towards the target
function Monster:MoveToTarget(speed: number)
	if not self.IsAlive or self.MovingEnabled then
		return
	end
	self.MovingEnabled = true

	self.MoveRoutine = coroutine.wrap(function()
		while self.MovingEnabled and self.IsAlive and self.SpitTarget and self.Model do
			local currentPosition = self.Model:GetPivot().Position
			local targetPosition = self.SpitTarget:GetPivot().Position
			local direction = (targetPosition - currentPosition).Unit
			local newPosition = currentPosition + direction * speed

			local lookVector = Vector3.new(direction.x, 0, direction.z) -- Zero out the y component to keep the monster upright
			local newCFrame = CFrame.lookAt(newPosition, currentPosition + lookVector)

			-- Check if the monster has reached the target
			if (newPosition - targetPosition).magnitude < 1 then
				break -- Stop moving if the monster is close enough to the target
			end

			self.Model:PivotTo(newCFrame)

			task.wait()
			RunService.Heartbeat:Wait()
		end
	end)

	self.MoveRoutine()
end

--- Stops the monster from moving
function Monster:StopMoving()
	self.MovingEnabled = false
end

--- Starts the monster spitting
function Monster:StartSpitting()
	if not self.IsAlive or self.SpittingEnabled then
		return
	end

	self.SpittingEnabled = true

	self.SpittingRoutine = coroutine.wrap(function()
		while self.SpittingEnabled and self.IsAlive and self.SpitTarget do
			self:Spit(self.SpitTarget:GetPivot().Position)
			task.wait(SPIT_INTERVAL) -- Spit every pre-defined interval
		end
	end)
	self.SpittingRoutine()
end

--- Stops the monster from spitting
function Monster:StopSpitting()
	self.SpittingEnabled = false
end

--- Spits at the target
function Monster:Spit(targetPos: Vector3)
	local spitProjectile = Spit.new(self.Model.Head.Mouth, targetPos, 10, 100) -- Damage and force can be adjusted
	spitProjectile:Launch()
end

function Monster:CheckHealth()
	local health = self.Model:GetAttribute("Health")
	if health <= 0 then
		self.IsAlive = false
		self:OnDeath()
	end
end

function Monster:OnDeath()
	-- Handle the monster's death (e.g., remove from the game, play animation)
	task.spawn(function()
		-- Animate the monster to fade out
		for _, part in ipairs(self.Model:GetChildren()) do
			if part:IsA("BasePart") then
				local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
				local goals = { Transparency = 1, Color = Color3.new(1, 1, 1) }
	
				local tween = TweenService:Create(part, tweenInfo, goals)
				tween:Play()
			end
		end

		self:Destroy()
	end)
end

--- Applies damage to the monster
function Monster:TakeDamage(amount: number)
	local currentHealth = self.Model:GetAttribute("Health") or 0
	self.Model:SetAttribute("Health", currentHealth - amount)
end

--- Destroys the monster
function Monster:Destroy()
	self.SpittingEnabled = false
	self.MovingEnabled = false
	self.IsAlive = false

	if self.SpittingRoutine then
		self.SpittingRoutine = nil
	end

	if self.MoveRoutine then
		self.MoveRoutine = nil
	end

	if self.HealthChanged then
		self.HealthChanged:Disconnect()
	end

	if self.Model then
		self.Model:Destroy()
	end

end

return Monster
