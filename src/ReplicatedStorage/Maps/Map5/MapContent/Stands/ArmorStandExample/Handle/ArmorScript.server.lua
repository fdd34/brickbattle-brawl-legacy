--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RbxClient Flag System
-- Scripted by shloid
--------------------------------------------------------------------------------------------------------------------------------------------------------------

local Players = game:GetService("Players")
local debounce = false
local self = script.Parent

--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Functions / Methods
--------------------------------------------------------------------------------------------------------------------------------------------------------------

function getPlayer(humanoid)
	local players = Players:GetPlayers()
	for i = 1, #players do
		if players[i].Character then
			if players[i].Character.Humanoid == humanoid then 
				return players[i] 
			end
		end
	end
	return nil
end

function ChangeArmorStats(type)
	local types = {
		["On"] = true,
		["Off"] = true,
	}
	if type and types[type] then
		print("[Armor] Changing armor stats: "..type)
		if type == "On" then
			self.Transparency = 0
			self.CanCollide = true
		elseif type == "Off" then
			self.Transparency = 1
			self.CanCollide = false
		end
	end
end

function putOnArmor(humanoid)
	local torso = humanoid.Parent:WaitForChild("Torso")
	local hrp = humanoid.Parent:WaitForChild("HumanoidRootPart")
	local sgraphic = humanoid.Parent:WaitForChild("Shirt Graphic")
	
	torso.Transparency = 1
	hrp.Transparency = 0
	hrp.Reflectance = .35
	hrp.BrickColor = torso.BrickColor
	
	local fakeTshirt = Instance.new("Decal",hrp)
	fakeTshirt.Face = Enum.NormalId.Front
	fakeTshirt.Texture = sgraphic.Graphic
	
	humanoid.MaxHealth = humanoid.MaxHealth * 2
end

function hasArmor(humanoid)
	return (humanoid.MaxHealth > 100)
end

function onTouched(hit)
	local humanoid = hit.Parent:findFirstChild("Humanoid")
	if humanoid and not debounce then
		if (hasArmor(humanoid)) then return end
		debounce = true
		ChangeArmorStats("Off")
		putOnArmor(humanoid)
		wait(10)
		debounce = false
		ChangeArmorStats("On")
	end
end

self.Touched:connect(onTouched)