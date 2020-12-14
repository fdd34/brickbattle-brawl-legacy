local Run = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local Ball = script.Parent
local Boing = Ball:WaitForChild("Boing")
local Tag = Ball:WaitForChild("creator")
local Damage = 25
local lastSoundTime = Run.Stepped:wait()

function TagHumanoid(humanoid)	
	if Tag then
		local new_tag = Tag:Clone()
		new_tag.Parent = humanoid
		Debris:AddItem(new_tag, 2)
	end
end

function onTouched(hit)
	if hit and hit.Parent then 
		local now = Run.Stepped:wait()
		if (now - lastSoundTime > .1) then
			Boing:play()
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
		if hitHum then
			if hit.Parent == Tag.Value.Character then
				Ball:Destroy()
				return
			end
			if Players:GetPlayerFromCharacter(hit.Parent) then
				local hitPlayer = Players:GetPlayerFromCharacter(hit.Parent)
				if hitPlayer:FindFirstChild("Status") then
					if hitPlayer.Status.Value == "AtSpawn" then
						Ball:Destroy()
						return
					end
				end
				if hitPlayer.TeamColor == Tag.Value.TeamColor and not hitPlayer.Neutral then
					Ball:Destroy()
					return
				end
			end
			
			TagHumanoid(hitHum)		
			hitHum:TakeDamage(Damage)	
			Ball:Destroy()
		end
	end
end

connection = Ball.Touched:connect(onTouched)
t, s = Run.Stepped:wait()
d = t + 5.0 - s
while t < d do
	t = Run.Stepped:wait()
end

Ball:Destroy()