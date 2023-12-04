local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets: Folder = ReplicatedStorage:WaitForChild("Assets")

local SpitPool = {} -- Pool for reusable spit objects

local Spit = {}
Spit.__index = Spit

-- Initialize the pool
function Spit.InitializePool(poolSize: number)
    for i = 1, poolSize do
        local spitObject = Assets:WaitForChild("Spit"):Clone()
        spitObject.Parent = workspace
        spitObject.Anchored = true -- Initially anchor the spit objects
        table.insert(SpitPool, spitObject)
    end
end

function Spit.new(sourceAttachment: Attachment, targetPos: Vector3, damage: number, forceMagnitude: number)
    local self = setmetatable({}, Spit)
    self.Source = sourceAttachment
    self.TargetPos = targetPos
    self.Damage = damage
    self.ForceMagnitude = forceMagnitude
    self.SpitObject = table.remove(SpitPool) -- Get an object from the pool
    return self
end

function Spit:ApplyForce()
    local spitForce = (self.TargetPos - self.SpitObject.Position).Unit * self.ForceMagnitude
    self.SpitObject.Velocity = spitForce
end

function Spit:SetCollisionGroup()
    PhysicsService:SetPartCollisionGroup(self.SpitObject, "SpitGroup")
end

function Spit:CalculateForce()
    local distance = (self.TargetPos - self.Source.WorldPosition).magnitude
    local forceMagnitude = distance * 10 -- Example calculation, adjust as needed
    return (self.TargetPos - self.Source.WorldPosition).Unit * forceMagnitude
end

function Spit:HandleCollision()
    self.SpitObject.Touched:Connect(function(part)
        if part.Parent and part.Parent:GetAttribute("Damageable") then
            local health = part.Parent:GetAttribute("Health")
            health = health - self.Damage
            part.Parent:SetAttribute("Health", health)
            self:Destroy()
        end
    end)
end

function Spit:Launch()
    self.SpitObject.Position = self.Source.WorldPosition
    self.SpitObject.Anchored = false

    local spitForce = self:CalculateForce()
    self.SpitObject.Velocity = spitForce
    --self:ApplyForce()
    self:SetCollisionGroup()
    self:HandleCollision()

    -- Return the spit object to the pool after a certain time
    task.wait(5)
    self:ReturnToPool()
end

function Spit:ReturnToPool()
    if self.SpitObject then
        self.SpitObject.Anchored = true
        self.SpitObject.CFrame = CFrame.new(-100000, -1000000, -100000) -- Move it out of sight
        table.insert(SpitPool, self.SpitObject)
        Spit:Destroy()
    end
end

function Spit:Destroy()
    self = nil
end
return Spit
