local Run = game:GetService("RunService")
local Rep = game:GetService("ReplicatedStorage")
local RoundInfo = Rep:WaitForChild("RoundInfo")
local GameTime = RoundInfo:WaitForChild("GameTime")

function StartMakingTheObjFall(obj)
	if obj then
		for i,v in pairs(obj:GetChildren()) do
			if v:IsA("Model") then
				StartMakingTheObjFall(v)
			elseif v:IsA("BasePart") then
				spawn(function()
					for i = 10, 500 do
						if v.Name == "Side Block" then
							v.CFrame = v.CFrame * CFrame.new(0.1,0,0)
						elseif v.Name == "Light" then
							v:Destroy()
							--v.CFrame = v.CFrame * CFrame.new(0,0.1,0) -- original: 0,0.1,0
						elseif obj.Name == "Falling Tree" then
							v.CFrame = v.CFrame * CFrame.new(0,0,-0.1)								
						else
							v.CFrame = v.CFrame * CFrame.new(0,-0.1,0)
						end
						Run.Stepped:wait()
					end
				end)
			end
		end
	end
end

repeat wait() until GameTime.Value == 90

for i = 1, 10 do
	workspace.Sounds.Music.Volume = workspace.Sounds.Music.Volume - .1
	wait()
end

StartMakingTheObjFall(script.Parent:FindFirstChild("AA Fall Event"))

workspace.Sounds.Music:Stop()
workspace.Sounds.Music.Volume = 1
workspace.Sounds.Music.SoundId = "rbxassetid://1042342602"
workspace.Sounds.Music:Play()