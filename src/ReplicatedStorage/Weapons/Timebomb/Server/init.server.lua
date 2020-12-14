--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RbxClient Bomb Script [Server]
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
local BombScript = script:WaitForChild("Bomb")
local EventHandler = Tool:WaitForChild("EventHandler")

-- Other Variables
local Networking = {}
local Equipped = false
local KillIcon = 1160905038

-- BombPart
local BombPart = Instance.new("Part")
BombPart.Name = "TimeBomb"
BombPart.Shape = Enum.PartType.Ball
BombPart.Reflectance = 1
BombPart.Locked = true
BombPart.BrickColor = BrickColor.new(21)
BombPart.Size = Vector3.new(2,2,2)
Skin.Mesh:Clone().Parent = BombPart

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

function TagObject(hum)
	if hum then
		local tag = Instance.new("ObjectValue",hum)
		tag.Name = "creator"
		tag.Value = Player
		
		local ftag = Instance.new("StringValue",hum)
		ftag.Name = "FeedTag"
		ftag.Value = tostring(KillIcon)
		
		--Debris:AddItem(tag,1.5)
		--Debris:AddItem(ftag,1.5)
	end
end

function AttatchScript(part)
	if part then
		local newScript = BombScript:Clone()
		newScript.Parent = part
		local surfaceLight = script.PointLight:Clone()
		surfaceLight.Parent = part
		newScript.Disabled = false
	end
end

function plant()
	if Character and Player and Head then
		local bomb2 = BombPart:Clone()
		TagObject(bomb2)
		AttatchScript(bomb2)
		bomb2.Position = Vector3.new(Handle.Position.X, Handle.Position.Y + 2, Handle.Position.Z)
		bomb2.Parent = workspace
	end
end

function OnActivated(mouse)
	if Equipped and Tool.Enabled and Humanoid and Humanoid.Health > 0 then
		Tool.Enabled = false
		plant()
		--Handle.Transparency = 1
		Skin.Transparency = 1
		wait(6)
		--Handle.Transparency = 0
		Skin.Transparency = 0
		Tool.Enabled = true
	end
end

function ChangeSkin(skin)
	if skin == "Classic" then
		Skin.Transparency = 1
		Handle.Transparency = 0
		if BombPart:FindFirstChild("Mesh") then
			BombPart:FindFirstChild("Mesh").Parent = Tool
		end
	elseif skin == "MoneyBomb" then
		if BombPart:FindFirstChild("Mesh") then
			BombPart:FindFirstChild("Mesh").Parent = Tool
		end
	else
		Skin.Transparency = 0
		Handle.Transparency = 1
		if Tool:FindFirstChild("Mesh") then
			Tool:FindFirstChild("Mesh").Parent = Handle
		end
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
	Character = Tool.Parent
	Head = Character:FindFirstChild("Head")
	Humanoid = Character:FindFirstChild("Humanoid")
	Player = Players:GetPlayerFromCharacter(Character)
	PlayerEvent = Player:WaitForChild("PlayerEvent")
	PlayerInfo = Player:WaitForChild("PlayerInfo")
	ImportantConnection = PlayerInfo.Skins.BombSkin.Changed:connect(ChangeSkin)
	Equipped = true
end)

Tool.Unequipped:connect(function()
	Equipped = false
end)

Tool.Changed:connect(UpdateMouse)