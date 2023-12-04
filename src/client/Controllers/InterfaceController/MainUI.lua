local TweenService = game:GetService("TweenService")

local MainUI = {}
MainUI.__index = MainUI

--- Creates a new MainUI
function MainUI.new(gui)
	local self = setmetatable({}, MainUI)
	self.GUI = gui
	self.WaveCounter = gui:WaitForChild("WaveCounter")
	self.TimeCounter = gui:WaitForChild("TimeCounter")
	self.WaveStarts = gui:WaitForChild("WaveStarts")
	self:InitializeUI()
	return self
end

--- Initializes the UI
function MainUI:InitializeUI()
	self.WaveCounter.Text = "Wave: 0"
	self.TimeCounter.Text = "Time: 0:00"
	self.WaveStarts.Visible = false
end

--- Updates the wave counter
function MainUI:UpdateWaveCounter(waveNumber)
	self.WaveCounter.Text = "Wave: " .. waveNumber
end

--- Updates the time counter
function MainUI:UpdateTimeCounter(time)
	self.TimeCounter.Text = "Time: " .. time
end

--- Animates the wave starts text
function MainUI:AnimateWaveStarts()
	self.WaveStarts.Text = "New Wave Starting!"
    self.WaveStarts.Visible = true
	local fadeIn = TweenService:Create(self.WaveStarts, TweenInfo.new(0.2), { TextTransparency = 0 })
	local fadeOut = TweenService:Create(self.WaveStarts, TweenInfo.new(0.2), { TextTransparency = 1 })

	fadeIn:Play()
	fadeIn.Completed:Wait() -- Wait for the fade-in to complete
	task.wait(1 :: number) -- Wait for a moment before fading out

	fadeOut.Completed:Connect(function()
		self.WaveStarts.Visible = false
	end)
	fadeOut:Play()
end

return MainUI
