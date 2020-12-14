local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local updateInterval = .4
local currentColor = 1
local colors = {26, 21} 
local maxDamage = 100

local self = script.Parent
local Tag = self:WaitForChild("creator")
local tickSound = Instance.new("Sound",self)
tickSound.SoundId = "rbxasset://sounds\\clickfast.wav"

local explosionSound = Instance.new("Sound",self)
explosionSound.SoundId = "rbxasset://sounds\\Rocket shot.wav"
explosionSound.Volume = 1

function update()
	updateInterval = updateInterval * .9
	self.BrickColor = BrickColor.new(colors[currentColor])
	currentColor = currentColor + 1
	if (currentColor > 2) then 
		currentColor = 1 
	end
end

function TagHumanoid(humanoid)
	-- tag does not need to expire iff all explosions lethal	
	if Tag then
		local new_tag = Tag:Clone()
		new_tag.Parent = humanoid
		Debris:AddItem(new_tag,2)
	end
end

function blowUp()
	local explosion = Instance.new("Explosion")
	explosion.BlastRadius = 12
	explosion.BlastPressure = 1000000 -- these are really wussy units
	explosion.DestroyJointRadiusPercent = 0
	explosion.Position = self.Position
	explosionSound:Play()
	
	-- find instigator ta
	if Tag then
		explosion.Hit:connect(function(part, distance)  
			if part and part.Parent and part.Parent ~= Tag.Value.Character then
				local hitChar = part.Parent
				local hitHum = hitChar:FindFirstChild("Humanoid")
				
				local Forcefield =  hitChar:FindFirstChild("Forcefield") or  hitChar:FindFirstChild("ForceField") or nil
				if Forcefield then
					self:Destroy()
					return
				end
				local WallCreator = hitChar:FindFirstChild("WallCreator") or nil
				if WallCreator then
					if Tag.Value.TeamColor == WallCreator.Value.TeamColor and not Tag.Value.Neutral or Tag.Value == WallCreator.Value then
						return
					else
						for i,v in pairs(WallCreator:GetChildren()) do
							if v:IsA("BasePart") then
								v.Anchored = false
								v:BreakJoints()
							end
						end
					end
				end
				if hitHum then
					if Players:GetPlayerFromCharacter(hitChar) then
						local hitPlayer = Players:GetPlayerFromCharacter(hitChar)
						if hitPlayer:FindFirstChild("Status") then
							if hitPlayer.Status.Value == "AtSpawn" then
								explosion:Destroy()
								return
							end
						end
						if hitPlayer.TeamColor == Tag.Value.TeamColor and not hitPlayer.Neutral then
							return
						end
					end
					
					local distanceFactor = distance / explosion.BlastRadius
					TagHumanoid(hitHum)
					hitHum:TakeDamage(maxDamage * distanceFactor)
				end
			end
		end)
	end

	explosion.Parent = workspace
	self:Destroy()
end

while updateInterval > .1 do
	wait(updateInterval)
	update()	
	tickSound:play()	
end

blowUp()