--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RbxClient Rocketlauncher [Server]
--------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Services
local Rep = game:GetService("ReplicatedStorage")
local SkinsModule = require(Rep:FindFirstChild("SkinsModule"))
local Rep = game:GetService("ReplicatedStorage")
local Debris = game:GetService('Debris')
local Players = game:GetService('Players')

-- Tool
local Tool = script.Parent
local Skin = Tool:WaitForChild("Skin")
local Handle = Tool:WaitForChild("Handle")
local EventHandler = Tool:WaitForChild("EventHandler")
local EquipSound = Handle:WaitForChild("Equip")

-- Script Variables
local RocketScript = script:WaitForChild('Rocket')
local SwooshSound = script:WaitForChild('Swoosh')
local BoomSound = script:WaitForChild('Boom')

-- Settings
local GravityAcceleration = 196.2
local ReloadTime = 3 
local RocketSpeed = 60
local RocketPartSize = Vector3.new(1, 1, 4)
local Equipped = false
local Networking = {}
local KillIcon = 1160900890

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
		tag.Name = "Creator"
		tag.Value = Player
		
		local ftag = Instance.new("StringValue",hum)
		ftag.Name = "FeedTag"
		ftag.Value = tostring(KillIcon)
		
		--Debris:AddItem(tag,1.5)
		--Debris:AddItem(ftag,1.5)
	end
end

function CreateRocket()
	local Rocket = Instance.new('Part')
	Rocket.Name = 'Rocket'
	Rocket.FormFactor = Enum.FormFactor.Custom
	Rocket.Size = RocketPartSize
	Rocket.CanCollide = false
	
	-- Add fire
	local fireStuff = Rep:WaitForChild("Particles"):WaitForChild("Fire"):GetChildren()
	for i,v in pairs(fireStuff) do
		local vClone = v:Clone()
		vClone.EmissionDirection = Enum.NormalId.Back
		vClone.Parent = Rocket
	end

	-- Add a force to counteract gravity
	local bodyForce = Instance.new('BodyForce', Rocket)
	bodyForce.Name = 'Antigravity'
	bodyForce.force = Vector3.new(0, Rocket:GetMass() * GravityAcceleration, 0)

	-- Clone the sounds and set Boom to PlayOnRemove
	local swooshSoundClone = SwooshSound:Clone()
	swooshSoundClone.Parent = Rocket
	
	local boomSoundClone = BoomSound:Clone()
	boomSoundClone.Parent = Rocket

	TagObject(Rocket)
	
	return Rocket
end

function computeDirection(vec)
	local lenSquared = vec.magnitude * vec.magnitude
	local invSqrt = 1 / math.sqrt(lenSquared)
	return Vector3.new(vec.x * invSqrt, vec.y * invSqrt, vec.z * invSqrt)
end

function OnActivated(mouse)
	if Equipped and Tool.Enabled and Humanoid.Health > 0 then
		Tool.Enabled = false

		-- Create a clone of Rocket and set its color
		local rocketClone = CreateRocket()
		rocketClone.BrickColor = Player.TeamColor
		Debris:AddItem(rocketClone, 30)
		if Player.Neutral then
			rocketClone.BrickColor = BrickColor.new("Bright blue")
		end
		
		for i,v in pairs(script:GetChildren()) do
			if v:IsA("Texture") then
				v:Clone().Parent = rocketClone
			elseif v:IsA("SurfaceLight") then
				local lightClone = v:Clone()
				lightClone.Parent = rocketClone
				lightClone.Enabled = true
			end
		end

		-- Position the rocket clone and launch!
		local direction = Humanoid.TargetPoint - Handle.Position
		direction = computeDirection(direction)
		
		local spawnPosition = (Handle.CFrame * CFrame.new(2, 0, 0)).p
		rocketClone.CFrame = CFrame.new(spawnPosition, mouse) --NOTE: This must be done before assigning Parent
		rocketClone.Velocity = rocketClone.CFrame.lookVector * RocketSpeed --NOTE: This should be done before assigning Parent
		rocketClone.Parent = workspace

		local RClone = script.Rocket:Clone()
		RClone.Parent = rocketClone
		RClone.Disabled = false
		
		wait(ReloadTime)
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
		if SkinsModule.RocketLauncher[skin] then
			Skin.Mesh.TextureId = "rbxassetid://"..SkinsModule.RocketLauncher[skin]
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
	Humanoid = Character:WaitForChild("Humanoid")
	Player = Players:GetPlayerFromCharacter(Character)
	PlayerInfo = Player:WaitForChild("PlayerInfo")
	ImportantConnection = PlayerInfo.Skins.LauncherSkin.Changed:connect(ChangeSkin)
	PlayerEvent = Player:WaitForChild("PlayerEvent")
	Equipped = true
end)

Tool.Unequipped:connect(function()
	EquipSound:Play()
	Equipped = false
end)

Tool.Changed:connect(UpdateMouse)