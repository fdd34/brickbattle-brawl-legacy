local Run = game:service("RunService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local pellet = script.Parent
pellet.Name = "Pellet"
local damage = 25
local tag = pellet:WaitForChild("Creator")
local fTag = pellet:WaitForChild("FeedTag")

local SurfaceLight = Instance.new("PointLight",pellet)
SurfaceLight.Brightness = .5
SurfaceLight.Color = pellet.BrickColor.Color

function RemoveTagFromHumanoid(hum)
	for i,v in pairs(hum:GetChildren()) do
		if v:IsA("ObjectValue") or v:IsA("StringValue") then
			v:Destroy()
		end
	end	
end

function TagHumanoid(humanoid)	
	if tag then
		RemoveTagFromHumanoid(humanoid)
		
		wait(.1)
		
		local new_tag = tag:Clone()
		local feed_tag = fTag:Clone()
		
		new_tag.Parent = humanoid
		feed_tag.Parent = humanoid
		
		Debris:AddItem(new_tag, 2)
		Debris:AddItem(feed_tag, 2)
	end
end

function onTouched(hit)
	if hit and hit.Parent then
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		if hit.Parent:FindFirstChild("ForceField") or hit.Parent:FindFirstChild("Forcefield") then
			pellet:Destroy()
			return
		end
		if humanoid then
			TagHumanoid(humanoid)
			humanoid:TakeDamage(damage)
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