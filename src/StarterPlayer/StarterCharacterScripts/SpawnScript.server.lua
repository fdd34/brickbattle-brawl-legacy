--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Brickbattle Brawl Spawn Script
--------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Services
local Rep = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Rep Variables
local RepHats = Rep:WaitForChild("Hats")

-- Chracter Variables
repeat wait() until script.Parent:FindFirstChild("HumanoidRootPart")
local Character = script.Parent
local HRP = Character:WaitForChild("HumanoidRootPart")
local BodyParts = {
	LArm = Character:WaitForChild("Left Arm"),
	RArm = Character:WaitForChild("Right Arm"),
	LLeg = Character:WaitForChild("Left Leg"),
	RLeg = Character:WaitForChild("Right Leg")
}
local Head = Character:WaitForChild("Head")
local Torso = Character:WaitForChild("Torso")
local Face = (Head:FindFirstChild("Face") or Head:FindFirstChild("face"))
local Humanoid = Character:WaitForChild("Humanoid")

-- Player Variables
local Player = Players:GetPlayerFromCharacter(Character)
local PStatus = Player:WaitForChild("Status")
local PlayerInfo = Player:WaitForChild("PlayerInfo")

-- PlayerInfo Character Variables
local PI_Char = PlayerInfo:WaitForChild("Character")
local PI_BoughtHats = PlayerInfo:WaitForChild("BoughtHats")

local CharHat = PI_Char:WaitForChild("Hat")
local CharShirt  = PI_Char:WaitForChild("TShirt")
local CharColors = PI_Char:WaitForChild("BodyColors")
local MainHat = nil

-- T-Shirt Variable
local ShirtGui = Instance.new("SurfaceGui", Torso)
ShirtGui.Name = "TShirtGui"
ShirtGui.Adornee = Torso
ShirtGui.Face = Enum.NormalId.Front
ShirtGui.LightInfluence = 1

local TShirtLabel = Instance.new("ImageLabel", ShirtGui)
TShirtLabel.Name = "Label"
TShirtLabel.Size = UDim2.fromScale(1, 1)
TShirtLabel.BackgroundTransparency = 1
TShirtLabel.Image = "rbxassetid://64347969"

-- Health Gui Variables
local HealthGui = script.HealthGui:Clone()
HealthGui.Parent = Head
HealthGui.Adornee = Head
HealthGui.Enabled = true
HealthGui.PlayerToHideFrom = Player

local HBar = HealthGui:WaitForChild("FG")
local PLabel = HealthGui:WaitForChild("PlayerLabel")
PLabel.Text = Player.Name

--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Functions / Methods
--------------------------------------------------------------------------------------------------------------------------------------------------------------

for i,v in pairs(Character:GetChildren()) do
	if v.Name == tostring(CharHat.Value) and v:IsA("Accessory") then
		MainHat = v
	end
end

function SpawnPlayer(target)
	if target then
		HRP.CFrame = target.CFrame + Vector3.new(0, 5, 0)
	end
end

function UpdateHealth()
	if Humanoid then
		local hp = Humanoid.Health / Humanoid.MaxHealth
		HBar.Size = UDim2.new(hp,0,1,0)
		if Humanoid.Health >= math.huge then
			HBar.Size = UDim2.new(1,0,1,0)
			HBar.BackgroundColor3 = Color3.new(0,1,1)
		else
			HBar.BackgroundColor3 = Color3.new(0, 204/255, 0)
		end
	end
end

function SetTShirt()
	-- fixed
	local id = (CharShirt.Value:lower() == "default" and "rbxassetid://64347969") or "rbxthumb://type=Asset&id=" .. CharShirt.Value .. "&w=420&h=420"
	TShirtLabel.Image = id
	--if tshirt and tshirt:IsA("ShirtGraphic") then
		
	--	if CharShirt.Value == "Default" then
	--		tshirt.Graphic = "rbxassetid://64347969"
	--	else
	--		tshirt.Graphic = "rbxassetid://" .. tostring(CharShirt.Value)
	--	end	
	--end
end

function GiveHat()
	if MainHat ~= nil then
		MainHat:Destroy()
		MainHat = nil
	end
	local selectedHat = RepHats:FindFirstChild(CharHat.Value)
	local boolValueH = PI_BoughtHats:FindFirstChild(CharHat.Value)
	if CharHat.Value == "Default" or CharHat.Value == "None" or selectedHat == nil or boolValueH == nil then
		-- do nothing
	else
		if boolValueH.Value == true then
			local newHat = selectedHat:Clone()
			newHat.Parent = Character
			MainHat = newHat
		end
	end
end

CharHat.Changed:connect(function()
	GiveHat()
end)

function SetBodyColors(bcol)
	if bcol and bcol:IsA("BodyColors") then
		bcol.HeadColor = BrickColor.new(tostring(CharColors:WaitForChild("Head").Value))
		bcol.TorsoColor = BrickColor.new(tostring(CharColors:WaitForChild("Torso").Value))
		bcol.LeftArmColor = BrickColor.new(tostring(CharColors:WaitForChild("LeftArm").Value))
		bcol.RightArmColor = BrickColor.new(tostring(CharColors:WaitForChild("RightArm").Value))
		bcol.LeftLegColor = BrickColor.new(tostring(CharColors:WaitForChild("LeftLeg").Value))
		bcol.RightLegColor = BrickColor.new(tostring( CharColors:WaitForChild("RightLeg").Value))
		CharColors:WaitForChild("Head").Changed:connect(function(v)
			if v ~= nil and Player.Neutral then
				bcol.HeadColor = BrickColor.new(tostring(v))
			end
		end)
		CharColors:WaitForChild("Torso").Changed:connect(function(v)
			if v ~= nil and Player.Neutral then
				
				bcol.TorsoColor = BrickColor.new(tostring(v))
			end
		end)
		CharColors:WaitForChild("LeftArm").Changed:connect(function(v)
			if v ~= nil and Player.Neutral then
				bcol.LeftArmColor = BrickColor.new(tostring(v))
			end
		end)
		CharColors:WaitForChild("RightArm").Changed:connect(function(v)
			if v ~= nil and Player.Neutral then
				bcol.RightArmColor = BrickColor.new(tostring(v))
			end
		end)
		CharColors:WaitForChild("LeftLeg").Changed:connect(function(v)
			if v ~= nil and Player.Neutral then
				bcol.LeftLegColor = BrickColor.new(tostring(v))
			end
		end)
		CharColors:WaitForChild("RightLeg").Changed:connect(function(v)
			if v ~= nil and Player.Neutral then
				bcol.RightLegColor = BrickColor.new(tostring(v))
			end
		end)
	end
end

function CloneTexturesToParent(fold,par)
	if fold and par then
		for i,v in pairs(fold:GetChildren()) do
			v:Clone().Parent = par
		end
	end
end

function SetupStuds()
	for i,v in pairs(script:GetChildren()) do
		if v:IsA("Texture") then
			v:Clone().Parent = HRP
		end
	end
	
	CloneTexturesToParent(script.ArmTex,BodyParts.LArm)
	CloneTexturesToParent(script.ArmTex,BodyParts.LLeg)
	CloneTexturesToParent(script.ArmTex,BodyParts.RArm)
	CloneTexturesToParent(script.ArmTex,BodyParts.RLeg)
end

function SetupPlayer()
	local spawns = nil
	
	if PStatus.Value == "AtSpawn" then
		spawns = workspace.Lobby.Spawns:GetChildren()
	elseif PStatus.Value == "InGame" and workspace.Map:FindFirstChild("Spawns") then
		spawns = workspace.Map.Spawns:GetChildren()
	end
	
	local mdr = math.random(1,#spawns)
	for i = 1, #spawns do
		if i == mdr then
			SpawnPlayer(spawns[i])
		end
	end
	
	local FF = Instance.new("ForceField",Character)
	local BodyColor = Instance.new("BodyColors",Character)
	
	SetBodyColors(BodyColor)
	SetTShirt()
	GiveHat()
	SetupStuds()
	
	if not Player.Neutral then
		BodyColor.HeadColor = Player.TeamColor
		BodyColor.TorsoColor = Player.TeamColor
		BodyColor.LeftArmColor = BrickColor.new("Black")
		BodyColor.RightArmColor = BrickColor.new("Black")
		BodyColor.LeftLegColor = BrickColor.new("Black")
		BodyColor.RightLegColor = BrickColor.new("Black")
	end
	
	BodyColor.Name = "BodyColor"
	Face.Texture = "rbxassetid://1093033973"

	CharShirt.Changed:connect(function(v)
		SetTShirt()
	end)
	
	Humanoid.WalkSpeed = 20
	Humanoid.JumpPower = 55
	
	Debris:AddItem(FF, 5)
end

SetupPlayer()
Humanoid.HealthChanged:connect(UpdateHealth)