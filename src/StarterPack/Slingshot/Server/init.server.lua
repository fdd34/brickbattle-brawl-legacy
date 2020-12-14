--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RbxClient Slingshot [Server]
--------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Services
local Rep = game:GetService("ReplicatedStorage")
local SkinsModule = require(Rep:FindFirstChild("SkinsModule"))
local Run = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

-- Tool
local Tool = script.Parent
local Skin = Tool:WaitForChild("Skin")
local Handle = Tool:WaitForChild("Handle")
local EventHandler = Tool:WaitForChild("EventHandler")
local EquipSound = Handle:WaitForChild("Equip")
local SlingshotSound = Handle:WaitForChild("SlingshotSound") -- rbxassetid://256693986

-- Other Variables
local Networking = {}
local VELOCITY = 85 -- constant
local Equipped = false
local KillIcon = 1160901473

-- Pellet Script
local Pellet = Instance.new("Part")
Pellet.Locked = true
Pellet.BackSurface = 0
Pellet.BottomSurface = 0
Pellet.FrontSurface = 0
Pellet.LeftSurface = 0
Pellet.RightSurface = 0
Pellet.TopSurface = 0
Pellet.Shape = 0
Pellet.Size = Vector3.new(1.2,1.2,1.2)
Pellet.BrickColor = BrickColor.new("White")
script.PelletScript:Clone().Parent = Pellet

local PelletMesh = Instance.new('SpecialMesh', Pellet)
PelletMesh.MeshId = "rbxassetid://94689434"
PelletMesh.TextureId = "rbxassetid://94689543"
PelletMesh.Scale = Vector3.new(1.7, 1.7, 1.7)
PelletMesh.Name = 'PelletMesh'

--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Functions / Methods
--------------------------------------------------------------------------------------------------------------------------------------------------------------

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

function computeLaunchAngle(dx,dy,grav)
	local g = math.abs(grav)
	local inRoot = (VELOCITY*VELOCITY*VELOCITY*VELOCITY) - (g * ((g*dx*dx) + (2*dy*VELOCITY*VELOCITY)))
	if inRoot <= 0 then
		return .25 * math.pi
	end
	local root = math.sqrt(inRoot)
	local inATan1 = ((VELOCITY*VELOCITY) + root) / (g*dx)

	local inATan2 = ((VELOCITY*VELOCITY) - root) / (g*dx)
	local answer1 = math.atan(inATan1)
	local answer2 = math.atan(inATan2)
	if answer1 < answer2 then return answer1 end
	return answer2
end

function computeDirection(vec)
	local lenSquared = vec.magnitude * vec.magnitude
	local invSqrt = 1 / math.sqrt(lenSquared)
	return Vector3.new(vec.x * invSqrt, vec.y * invSqrt, vec.z * invSqrt)
end

function TagObject(hum)
	if hum then
		local tag = Instance.new("ObjectValue",hum)
		tag.Name = "Creator"
		tag.Value = Player
		
		local ftag = Instance.new("StringValue",hum)
		ftag.Name = "FeedTag"
		ftag.Value = tostring(KillIcon)
		
		--Debris:AddItem(tag,1.5)
		--Debris:AddItem(ftag,1.5)
	end
end

function fire(mouse_pos)
	if Character and Player and Head then
		SlingshotSound:Play()
		
		local dir = computeDirection(mouse_pos - Head.Position)
		local launch = Head.Position + 5 * dir
		
		local delta = mouse_pos - launch
		local dy = delta.y
		local new_delta = Vector3.new(delta.x, 0, delta.z)
		delta = new_delta
		
		local dx = delta.magnitude
		local unit_delta = delta.unit
		local g = (-9.81 * 20)

		local theta = computeLaunchAngle( dx, dy, g)

		local vy = math.sin(theta)
		local xz = math.cos(theta)
		local vx = unit_delta.x * xz
		local vz = unit_delta.z * xz

		local missile = Pellet:Clone()
		missile.Position = launch
		missile.Velocity = Vector3.new(vx,vy,vz) * VELOCITY
		missile.PelletScript.Disabled = false
		if not Player.Neutral then
			missile.BrickColor = Player.TeamColor
		end
		
		TagObject(missile)
		
		missile.Parent = workspace
	end
end

function OnActivated(mouse)
	if Equipped and Tool.Enabled and Humanoid and Humanoid.Health > 0 then
		Tool.Enabled = false
		fire(mouse)
		wait(.2)
		Tool.Enabled = true
	end
end

function ChangeSkin(skin)
	if skin == "Classic" then
		Skin.Transparency = 1
		Handle.Transparency = 0
	else
		Skin.Transparency = 0
		Handle.Transparency = 1
		if SkinsModule.Slingshot[skin] then
			Skin.Mesh.TextureId = "rbxassetid://"..SkinsModule.Slingshot[skin]
		else
			print("[Server] Error: Skin for the "..Tool.Name.." has not been found. Reverting back to original skin.")
		end
	end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Setting up Tool
--------------------------------------------------------------------------------------------------------------------------------------------------------------

Networking.Functions = {
	OnActivation = function(mouse)
		OnActivated(mouse)
	end
}

EventHandler.OnServerEvent:connect(function(player,fname,...)
	if fname then
		Networking.Functions[fname](...)
	end
end)

Tool.Equipped:connect(function()
	EquipSound:Play()
	Character = Tool.Parent
	Head = Character:FindFirstChild("Head")
	Humanoid = Character:FindFirstChild("Humanoid")
	Player = Players:GetPlayerFromCharacter(Character)
	PlayerEvent = Player:WaitForChild("PlayerEvent")
	PlayerInfo = Player:WaitForChild("PlayerInfo")
	ImportantConnection = PlayerInfo.Skins.SlingshotSkin.Changed:connect(ChangeSkin)
	Equipped = true
end)

Tool.Unequipped:connect(function()
	EquipSound:Play()
	Equipped = false
end)

Tool.Changed:connect(UpdateMouse)