local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local Ball = script.Parent
local Damage = 24
local colors = {45, 119, 21, 24, 23, 105, 104}
local Tag = Ball:findFirstChild("creator")
Ball.BrickColor = BrickColor.new(colors[math.random(1, #colors)])
if not Tag.Value.Neutral then
	Ball.BrickColor = Tag.Value.TeamColor
end

function TagHumanoid(humanoid)
	if Tag then
		local new_tag = Tag:Clone()
		new_tag.Parent = humanoid
		Debris:AddItem(new_tag,2)
	end
end

function GenerateDebris()
	for i = 1, 3 do
		local v = Vector3.new(math.random(-1,1), math.random(0,1), math.random(-1,1))
		local s = Instance.new("Part",workspace)
		s.Shape = 1 -- block
		s.formFactor = 2 -- plate
		s.Size = Vector3.new(1,.4,1)
		s.BrickColor = Ball.BrickColor
		s.Velocity = 15 * v
		s.CFrame = CFrame.new(Ball.Position + v, v)
		Debris:AddItem(s,15)
	end
end

function onTouched(hit)
	local ignoreTable = {
		["BadgeAwarder"] = true,
	}
	if hit and hit.Parent and hit.Parent ~= Tag.Value.Character then
		if Players:GetPlayerFromCharacter(hit.Parent) then
			local hitPlayer = Players:GetPlayerFromCharacter(hit.Parent)
			if hitPlayer:FindFirstChild("Status") then
				if hitPlayer.Status.Value == "AtSpawn" then
					Ball:Destroy()
					return
				end
			end
			
			if hitPlayer.TeamColor == Tag.Value.TeamColor or not hitPlayer.Neutral then
				Ball:Destroy()
				return
			end
		end
		local Forcefield = hit.Parent:FindFirstChild("Forcefield") or hit.Parent:FindFirstChild("ForceField") or nil
		if Forcefield then
			Ball:Destroy()
			return
		end
		if hit:IsA("SpawnLocation") or ignoreTable[hit.Name] or hit:FindFirstChild("BadgeAwarderScript") then
			-- dont do anything
		else
			if hit:IsA("BasePart") and hit:GetMass() < 1.2 * 200 then
				hit.BrickColor = Ball.BrickColor
			end
		end
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		if humanoid then
			TagHumanoid(humanoid)
			humanoid:TakeDamage(Damage)
		else
			GenerateDebris()
		end
		Ball:Destroy()
	end
end

Ball.Touched:connect(onTouched)