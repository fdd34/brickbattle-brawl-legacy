-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Linked Leaderboard System [v1.3]
-- Scripted by ROBLOX, Modified by shloid
-------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Services
local Rep = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local DataStore = game:GetService("DataStoreService")
local PointsService = game:GetService("PointsService")

-- Variables
local Settings = {
	Version = "1.3",
	CTF_Mode = false,
	Punishment = false,
	SaveData = false,
	PlayerPoints = false,
	
	Kills = "Kills",
	Wipeouts = "Wipeouts",
	Captures = "Captures",
}
local Stands = {}

local Cleanup = script:WaitForChild("CleanupData")
local EventHandler = Rep:WaitForChild("EventHandler")
Cleanup.Parent = Rep

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Functions / Methods
-------------------------------------------------------------------------------------------------------------------------------------------------------------

function AwardPoints(player,num)
	if player and Settings.PlayerPoints then
		PointsService:AwardPoints(player, (num or 1))
	end
end

function CleanupData()
	for i,v in pairs(Players:GetPlayers()) do
		local ls = v:FindFirstChild("leadarstats")
		if ls then
			for i2,v2 in pairs(ls) do
				if v2:IsA("IntValue") or v2:IsA("NumberValue") then
					v2.Value = 0
				elseif v2:IsA("StringValue") then
					v2.Value = ""
				end
			end
		end
	end	
end

Cleanup.OnServerEvent:connect(function(player)
	CleanupData()
end)

function onHumanoidDied(humanoid,player)
	local stats = player:FindFirstChild("leaderstats")
	if stats then
		local deaths = stats:FindFirstChild(Settings.Wipeouts)
		
		if deaths then 
			deaths.Value = deaths.Value + 1
			HandleKillCount(humanoid, player)
		end
	end
end

function onPlayerRespawn(property, player)
	if property == "Character" and player.Character then
		local character = player.Character
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.Died:connect(function() 
				onHumanoidDied(humanoid, player) 
			end)
		end
	end
end

function FindKiller(humanoid)
	local cTagNames = {
		["Creator"] = true,
		["creator"] = true,
	}
	local tag = nil
	for i,v in pairs(humanoid:GetChildren()) do 
		if cTagNames[v.Name] then
			for i2, v2 in pairs(Players:GetPlayers()) do
				if v2 == v.Value then
					tag = v2
				end
			end
		end
	end
	return tag
end

function FindFeed(humanoid)
	local cTagNames = {
		["FeedTag"] = true,
		["feedtag"] = true,
	}
	local tag = nil
	for i,v in pairs(humanoid:GetChildren()) do
		if cTagNames[v.Name] then
			tag = v.Value
		end
	end
	return tag
end

function HandleKillCount(humanoid, player)
	local killer = FindKiller(humanoid)
	if killer and killer:FindFirstChild("leaderstats") then
		local stats = killer:FindFirstChild("leaderstats")
		local pinfo = killer:FindFirstChild("PlayerInfo")
		local KSValue = humanoid:FindFirstChild("IsDead")
		if stats and pinfo and KSValue and KSValue.Value == false then
			KSValue.Value = true
			local kills = stats:FindFirstChild(Settings.Kills)
			local bux = pinfo:FindFirstChild("BloxBux")
			if kills then
				print("[Server] Kill Feed constants:")
				print(">Killer: "..killer.Name)
				print(">Victim: "..humanoid.Parent.Name)
				if FindFeed(humanoid) ~= nil then
					print("[Server] Kill Feed Option #1.")
					local thisFeed = FindFeed(humanoid)
					EventHandler:FireAllClients("UpdateKillFeed",killer.Name,humanoid.Parent.Name,tostring(thisFeed))
				else
					print("[Server] Kill Feed Option #2.")
					EventHandler:FireAllClients("UpdateKillFeed",killer.Name,humanoid.Parent.Name)
				end
				if killer ~= player then
					bux.Value = bux.Value + 2
					kills.Value = kills.Value + 1
					AwardPoints(killer,1)
					--bux.Value = bux.Value + 1
				else
					if Settings.Punishment == true then
						kills.Value = kills.Value - 1
						AwardPoints(killer, -1)
						--bux.Value = bux.Value - 1
					end
				end
			end
		end
	end
end

function FindAllFlagStands(root)
	for i,v in pairs(root:GetChildren()) do
		if v:IsA("FlagStand") then
			table.insert(Stands,v)
		else
			FindAllFlagStands(v)
		end
	end
end

function hookUpListeners()
	for i = 1, #Stands do
		Stands[i].FlagCaptured:connect(function(plr)
			if plr:FindFirstChild("Humanoid") then
				if plr:FindFirstChild("leaderstats") then
					local stats = plr:FindFirstChild("leaderstats")
					local caps = stats:FindFirstChild(Settings.Captures)
					if caps == nil then return end
					caps.Value = caps.Value + 1
				end
			end
		end)
	end
end

function GetPlayerData(id,type)
	local Types = {
		["kills"] = Settings.Kills,
		["wipeouts"] = Settings.Wipeouts,
		["captures"] = Settings.Captures,
	}
	
	if id and type then
		local realKey = nil
		local returnValue = 0
	
		if DataStore:GetDataStore(id) then
			realKey = DataStore:GetDataStore(id)
			if Types[type] then
				realKey:UpdateAsync(Types[type], function(v)
					if not v then returnValue = 0 end
					returnValue = v
				end)
			else
				print("[Leaderboard] Error: Cannot find correct type of player data. Returning to 0.")
			end
		else
			print("[Leaderboard] Error: Cannot get player's data. Returning 0.")
		end
	
		return returnValue
	else
		return 0
	end
end

function setupLeaderstats(target)
	if target and target:IsA("Player") then 
		local keyId = target.Name.."_"..target.userId	
	
		local stats = Instance.new("Folder",target)
		stats.Name = "leaderstats"
	
		local kills = Instance.new("IntValue",stats)
		kills.Name = Settings.Kills
	
		local wos = Instance.new("IntValue",stats)
		wos.Name = Settings.Wipeouts
	
		if Settings.CTF_Mode then
			local caps = Instance.new("IntValue",stats)	
			caps.Name = Settings.Captures
		end
		
		if Settings.SaveData then
			kills.Value = GetPlayerData(keyId,"kills")
			wos.Value = GetPlayerData(keyId,"wipeouts")
			if Settings.CTF_Mode and stats:FindFirstChild(Settings.Captures) then
				local caps = stats:FindFirstChild(Settings.Captures)
				caps.Value = GetPlayerData(keyId,"captures")
			end
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Firing all the main functions.
-------------------------------------------------------------------------------------------------------------------------------------------------------------

FindAllFlagStands(workspace)
hookUpListeners()
if (#Stands > 0) then Settings.CTF_Mode = true end

Players.PlayerAdded:connect(function(player)
	-- Setting up the leaderboard.
	setupLeaderstats(player)
	
	-- Setting up the player's character.
	player.CharacterAdded:connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		local killstreakValue = Instance.new("IntValue",character)
		killstreakValue.Name = "KillStreak"
		local IsDead = Instance.new("BoolValue",humanoid)
		IsDead.Name = "IsDead"
		IsDead.Value = false
		humanoid.Died:connect(function() onHumanoidDied(humanoid, player) end)
	end)
end)

print("[Server] Leaderboard System [v"..Settings.Version.."] has been successfully loaded.")