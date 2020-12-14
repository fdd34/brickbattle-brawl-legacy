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

local BoingSound = Handle:WaitForChild("Boing")
Tool.Enabled = true

-- Settings
local Equipped = false
local InUse = false
local Networking = {}
local Forcefield = nil

--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Functions / Methods
--------------------------------------------------------------------------------------------------------------------------------------------------------------

function ShieldHandler(type)
	local types = {
		["Activate"] = true,
		["Deactivate"] = true,
	}
	
	if type and types[type] then
		if type == "Activate" then
			Handle.BrickColor = BrickColor.new(24)
			BoingSound:Play()
			Tool.TextureId = "rbxassetid://1122746040"
		elseif type == "Deactivate" then
			Handle.BrickColor = BrickColor.new(104)
			Tool.TextureId = "rbxassetid://1122745766"
			if Forcefield then
				Forcefield:Destroy()
				Forcefield = nil
			end
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
			ShieldHandler("Activate")
			Forcefield = Instance.new("ForceField",Character)
			wait(8)
			ShieldHandler("Deactivate")
			wait(2.5)
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
	BoingSound:Play()
	Equipped = true
end)

Tool.Unequipped:connect(function()
	BoingSound:Play()
	Equipped = false
	ShieldHandler("Deactivate")
end)