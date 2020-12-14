--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RbxClient Linked Sword [Server]
--------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Services
local Rep = game:GetService("ReplicatedStorage")
local SkinsModule = require(Rep:FindFirstChild("SkinsModule"))
local Run = game:service("RunService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

-- Tool Variables
local Tool = script.Parent
local Event = Tool:WaitForChild("Event")
local Handle = Tool:WaitForChild("Handle")
local Skin = Tool:WaitForChild("Skin")

local SlashSound = Handle:WaitForChild("Slash")
local LungeSound = Handle:WaitForChild("Lunge")
local UnsheathSound = Handle:WaitForChild("Unsheath")
Tool.Enabled = true

-- Settings
local Damage = 5
local SlashDamage = 10
local LungeDamage = 25
local LastAttack = 0
local Equipped = false
local Debounce = false
local Networking = {}
local KillIcon = 1160897266

--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Functions / Methods
--------------------------------------------------------------------------------------------------------------------------------------------------------------

function RemoveTagFromHumanoid(hum)
	for i,v in pairs(hum:GetChildren()) do
		if v:IsA("ObjectValue") or v:IsA("StringValue") then
			v:Destroy()
		end
	end	
end

function UpdateMouse()
	if PlayerEvent then
		if Equipped then
			if Tool.Enabled then
				PlayerEvent:FireClient(Player,"UpdateMouseStatus","Gun")
			else
				PlayerEvent:FireClient(Player,"UpdateMouseStatus","GunReload")
			end
		else
			PlayerEvent:FireClient(Player,"UpdateMouseStatus","Regular")
		end
	end
end

function TagHumanoid(hum)
	if hum and hum:IsA("Humanoid") and Players:GetPlayerFromCharacter(hum.Parent) then
		local tag = Instance.new("ObjectValue",hum)
		tag.Name = "Creator"
		tag.Value = Player
		
		local ftag = Instance.new("StringValue",hum)
		ftag.Name = "FeedTag"
		ftag.Value = tostring(KillIcon)
		
		Debris:AddItem(tag,1.5)
		Debris:AddItem(ftag,1.5)
	end
end

function CheckHitObj(char,hum)
	if char and hum then
		if hum == Humanoid or char:FindFirstChild("Forcefield") or char:FindFirstChild("ForceField") or Humanoid.Health <= 0 or hum.Health <= 0 or Damage <= 0 or hum.Health >= math.huge then 
			return false
		else
			return true
		end
	end
	return false
end

function OnHit(hit)
	if hit and hit.Parent and hit.Parent:FindFirstChild("Humanoid") then
		local hitHum = hit.Parent:FindFirstChild("Humanoid")
		if CheckHitObj(hit.Parent,hitHum) == true then
			RemoveTagFromHumanoid(hitHum)
			if Players:GetPlayerFromCharacter(hit.Parent) then
				local hitPlayer = Players:GetPlayerFromCharacter(hit.Parent)
				if hitPlayer:FindFirstChild("Status") then
					if hitPlayer.Status.Value == "AtSpawn" then
						return
					end
				end
				if Players:GetPlayerFromCharacter(hit.Parent).TeamColor == Player.TeamColor and Player.Neutral == false then return end		
			end	
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
			--local force = Instance.new("BodyVelocity",Torso)
			--force.Velocity = Vector3.new(0,10,0)
			--Debris:AddItem(force,.5)
			wait(.25)
			swordOut()
			wait(.25)
			wait(.5)
			swordUp()
			Damage = 0
		end
	end
end

function ChangeSkin(skin)
	if skin == "Classic" then
		Skin.Transparency = 1
		Handle.Transparency = 0
	else
		Skin.Transparency = 0
		Handle.Transparency = 1
		if SkinsModule.Swords[skin] then
			Skin.Mesh.TextureId = "rbxassetid://"..SkinsModule.Swords[skin]
		else
			print("[Server] Error: Skin for the "..Tool.Name.." has not been found. Reverting back to original skin.")
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
			Debounce = true
			local t = Run.Stepped:wait()
			if (t - LastAttack < .2) then
				ActivateAnim("Lunge")
			else
				ActivateAnim("Attack")
			end
			LastAttack = t
			--wait(.5)
			Tool.Enabled = true
			spawn(function()
				wait(.5)
				if Tool.Enabled == true then
					Debounce = false
				end
			end)
		end
	end,
}

Event.OnServerEvent:connect(function(player,fname,...)
	if fname then
		Networking.Functions[fname](...)
	end
end)

Tool.Equipped:connect(function()
	UnsheathSound:Play()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	PlayerEvent = Player:WaitForChild("PlayerEvent")
	PlayerInfo = Player:WaitForChild("PlayerInfo")
	ImportantConnection = PlayerInfo.Skins.SwordSkin.Changed:connect(ChangeSkin)
	Humanoid = Character:WaitForChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	Tool.Enabled = true
	Equipped = true
	UpdateMouse()
end)

Tool.Unequipped:connect(function()
	UnsheathSound:Play()
	Tool.Enabled = false
	Equipped = false
	UpdateMouse()
end)

Tool.Changed:connect(UpdateMouse)
Handle.Touched:connect(OnHit)