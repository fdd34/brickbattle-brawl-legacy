local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local Ball = script.Parent
local Damage = 30
local colors = {45, 119, 21, 24, 23, 105, 104}
local Tag = Ball:FindFirstChild("creator")
local fTag = Ball:WaitForChild("FeedTag")
Ball.BrickColor = BrickColor.new(colors[math.random(1, #colors)])

if not Tag.Value.Neutral then
	Ball.BrickColor = Tag.Value.TeamColor
end

local SurfaceLight = Instance.new("PointLight",Ball)
SurfaceLight.Brightness = .8
SurfaceLight.Color = Ball.BrickColor.Color

function RemoveTagFromHumanoid(hum)
	for i,v in pairs(hum:GetChildren()) do
		if v:IsA("ObjectValue") or v:IsA("StringValue") then
			v:Destroy()
		end
	end	
end

function TagHumanoid(humanoid)	
	if Tag then
		RemoveTagFromHumanoid(humanoid)
		local new_tag = Tag:Clone()
		new_tag.Parent = humanoid
		
		local feed_tag = fTag:Clone()
		feed_tag.Parent = humanoid
		
		Debris:AddItem(new_tag, 1.5)
		Debris:AddItem(feed_tag, 1.5)
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
		print("[Paintball] Touched: "..tostring(hit.Name))
		print("[Paintball] Part's parent: "..tostring(hit.Parent.Name))
		
		if Players:GetPlayerFromCharacter(hit.Parent) then
			local hitPlayer = Players:GetPlayerFromCharacter(hit.Parent)
			if hitPlayer:FindFirstChild("Status") then
				if hitPlayer.Status.Value == "AtSpawn" then
					Ball:Destroy()
					return
				end
			end
			
			if hitPlayer.TeamColor == Ball.BrickColor and hitPlayer.Neutral == false and Tag.Value.Neutral == false then
				Ball:Destroy()
				return
			end
		end
		
		local Forcefield = hit.Parent:FindFirstChild("Forcefield") or hit.Parent:FindFirstChild("ForceField") or nil
		if Forcefield then Ball:Destroy() return end
		if hit:IsA("BasePart") and hit:GetMass() < 1.2 * 200 then
			hit.BrickColor = Ball.BrickColor
			print("[Paintball] Changed "..tostring(hit.Name).."'s BrickColor.")
		else
			print("[Paintball] Couldn't change "..tostring(hit.Name).."'s BrickColor.")
		end
		
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		if humanoid and humanoid.Health > 0 then
			print("[Paintball] Found "..tostring(hit.Parent.Name).."'s Humanoid!")
			print("[Paintball] "..tostring(hit.Parent.Name).."'s health before: "..humanoid.Health)
			TagHumanoid(humanoid)
			humanoid:TakeDamage(Damage)
			print("[Paintball] "..tostring(hit.Parent.Name).."'s health after: "..humanoid.Health)
		else
			GenerateDebris()
		end
		
		Ball:Destroy()
	end
end

Ball.Touched:connect(onTouched)