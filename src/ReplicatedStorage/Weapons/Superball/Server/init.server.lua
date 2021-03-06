--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RbxClient Superball [Server]
--------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Services
local Rep = game:GetService("ReplicatedStorage")
local SkinsModule = require(Rep:FindFirstChild("SkinsModule"))
local Run = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

-- Tool Variables
local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local CannonBall = script:WaitForChild("CannonBall")
local BoingSound = Handle:WaitForChild("Boing")
local EventHandler = Tool:WaitForChild("EventHandler")

-- Important Variables
local Equipped = false
local VELOCITY = 85
local Networking = {}
local KillIcon = 1160904132

-- Ball Part
local BallPart = Instance.new("Part")
BallPart.Shape = Enum.PartType.Ball
BallPart.Material = Enum.Material.Ice
BallPart.Size = Vector3.new(3,3,3)
BallPart.Name = "CannonShot"
BallPart.Reflectance = .2
BallPart.Elasticity = 1
BoingSound:Clone().Parent = BallPart

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
		local newScript = CannonBall:Clone()
		newScript.Parent = part
		newScript.Disabled = false
	end
end

function fire(direction)
	if Character and Player and Head then
		BoingSound:Play()
		local missile = BallPart:Clone()
		missile.Velocity = direction * 200
		missile.BrickColor = BrickColor.Random()
		if not Player.Neutral then
			missile.BrickColor = Player.TeamColor
		end
		
		local spawnPos = Character.PrimaryPart.Position
		spawnPos  = spawnPos + (direction * 5)
		
		TagObject(missile)
		AttatchScript(missile)
		missile.Position = spawnPos
		missile.Parent = workspace
	end
end

function OnActivated(mouse)
	if Equipped and Tool.Enabled and Humanoid and Humanoid.Health > 0 then
		local lookAt = (mouse - Head.Position).unit
		fire(lookAt)
		Tool.Enabled = false
		wait(2)
		Tool.Enabled = true
	end
end

function ChangeSkin(skin)
	if skin == "Classic" then
		Handle.Mesh.Parent = Tool
	else
		Tool.Mesh.Parent = Handle
		if SkinsModule.Superball[skin] then
			Handle.Mesh.TextureId = "rbxassetid://"..SkinsModule.Superball[skin]
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
	ImportantConnection = PlayerInfo.Skins.SuperballSkin.Changed:connect(ChangeSkin)
	Equipped = true
	BoingSound:Play()
	if not Player.Neutral then
		Handle.BrickColor = Player.TeamColor
	else
		Handle.BrickColor = BrickColor.new("Bright red")
	end
	
	NewConnection = Player.Changed:connect(function(prop)
		if not Player.Neutral then
			Handle.BrickColor = Player.TeamColor
		else
			Handle.BrickColor = BrickColor.new("Bright red")
		end
	end)
end)

Tool.Unequipped:connect(function()
	Equipped = false
	BoingSound:Play()
	NewConnection:disconnect()
end)

Tool.Changed:connect(UpdateMouse)