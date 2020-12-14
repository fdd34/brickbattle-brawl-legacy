local self = script.Parent
local Music = self:WaitForChild("Sound")
local Debounce = false

function ParticleEmitterHandler(value)
	if value then
		for i,v in pairs(script.Parent:GetChildren()) do
			if v:IsA("ParticleEmitter") then
				v.Enabled = value
			end
		end
	end
end

self.Touched:connect(function(hit)
	if hit and hit.Parent:FindFirstChild("Humanoid") and Debounce == false then
		Debounce = true
		Music:Play()
		ParticleEmitterHandler(true)
		wait(Music.TimeLength)
		ParticleEmitterHandler(false)
		wait(5)
		Debounce = false
	end
end)