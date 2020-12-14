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
Tool.Enabled = true

-- Settings
local Equipped = false
local InUse = false
local Networking = {}

--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Functions / Methods
--------------------------------------------------------------------------------------------------------------------------------------------------------------

function ReplenishSkin(BodyColors)
	for i,v in pairs(Character:GetChildren()) do
		if v.Name == "Head" then
			v.BrickColor = BodyColors.HeadColor
		elseif v.Name == "Left Arm" then
			v.BrickColor = BodyColors.LeftArmColor
		elseif v.Name == "Right Arm" then
			v.BrickColor = BodyColors.RightArmColor
		elseif v.Name == "Left Leg" then
			v.BrickColor = BodyColors.LeftLegColor
		elseif v.Name == "Right Leg" then
			v.BrickColor = BodyColors.RightLegColor
		elseif v.Name == "Torso" then
			v.BrickColor = BodyColors.TorsoColor
		end
	end
end

function UpdateCharacterBody(dir)
	if dir and dir:FindFirstChild("Humanoid") and dir:FindFirstChild("Body Colors") then
		for i,v in pairs(dir:GetChildren()) do
			if v:IsA("BasePart") then
				v.BrickColor = BrickColor.new(1)
			end
		end
	end
end

function ReplenishHealth()
	if Humanoid.Health > 0 then
		Humanoid.Health = Humanoid.MaxHealth
	end
end

function Replenish()
	if Humanoid.Health > 0 and Character:FindFirstChild("Body Colors") then
		local bColor = Character:FindFirstChild("Body Colors") 
		UpdateCharacterBody(Character)
		wait(1)
		ReplenishSkin(bColor)
		ReplenishHealth()
		Tool:Destroy()
	end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Setting up Tool
--------------------------------------------------------------------------------------------------------------------------------------------------------------

Tool.Enabled = true
Networking.Functions = {
	OnActivation = function()
		if Equipped and Tool.Enabled and Humanoid.Health > 0 then
			Replenish()
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
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("LowerTorso")
	Humanoid = Character:WaitForChild("Humanoid")
	Equipped = true
end)

Tool.Unequipped:connect(function()
	Equipped = false
end)