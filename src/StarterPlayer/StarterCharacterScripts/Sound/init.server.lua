--[[
	Author: @spotco
	This script creates sounds which are placed under the character head.
	These sounds are used by the "LocalSound" script.
	
	To modify this script, copy it to your "StarterPlayer/StarterCharacterScripts" folder keeping the same script name ("Sound").
	The default Sound script loaded for every character will then be replaced with your copy of the script.
]]--

local DefaultServerSoundEvent = nil
if UserSettings():IsUserFeatureEnabled("UserPlayCharacterSoundWhenFE") then
	DefaultServerSoundEvent = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultServerSoundEvent")
	if DefaultServerSoundEvent == nil then
		DefaultServerSoundEvent = Instance.new("RemoteEvent", game:GetService("ReplicatedStorage"))
		DefaultServerSoundEvent.Name = "DefaultServerSoundEvent"
	end
end

function CreateNewSound(name, id, looped, pitch, parent)
	local sound = Instance.new("Sound")
	sound.SoundId = id
	sound.Name = name
	sound.archivable = false
	sound.Parent = parent
	sound.Pitch = pitch
	sound.Looped = looped
	
	sound.MinDistance = 5
	sound.MaxDistance = 150
	sound.Volume = 0.65
	
	if UserSettings():IsUserFeatureEnabled("UserPlayCharacterSoundWhenFE") and DefaultServerSoundEvent then
		local CharacterSoundEvent = Instance.new("RemoteEvent", sound)
		CharacterSoundEvent.Name = "CharacterSoundEvent"
		local Players = game:GetService("Players")
		CharacterSoundEvent.OnServerEvent:connect(function(player)
			for _, p in pairs(Players:GetPlayers()) do
				if p ~= player then
					DefaultServerSoundEvent:FireClient(p, sound)
				end
			end
		end)
	end
	return sound
end

local head = script.Parent:FindFirstChild("Head")
if head == nil then
	error("Sound script parent has no child Head.")
	return
end


CreateNewSound("GettingUp", 	"rbxassetid://651794226",					false, 	1,		head)
CreateNewSound("Died", 		"rbxasset://sounds/uuhhh.mp3",							false, 	1,		head) 
CreateNewSound("FreeFalling", 	"",				true,	1,		head)
CreateNewSound("Jumping", 		"rbxassetid://400942696",					false,	1,		head)
CreateNewSound("Landing", 		"",				false,	1,		head)
CreateNewSound("Splash", 		"",					false, 	1,		head)
CreateNewSound("Running", 		"rbxassetid://174960816",		true, 	1,	head)
CreateNewSound("Swimming", 	"",					true,	1.6,	head)
CreateNewSound("Climbing", 	"rbxassetid://174960816",		true,	1,		head)