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

function UpdateTransparency(trans)
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
		Handle.Transparency = trans
		if Handle.Transparency < .5 then
			Handle.Transparency = .5
		end
	end
end

function ShieldHandler(type)
	local types = {
		["Activate"] = true,
		["Deactivate"] = true,
	}
	
	if type and types[type] then
		local counter = 0
		if type == "Activate" then
			for i = 1, 10 do
				counter = counter + .1
				UpdateTransparency(counter)
				wait()
			end
		elseif type == "Deactivate" then
			counter = 1
			for i = 1, 10 do
				counter = counter - .1
				UpdateTransparency(counter)
				wait()
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
			InUse = true
			wait(8)
			InUse = false
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
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("LowerTorso")
	Humanoid = Character:WaitForChild("Humanoid")
	Equipped = true
end)

Tool.Unequipped:connect(function()
	Equipped = false
	if InUse then
		ShieldHandler("Deactivate")
		InUse = false
	end
end)