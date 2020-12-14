local Debris = game:GetService("Debris")
local Character = script.Parent
local Humanoid = Character:FindFirstChild("Humanoid")
local BodyColors = Character:FindFirstChild("Body Colors")
if not Humanoid or not BodyColors then script.Disabled = true end

function TagHumanoid(humanoid)
	local poisoner = script:FindFirstChild("poisoner")
	if (poisoner) then
		local creatorTag = Instance.new("ObjectValue")
		creatorTag.Value = poisoner.Value
		creatorTag.Name = "Creator"
		creatorTag.Parent = humanoid
		Debris:AddItem(creatorTag, 1)
	end
end

function ReplenishSkin()
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

function Poison(lastTime)
	for i,v in pairs(Character:GetChildren()) do
		if v:IsA("BasePart") then
			v.BrickColor = BrickColor.new(119)
		end
	end
	wait(1)
	ReplenishSkin()
	TagHumanoid(Humanoid)
	Humanoid.Health = Humanoid.Health - (Humanoid.MaxHealth / 8)
	wait(1)
end

for i = 1, 5 do
	Poison(i == 5)
	wait(.1)
end

script:Destroy()