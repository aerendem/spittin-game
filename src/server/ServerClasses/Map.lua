-- Map class definition
local Map = {}
Map.__index = Map

function Map.new(userId: number)
	local self = setmetatable({}, Map)

	--Find empty map from workspace.Maps
	local chosenMap: Folder

	for _, mapFolder in pairs(workspace.Maps:GetChildren()) do
		local owned = mapFolder:GetAttribute("Owned")
        local owner = mapFolder:GetAttribute("Owner")
		if not owned or owner == userId then
			chosenMap = mapFolder
			break
		end
	end

	self.folder = chosenMap

	-- Initialize map properties
	self.folder:SetAttribute("Owned", true)
	self.folder:SetAttribute("Owner", userId)

	return self
end

function Map:Destroy()
	self.folder:SetAttribute("Owned", false)
    self.folder:SetAttribute("Owner", nil)
end

return Map
