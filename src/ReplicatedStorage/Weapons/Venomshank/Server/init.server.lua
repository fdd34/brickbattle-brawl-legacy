--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RbxClient Linked Sword [Server]
-- Scripted by shloid
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
local UnsheathSound = Handle:WaitForChild("Unsheath")
Tool.Enabled = true

-- Settings
local Damage = 5
local SlashDamage = 10
local LungeDamage = 30
local LastAttack = 0
local Equipped = false
local Networking = {}

--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Functions / Methods
--------------------------------------------------------------------------------------------------------------------------------------------------------------

function TagPoison()
	local poisonScript = script.Poison:Clone()
	local creatorTag = Instance.new("ObjectValue")
	creatorTag.Value = Player
	creatorTag.Name = "poisoner"
	
	return creatorTag, poisonScript
end

function TagHumanoid(hum)
	if hum and hum:IsA("Humanoid") and Players:GetPlayerFromCharacter(hum.Parent) then
		local tag = Instance.new("ObjectValue",hum)
		tag.Name = "Creator"
		tag.Value = Player
		Debris:AddItem(tag,1)
	end
end

function Poison(char)
	if char and char:FindFirstChild("Humanoid") and not char:FindFirstChild("ForceField") and not char:FindFirstChild("Poison") then
		print("{Sword] Applying poision to character.")
		local tag, sc = TagPoison()
		tag.Parent = char
		sc.Parent = char
		sc.Disabled = false
	end
end

function OnHit(hit)
	if hit and hit.Parent:FindFirstChild("Humanoid") then
		if hit.Parent:FindFirstChild("Forcefield") then return end
		local hitHum = hit.Parent:FindFirstChild("Humanoid")
		if hitHum.Health >= math.huge then return end
		if hitHum ~= Humanoid and hitHum.Health > 0 and Damage > 0 then
			if Players:GetPlayerFromCharacter(hit.Parent) then
				if Players:GetPlayerFromCharacter(hit.Parent).TeamColor == Player.TeamColor then return end		
			end
			Poison(hit.Parent)
			TagHumanoid(hitHum)
			hitHum:TakeDamage(Damage)
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
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	UnsheathSound:Play()
	Tool.Enabled = true
	Equipped = true
end)

Tool.Unequipped:connect(function()
	UnsheathSound:Play()
	Tool.Enabled = false
	Equipped = false
end)

Handle.Touched:connect(OnHit)