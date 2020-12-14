--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RbxClient Bomb Script [Server]
-- Scripted by shloid
--------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Services
local Run = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

-- Tool
local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local BombScript = script:WaitForChild("Bomb")
local EventHandler = Tool:WaitForChild("EventHandler")

-- Other Variables
local Networking = {}
local Equipped = false

-- BombPart
local BombPart = Instance.new("Part")
BombPart.Name = "TimeBomb"
BombPart.Shape = Enum.PartType.Ball
BombPart.Reflectance = 1
BombPart.Locked = true
BombPart.BrickColor = BrickColor.new(21)
BombPart.Size = Vector3.new(2,2,2)

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

function TagBall(part)
	if part and not part:FindFirstChild("creator") then
		local creatorTag = Instance.new("ObjectValue",part)
		creatorTag.Name = "creator"
		creatorTag.Value = Player
	end
end

function AttatchScript(part)
	if part then
		local newScript = BombScript:Clone()
		newScript.Parent = part
		newScript.Disabled = false
	end
end

function plant()
	if Character and Player and Head then
		local bomb2 = BombPart:Clone()
		bomb2.Position = Vector3.new(Handle.Position.X, Handle.Position.Y + 2, Handle.Position.Z)
		TagBall(bomb2)
		AttatchScript(bomb2)
		bomb2.Parent = workspace
	end
end

function OnActivated(mouse)
	if Equipped and Tool.Enabled and Humanoid and Humanoid.Health > 0 then
		Tool.Enabled = false
		plant()
		Handle.Transparency = 1
		wait(6)
		Handle.Transparency = 0
		Tool.Enabled = true
	end
end

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
	Equipped = true
end)

Tool.Unequipped:connect(function()
	Equipped = false
end)

Tool.Changed:connect(UpdateMouse)