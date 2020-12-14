local Run = game:service("RunService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local pellet = script.Parent
pellet.Name = "Pellet"
local damage = 16
local tag = pellet:FindFirstChild("creator")
local fTag = pellet:WaitForChild("FeedTag")

local SurfaceLight = Instance.new("PointLight",pellet)
SurfaceLight.Brightness = .5
SurfaceLight.Color = pellet.BrickColor.Color

function TagHumanoid(humanoid)	
	if tag then
		local new_tag = tag:Clone()
		new_tag.Parent = humanoid
		
		local feed_tag = fTag:Clone()
		feed_tag.Parent = humanoid
		
		Debris:AddItem(new_tag, 1.5)
		Debris:AddItem(feed_tag, 1.5)
	end
end

function onTouched(hit)
	if hit and hit.Parent then
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		if hit.Parent:FindFirstChild("ForceField") or hit.Parent:FindFirstChild("Forcefield") then
			pellet:Destroy()
			return
		end
		if humanoid and humanoid.Health > 0 then
			TagHumanoid(humanoid)
			humanoid:TakeDamage(damage)
		else
			
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