local Run = game:service("RunService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local pellet = script.Parent
pellet.Name = "Pellet"
local damage = 12
local tag = pellet:FindFirstChild("creator")

function TagHumanoid(humanoid)
	-- todo: make tag expire
	if tag then
		while(humanoid:FindFirstChild("creator")) do
			humanoid:FindFirstChild("creator").Parent = nil
		end

		local new_tag = tag:Clone()
		new_tag.Parent = humanoid
		Debris:AddItem(new_tag, 1)
	end
end

function onTouched(hit)
	if hit and hit.Parent then
		local humanoid = hit.Parent:FindFirstChild("Humanoid")if Forcefield then
			pellet:Destroy()
			return
		end
		if humanoid then
			TagHumanoid(humanoid)
			humanoid:TakeDamage(damage)
		else
			--[[
			damage = damage / 2
			if damage < 1 then
				connection:disconnect()
			end	
			--]]
		end
		pellet:Destroy()
	end
end

pellet.Touched:connect(onTouched)

t, s = Run.Stepped:wait()
d = t + 2.0 - s
while t < d do
	t = Run.Stepped:wait()
end

pellet:Destroy()