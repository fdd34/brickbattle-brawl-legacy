local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local updateInterval = .4
local currentColor = 1
local currentTexture = 1
local colors = {26, 21} 
local textures = {94691681,98261349}
local lightenabled = {false,true}

local self = script.Parent
local Tag = self:WaitForChild("creator")
local fTag = self:WaitForChild("FeedTag")
local tickSound = Instance.new("Sound",self)
local surfaceLight = self:WaitForChild("PointLight")
tickSound.SoundId = "rbxasset://sounds\\clickfast.wav"

local explosionSound = Instance.new("Sound",self)
explosionSound.SoundId = "rbxasset://sounds\\Rocket shot.wav"
explosionSound.Volume = 1

local Mesh = self:FindFirstChild("Mesh")
local BLAST_RADIUS = 35 -- Blast radius of the explosion
local BLAST_DAMAGE = 130 -- Amount of damage done to players
local BLAST_FORCE = 5000 -- Amount of force applied to parts

function update()
	if Mesh then
		updateInterval = updateInterval * .9
		Mesh.TextureId = "rbxassetid://"..textures[currentTexture]
		surfaceLight.Enabled = lightenabled[currentTexture]
		currentTexture = currentTexture + 1
		if (currentTexture > 2) then 
			currentTexture = 1 
		end
	else
		updateInterval = updateInterval * .9
		self.BrickColor = BrickColor.new(colors[currentColor])
		surfaceLight.Enabled = lightenabled[currentTexture]
		currentColor = currentColor + 1
		if (currentColor > 2) then 
			currentColor = 1 
		end
	end
end

local fTag = self:WaitForChild("FeedTag")
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

function FindCharacterAncestor(subject)
	if subject and subject ~= workspace then
		local humanoid = subject:FindFirstChild('Humanoid')
		if humanoid then
			return subject, humanoid
		else
			return FindCharacterAncestor(subject.Parent)
		end
	end
	return nil
end

function OnExplosionHit(hitPart, hitDistance, blastCenter)
	if hitPart and hitDistance then
		local character, humanoid = FindCharacterAncestor(hitPart.Parent)
		
		local WallCreator = hitPart.Parent:FindFirstChild("WallCreator") or nil
		if WallCreator then
			print("[Rocket] Found wall.")
			if WallCreator.Value.Name ~= "Wall" then 
				if Tag.Value.TeamColor == WallCreator.Value.TeamColor and not Tag.Value.Neutral or Tag.Value == WallCreator.Value then
					return
				end
			else
				print("[Rocket] Breaking the wall.")
				for i,v in pairs(hitPart.Parent:GetChildren()) do
					if v:IsA("BasePart") then
						v.Anchored = false
						v.Locked = false
						v:BreakJoints()
						Debris:AddItem(v,3)
					end
				end
			end
		end
		
		local CanDestroy = hitPart.Parent:FindFirstChild("CanDestroy")
		if CanDestroy then
			print("[Rocket] Breaking the wall.")
			for i,v in pairs(hitPart.Parent:GetChildren()) do
				if v:IsA("BasePart") then
					v.Anchored = false
					v.Locked = false
					v:BreakJoints()
					Debris:AddItem(v,3)
				end
			end
		end
		
		local hitPlayer = Players:GetPlayerFromCharacter(character)
		if hitPlayer and hitPlayer:FindFirstChild("Status") then
			if hitPlayer.Status.Value == "AtSpawn" then
				self:Destroy()
				return
			end
		end
		
		if character then
			local myPlayer = Tag.Value
			if myPlayer and not myPlayer.Neutral then -- Ignore friendlies caught in the blast
				if myPlayer.Character == character then return end
				local player = Players:GetPlayerFromCharacter(character)
				--[[if player and player ~= myPlayer and player.TeamColor == self.BrickColor then
					return
				end]]
			end
		end
		
		if humanoid and humanoid.Health > 0 then -- Humanoids are tagged and damaged
			if hitPart.Name == 'Torso' then
				TagHumanoid(humanoid)
				local distanceFactor = hitDistance / BLAST_RADIUS
				distanceFactor = 1 - distanceFactor
				if Tag.Value.Name == hitPart.Parent.Name then
					BLAST_DAMAGE = BLAST_DAMAGE / 2
				end
				humanoid:TakeDamage(BLAST_DAMAGE * distanceFactor)
				
				local blastForce = Instance.new('BodyForce', hitPart) --NOTE: We will multiply by mass so bigger parts get blasted more
				blastForce.force = (hitPart.Position - blastCenter).unit * BLAST_FORCE * hitPart:GetMass()
				Debris:AddItem(blastForce, .2)
			end
		else -- Loose parts and dead parts are blasted
			if hitPart.Name ~= 'Handle' then
				hitPart:BreakJoints()
				local blastForce = Instance.new('BodyForce', hitPart) --NOTE: We will multiply by mass so bigger parts get blasted more
				blastForce.force = (hitPart.Position - blastCenter).unit * BLAST_FORCE * hitPart:GetMass()
				Debris:AddItem(blastForce, 0.1)
			end
		end
	end
end

function blowUp()
	explosionSound:Play()
	local explosion = Instance.new('Explosion')
	explosion.BlastPressure = 0 -- Completely safe explosion
	explosion.BlastRadius = BLAST_RADIUS
	explosion.ExplosionType = Enum.ExplosionType.NoCraters
	explosion.Position = self.Position
	explosion.Parent = workspace
	explosion.Hit:connect(function(hitPart, hitDistance) OnExplosionHit(hitPart, hitDistance, explosion.Position) end)
	script.Parent = explosion
	Tag.Parent = script
	self:Destroy()
end

while updateInterval > .1 do
	wait(updateInterval)
	update()	
	tickSound:play()	
end

blowUp()