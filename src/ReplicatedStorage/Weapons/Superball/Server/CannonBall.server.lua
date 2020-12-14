local Run = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local Ball = script.Parent
local Boing = Ball:WaitForChild("Boing")
local Tag = Ball:WaitForChild("creator")
local fTag = Ball:WaitForChild("FeedTag")
local Damage = 20
local lastSoundTime = Run.Stepped:wait()

local SurfaceLight = Instance.new("PointLight",Ball)
SurfaceLight.Brightness = .8
SurfaceLight.Color = Ball.BrickColor.Color

function TagHumanoid(humanoid)	
	if Tag then
		local new_tag = Tag:Clone()
		new_tag.Parent = humanoid
		
		local feed_tag = fTag:Clone()
		feed_tag.Parent = humanoid
		
		Debris:AddItem(new_tag, 1.5)
		Debris:AddItem(feed_tag, 1.5)
	end
end

function onTouched(hit)
	if hit and hit.Parent then 
		local now = Run.Stepped:wait()
		if (now - lastSoundTime > .1) then
			Boing:Play()
			lastSoundTime = now
		else
			return
		end
		
		local hitHum = hit.Parent:FindFirstChild("Humanoid")
		local Forcefield = hit.Parent:FindFirstChild("Forcefield") or hit.Parent:FindFirstChild("ForceField") or nil
		if Forcefield then
			Ball:Destroy()
			return
		end
		if hitHum and hitHum.Health > 0 then
			if hit.Parent == Tag.Value.Character then
				Ball:Destroy()
				return
			else
				if Players:GetPlayerFromCharacter(hit.Parent) then
					local hitPlayer = Players:GetPlayerFromCharacter(hit.Parent)
					if hitPlayer.TeamColor == Tag.Value.TeamColor and hitPlayer.Neutral == false or hitPlayer.Status.Value == "AtSpawn" then
						Ball:Destroy()
						return
					end
				end
			end
			hitHum.Sit = true
			TagHumanoid(hitHum)		
			hitHum:TakeDamage(Damage)	
			Ball:Destroy()
		end
	end
end

connection = Ball.Touched:connect(onTouched)
wait(5)
if Ball == nil then
	-- do nothing
else
	Ball:Destroy()
end