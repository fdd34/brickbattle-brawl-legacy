--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RbxClient Linked Sword [Server]
--------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Services
local Run = game:service("RunService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

-- Tool
local Tool = script.Parent
local Event = Tool:WaitForChild("Event")
local Handle = Tool:WaitForChild("Handle")

local SlashSound = Handle:WaitForChild("Slash")
local LungeSound = Handle:WaitForChild("Lunge")
local SpookySound = Handle:WaitForChild("Spooky")
local UnsheathSound = Handle:WaitForChild("Unsheath")
Tool.Enabled = true

-- Settings
local Damage = 5
local SlashDamage = 10
local LungeDamage = 30
local DamageBase = 15
local DamageMax = 25

local LastAttack = 0
local Equipped = false
local Networking = {}

-- Ghost Effect
local GhostEffect = nil
local equalizingForce = 236 / 1.2 -- amount of force required to levitate a mass
local gravity = .75 -- things float at > 1
local killCounter = Tool:WaitForChild("Kills")

--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Functions / Methods
--------------------------------------------------------------------------------------------------------------------------------------------------------------

function recursiveGetMass(node)
	local m = 0
	local c = node:GetChildren()
	for i = 1, #c do
		if c[i]:IsA("BasePart") then
			m = m + c[i]:GetMass()
		end
		m = m + recursiveGetMass(c[i])
	end
	return m
end

function UpdateGhostParts(trans)
	if Character and Humanoid and Humanoid.Health > 0 then
		for i,v in pairs(Character:GetChildren()) do
			if v:IsA("BasePart") then
				if v.Name == "HumanoidRootPart" then
					if v.Reflectance > 0 then
						v.Transparency = trans
						for i2,v2 in pairs(v:GetChildren()) do
							if v2:IsA("Decal") then
								v2.Transparency = trans
							end
						end
					else
						-- do nothing
					end
				else
					v.Transparency = trans
				end		
			elseif v:IsA("Accessory") or v:IsA("Hat") then
				for i2,v2 in pairs(v:GetChildren()) do
					if v2:IsA("BasePart") then
						v2.Transparency = trans
					end
				end			
			end
		end
	end
end

function UpdateGhostState(type)
	local types = {
		["Update"] = true,
		["Unequip"] = true,
	}
	if type and types[type] then
		if type == "Unequip" then
			UpdateGhostParts(0)
			if GhostEffect then GhostEffect:Destroy() end
			GhostEffect = nil
		elseif type == "Update" then
			if not GhostEffect then
				local recursiveMass = recursiveGetMass(Character)
				GhostEffect = Instance.new("BodyForce",Character.Head)
				GhostEffect.Name = "GhostEffect"
				GhostEffect.Force = Vector3.new(0, recursiveMass * equalizingForce * gravity,0)
			end
			local newPower = killCounter.Value
			if newPower > 9 then newPower = 9 end
			
			Tool.Name = "Ghostwalker (" .. newPower .. ")"
			SlashDamage = DamageBase + (DamageMax - DamageBase) * (newPower / 9)
			LungeDamage = 2 * (DamageBase + (DamageMax - DamageBase) * (newPower / 9))
			UpdateGhostParts(.2 + ((newPower / 9) * .8))
			if newPower == 9 then
				Handle.Transparency = .9
			end
		end
	end
end

function TagHumanoid(hum)
	if hum and hum:IsA("Humanoid") and Players:GetPlayerFromCharacter(hum.Parent) then
		local tag = Instance.new("ObjectValue",hum)
		tag.Name = "Creator"
		tag.Value = Player
		Debris:AddItem(tag,1)
	end
end

function OnHit(hit)
	if hit and hit.Parent and hit.Parent:FindFirstChild("Humanoid") then
		if hit.Parent:FindFirstChild("Forcefield") then return end
		local hitHum = hit.Parent:FindFirstChild("Humanoid")
		if hitHum.Health >= math.huge then return end
		if hitHum ~= Humanoid and hitHum.Health >= 0 and Damage > 0 then
			if Players:GetPlayerFromCharacter(hit.Parent) then
				if Players:GetPlayerFromCharacter(hit.Parent).TeamColor == Player.TeamColor then return end		
			end	
			TagHumanoid(hitHum)
			hitHum:TakeDamage(Damage)
			if hitHum.Health >= 0 and killCounter.Value < 9 then
				killCounter.Value = killCounter.Value + 1
				SpookySound:Play()
				UpdateGhostState("Update")
			end
		end
	end
end

function swordUp()
	Tool.GripForward = Vector3.new(-1,0,0)
	Tool.GripRight = Vector3.new(0,1,0)
	Tool.GripUp = Vector3.new(0,0,1)
end

function swordOut()
	Tool.GripForward = Vector3.new(0,0,1)
	Tool.GripRight = Vector3.new(0,-1,0)
	Tool.GripUp = Vector3.new(-1,0,0)
end

function ActivateAnim(type)
	local types = {
		["Attack"] = true,
		["Lunge"] = true,
	}
	if type and types[type] then
		local anim = Instance.new("StringValue")
		anim.Name = "toolanim"
		anim.Parent = Tool
		
		if type == "Attack" then
			Damage = SlashDamage
			anim.Value = "Slash"
			SlashSound:Play()
		elseif type == "Lunge" then
			Damage = LungeDamage
			LungeSound:Play()
			anim.Value = "Lunge"
			local force = Instance.new("BodyVelocity",Torso)
			force.Velocity = Vector3.new(0,10,0)
			Debris:AddItem(force,.5)
			wait(.25)
			swordOut()
			wait(.25)
			wait(.5)
			swordUp()
			Damage = 0
		end
	end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Setting up Tool
--------------------------------------------------------------------------------------------------------------------------------------------------------------

Tool.Enabled = true
Networking.Functions = {
	OnActivation = function()
		if Equipped and Tool.Enabled and Humanoid.Health > 0 then
			Tool.Enabled = false
			local t = Run.Stepped:wait()
			if (t - LastAttack < .2) then
				ActivateAnim("Lunge")
			else
				ActivateAnim("Attack")
			end
			LastAttack = t
			--wait(.5)
			Tool.Enabled = true
		end
	end,
	
}

Event.OnServerEvent:connect(function(player,fname,...)
	if fname then
		Networking.Functions[fname](...)
	end
end)

Tool.Equipped:connect(function()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:WaitForChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("LowerTorso")
	UnsheathSound:Play()
	Tool.Enabled = true
	Equipped = true
	UpdateGhostState("Update")
end)

Tool.Unequipped:connect(function()
	UnsheathSound:Play()
	Tool.Enabled = false
	Equipped = false
	Handle.Transparency = .7
	UpdateGhostState("Unequip")
end)

Handle.Touched:connect(OnHit)
killCounter.Changed:connect(function()
	if Equipped then
		UpdateGhostState("Update")
	end
end)