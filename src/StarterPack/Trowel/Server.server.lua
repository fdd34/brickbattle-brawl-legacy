--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RbxClient Slingshot [Server]
--------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Services
local Run = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

-- Tool
local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local BuildSound = Handle:WaitForChild("BuildSound")
local EventHandler = Tool:WaitForChild("EventHandler")

-- Important Variables
local wallHeight = 4
local brickSpeed = 0.04
local wallWidth = 12
local Equipped = false
local Networking = {}

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

function TagWall(part)
	if part and not part:FindFirstChild("creator") then
		local creatorTag = Instance.new("ObjectValue",part)
		creatorTag.Name = "WallCreator"
		creatorTag.Value = Player
	end
end

function placeBrick(cf, pos, color, parent)
	local brick = Instance.new("Part", parent)
	brick.BrickColor = color
	brick.CFrame = cf * CFrame.new(pos + brick.Size / 2)
	brick:MakeJoints()
	brick.Anchored = true
	brick.TopSurface = Enum.SurfaceType.Smooth
	brick.BottomSurface = Enum.SurfaceType.Smooth
	Debris:AddItem(brick,24)
	return brick, pos + brick.Size
end

function snap(v)
	if math.abs(v.x)>math.abs(v.z) then
		if v.x>0 then
			return Vector3.new(1,0,0)
		else
			return Vector3.new(-1,0,0)
		end
	else
		if v.z>0 then
			return Vector3.new(0,0,1)
		else
			return Vector3.new(0,0,-1)
		end
	end
end

function buildWall(cf)
	if Character and Player then
		local color = BrickColor.Random()
		local bricks = {}
		local wallModel = Instance.new("Model",workspace)
		wallModel.Name = "Wall"
		TagWall(wallModel)
		
		if not Player.Neutral then
			color = Player.TeamColor
		end
		
		assert(wallWidth > 0)
		local y = 0
		while y < wallHeight do
			local p
			local x = -wallWidth/2
			while x < wallWidth/2 do
				local brick
				brick, p = placeBrick(cf, Vector3.new(x, y, 0), color, wallModel)
				x = p.x
				table.insert(bricks, brick)
				wait(brickSpeed)
			end
			y = p.y
		end
	end
end

function OnActivated(mouse)
	if Equipped and Tool.Enabled and Head and Humanoid and Humanoid.Health > 0 then
		Tool.Enabled = false
		local targetPos = mouse
		local newPos = (targetPos - Head.Position).unit
		local lookAt = snap(newPos)
		local cf = CFrame.new(targetPos, targetPos + lookAt)
		BuildSound:Play()
		buildWall(cf)
		wait(4)
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
	BuildSound:Play()
	Equipped = true
end)

Tool.Unequipped:connect(function()
	BuildSound:Play()
	Equipped = false
end)

Tool.Changed:connect(UpdateMouse)