local Rep = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Weapons = Rep:WaitForChild("Weapons")

local self = script.Parent
local Handle = self:WaitForChild("Handle")
local CanObtain = true
local CurrentTool = "Illumina"

function FindWeapon()
	for i,v in pairs(Weapons:GetChildren()) do
		if v.Name == CurrentTool then
			print("[Stand] Found weapon.")
			return v
		end
	end	
	print("[Stand] Weapon is nil.")
	return nil
end

function UpdateHandle()
	if CanObtain then
		Handle.Transparency = 0
	else
		Handle.Transparency = 1
	end
	Handle.CanCollide = CanObtain
end

function GiveWeaponToPlayer(dir)
	if dir and Players:GetPlayerFromCharacter(dir) then
		local dirPlayer = Players:GetPlayerFromCharacter(dir)
		local dirBackpack = dirPlayer:FindFirstChild("Backpack")
		if dirBackpack and dirBackpack:FindFirstChild(CurrentTool) == nil and dir:FindFirstChild(CurrentTool) == nil then
			local bpChildren = dirBackpack:GetChildren()
			if #bpChildren == 9 then return end
			local weapon = FindWeapon()
			if weapon then
				print("[Stand] Giving weapon to directory.")
				weapon:Clone().Parent = dirBackpack
				CanObtain = false
			end
		end
	end
end

Handle.Touched:connect(function(hit)
	if hit and hit.Parent:FindFirstChild("Humanoid") and CanObtain then
		GiveWeaponToPlayer(hit.Parent)	
		UpdateHandle()
		wait(10)
		CanObtain = true
		UpdateHandle()
	end
end)