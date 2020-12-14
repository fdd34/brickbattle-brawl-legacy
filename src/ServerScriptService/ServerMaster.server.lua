--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Brickbattle Brawl [Server]
--------------------------------------------------------------------------------------------------------------------------------------------------------------

-- GetRandomSeed
-- by Dawgra
local symbols = {}
for number = 48, 57 do table.insert(symbols,string.char(number)) end
for letter = 97, 122 do table.insert(symbols,string.char(letter)) end

function GetRandomSeed(length)
	local seed = ""
	for i = 1, length do seed = seed..symbols[math.random(1,#symbols)] end
	return string.upper(seed)
end

-- Services
local Run = game:GetService("RunService")
local Rep = game:GetService("ReplicatedStorage")
local Chat = game:GetService("Chat")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local DataStore = game:GetService("DataStoreService")
local BadgeService = game:GetService("BadgeService")

-- Important Variables
local Maps = Rep:WaitForChild("Maps")
local RoundInfo = Rep:WaitForChild("RoundInfo")
local EventHandler = Rep:WaitForChild("EventHandler")
local Networking = {}
local SID = Rep:WaitForChild("ServerId")

local CurrentMap = RoundInfo:WaitForChild("CurrentMap")
local GameTime = RoundInfo:WaitForChild("GameTime")
local GameMode = RoundInfo:WaitForChild("Gamemode")
local GameMsg = RoundInfo:WaitForChild("GameMessage")
local IsInCamera = RoundInfo:WaitForChild("IsInCamera")
local GameSubMsg = GameMsg:WaitForChild("SubMessage")
local WinnerNameV = RoundInfo:WaitForChild("WinnerName")

local ActivateUIAnim = RoundInfo:WaitForChild("ActivateUIAnim")
local ActivateUIMsg = ActivateUIAnim:WaitForChild("Message")

local ActivateWinnerAnim = RoundInfo:WaitForChild("ActivateWinnerAnim")
local ActivateWinnerMsg = ActivateWinnerAnim:WaitForChild("Message")
local ActivateWinnerSubMsg = ActivateWinnerAnim:WaitForChild("SubMessage")

-- Music Variables
local MusicList = {
	["Intermission"] = 1077604,
	["WinnerReveal"] = 2723457,
	VictoryMusic = {
		[1] = {
			Id = 4764628264,
			TimeLength = 0
		}
		--[1] = {
		--	Id = 712611949,
		--	TimeLength = 0,
		--},
	}
}

-- Sounds Variables
local Sounds = workspace:WaitForChild("Sounds")
local Music = Sounds:WaitForChild("Music")

-- Other Variables
local PreviousMap = "None"
local RbxAssetId = "rbxassetid://"
local PlayersPlaying = 0
local ServerId = GetRandomSeed(6)
SID.Value = ServerId

--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Functions / Methods
--------------------------------------------------------------------------------------------------------------------------------------------------------------

function CheckCharacterData(player,info)
	if player and info and player:IsA("Player") then
		local defaultColors = {
			["Head"] = "Cool yellow",
			["LeftArm"] = "Cool yellow",
			["LeftLeg"] = "Dark green",
			["RightArm"] = "Cool yellow",
			["RightLeg"] = "Dark green",
			["Torso"] = "Bright blue",
			
		}
		local playerId = "user"..tostring(player.UserId)
		local playerChar = DataStore:GetDataStore(playerId.."_char")
		
		local infoChar = info:WaitForChild("Character")
		local charBC = infoChar:WaitForChild("BodyColors")
		local charHat = infoChar:WaitForChild("Hat")
		local charTS = infoChar:WaitForChild("TShirt")
		
		local bcNumb = charBC:GetChildren()
		
		--------------------------------------------------
		for i = 1, #bcNumb do
			local bcName = bcNumb[i].Name
			if bcName then
				--------------------------------------------------
				local success, skin = pcall(function()
					return playerChar:GetAsync(tostring(bcName))
				end)
				--------------------------------------------------
				if success then
					if skin ~= nil then
						bcNumb[i].Value = tostring(skin)
					else
						playerChar:UpdateAsync(bcName, function(v)
							local newValue = defaultColors[bcName]
							bcNumb[i].Value = newValue
							return newValue
						end)
					end
					--------------------------------------------------
					bcNumb[i].Changed:connect(function(v)
						playerChar:UpdateAsync(bcName, function()
							return v
						end)
					end)
					--------------------------------------------------
				end
				--------------------------------------------------
			end
		end
		--------------------------------------------------
		
		local hatSuccession, skin = pcall(function()
			return playerChar:GetAsync(tostring("Hat"))
		end)
		
		if hatSuccession then
			if skin ~= nil then
				charHat.Value = skin
			else
				playerChar:UpdateAsync("Hat", function(v)
					local newValue = "None"
					charHat.Value = newValue 
					return newValue
				end)
			end
			
			charHat.Changed:connect(function(v)
				playerChar:UpdateAsync("Hat", function()
					return v
				end)
			end)
		end
		
		local shirtSuccession, skin2 = pcall(function()
			return playerChar:GetAsync(tostring("TShirt"))
		end)
		
		
		if shirtSuccession then
			if skin2 ~= nil then
				charTS.Value = skin2
			else
				playerChar:UpdateAsync("TShirt", function(v)
					local newValue = "Default"
					charTS.Value = newValue 
					return newValue
				end)
			end
			
			charTS.Changed:connect(function(v)
				playerChar:UpdateAsync("TShirt", function()
					return v
				end)
			end)
		end
	end
end

function CheckShopData(player,info)
	if player and info and player:IsA("Player") then
		local playerId = "user"..tostring(player.UserId)
		local playerShop = DataStore:GetDataStore(playerId.."_store")
		
		local boughtHats = info:WaitForChild("BoughtHats")
		local shopItems = info:WaitForChild("ShopItems")
		
		local bhNumber = boughtHats:GetChildren()
		local siNumber = shopItems:GetChildren()
		
		local successionRate1 = 0
		local successionRate2 = 0
		
		----------------------------------------------------------------------
		for i = 1, #bhNumber do
			local hatName = bhNumber[i].Name
			if hatName then
				--------------------------------------------------
				local success, skin = pcall(function()
					return playerShop:GetAsync(tostring(hatName))
				end)
				--------------------------------------------------
				if success then
					successionRate1 = successionRate1 + 1
					--------------------------------------------------
					if skin ~= nil then
						bhNumber[i].Value = skin
					else
						playerShop:UpdateAsync(bhNumber[i].Name, function(v)
							local newValue = false
							bhNumber[i].Value = newValue 
							return newValue
						end)
					end
					--------------------------------------------------
					bhNumber[i].Changed:connect(function(v)
						playerShop:UpdateAsync(hatName, function()
							return v
						end)
					end)
					--------------------------------------------------
				end
				--------------------------------------------------
			end
		end
		---------------------------------------------------------------------
		
		----------------------------------------------------------------------
		for i = 1, #siNumber do
			local hatName = siNumber[i].Name
			if hatName then
				--------------------------------------------------
				local success, skin = pcall(function()
					return playerShop:GetAsync(tostring(hatName))
				end)
				--------------------------------------------------
				if success then
					successionRate2 = successionRate2 + 1
					--------------------------------------------------
					if skin ~= nil then
						siNumber[i].Value = skin
					else
						playerShop:UpdateAsync(siNumber[i].Name, function(v)
							local newValue = false
							siNumber[i].Value = newValue 
							return newValue
						end)
					end
					--------------------------------------------------
					siNumber[i].Changed:connect(function(v)
						playerShop:UpdateAsync(hatName, function()
							return v
						end)
					end)
					--------------------------------------------------
				end
				--------------------------------------------------
			end
		end
		---------------------------------------------------------------------
		
	end
end

function CheckDatastore(player,info)
	print("[Server] Booting up CheckDatastore function.")
	if player and info and player:IsA("Player") then
		local playerId = "user"..tostring(player.UserId)
		local playerInfo = DataStore:GetDataStore(playerId.."_info")
		
		local success1, bombSkin = pcall(function()
			return playerInfo:GetAsync("BombSkin")
		end)
		
		local success2, launcherSkin = pcall(function()
			return playerInfo:GetAsync("LauncherSkin")
		end)
		
		local success3, paintballSkin = pcall(function()
			return playerInfo:GetAsync("PaintballSkin")
		end)
		
		local success4, slingshotSkin = pcall(function()
			return playerInfo:GetAsync("SlingshotSkin")
		end)
		
		local success5, superballSkin = pcall(function()
			return playerInfo:GetAsync("SuperballSkin")
		end)
		
		local success6, swordSkin = pcall(function()
			return playerInfo:GetAsync("SwordSkin")
		end)
		
		local success7, trowelSkin = pcall(function()
			return playerInfo:GetAsync("TrowelSkin")
		end)
		
		local success8, bloxBux = pcall(function()
			return playerInfo:GetAsync("BloxBux")
		end)
		
		if success1 and bombSkin ~= nil then
			info.Skins.BombSkin.Value = bombSkin
		else
			playerInfo:UpdateAsync("BombSkin", function(v)
				local newValue = "Default"
				info.Skins.BombSkin.Value = newValue 
				return newValue
			end)
		end
		
		if success2 and launcherSkin ~= nil then
			info.Skins.LauncherSkin.Value = launcherSkin
		else
			playerInfo:UpdateAsync("LauncherSkin", function(v)
				local newValue = "Default"
				info.Skins.LauncherSkin.Value = newValue 
				return newValue
			end)
		end
		
		if success3  and paintballSkin ~= nil then
			info.Skins.PaintballSkin.Value = paintballSkin
		else
			playerInfo:UpdateAsync("PaintballSkin", function(v)
				local newValue = "Default"
				info.Skins.PaintballSkin.Value = newValue 
				return newValue
			end)
		end
		
		if success4 and slingshotSkin ~= nil then
			info.Skins.SlingshotSkin.Value = slingshotSkin
		else
			playerInfo:UpdateAsync("SlingshotSkin", function(v)
				local newValue = "Default"
				info.Skins.SlingshotSkin.Value = newValue 
				return newValue
			end)
		end
		
		if success5 and superballSkin ~= nil then
			info.Skins.SuperballSkin.Value = superballSkin
		else
			playerInfo:UpdateAsync("SuperballSkin", function(v)
				local newValue = "Default"
				info.Skins.SuperballSkin.Value = newValue 
				return newValue
			end)
		end
		
		if success6 and swordSkin ~= nil then
			info.Skins.SwordSkin.Value = swordSkin
		else
			playerInfo:UpdateAsync("SwordSkin", function(v)
				local newValue = "Default"
				info.Skins.SwordSkin.Value = newValue 
				return newValue
			end)
		end
		
		if success7 and trowelSkin ~= nil then
			info.Skins.TrowelSkin.Value = trowelSkin
		else
			playerInfo:UpdateAsync("TrowelSkin", function(v)
				local newValue = "Default"
				info.Skins.TrowelSkin.Value = newValue 
				return newValue
			end)
		end
		
		if success8 and bloxBux ~= nil then
			info.BloxBux.Value = bloxBux
		else
			playerInfo:UpdateAsync("BloxBux", function(v)
				local newValue = 0
				info.BloxBux.Value = newValue 
				return newValue
			end)
		end
		
		info.Skins.BombSkin.Changed:connect(function(v)
			playerInfo:UpdateAsync("BombSkin", function()
				return v
			end)
		end)
		
		info.Skins.LauncherSkin.Changed:connect(function(v)
			playerInfo:UpdateAsync("LauncherSkin", function()
				return v
			end)
		end)
		
		info.Skins.PaintballSkin.Changed:connect(function(v)
			playerInfo:UpdateAsync("PaintballSkin", function()
				return v
			end)
		end)
			
		info.Skins.SuperballSkin.Changed:connect(function(v)
			playerInfo:UpdateAsync("SuperballSkin", function()
				return v
			end)
		end)
		
		info.Skins.SwordSkin.Changed:connect(function(v)
			playerInfo:UpdateAsync("SwordSkin", function()
				return v
			end)
		end)
		
		info.Skins.TrowelSkin.Changed:connect(function(v)
			playerInfo:UpdateAsync("TrowelSkin", function()
				return v
			end)
		end)
		
		info.BloxBux.Changed:connect(function(v)
			playerInfo:UpdateAsync("BloxBux", function()
				return v
			end)
		end)
		
		print("[Server] "..player.Name.."'s Values")
		for i,v in pairs(info.Skins:GetChildren()) do
			print(">"..v.Name..": "..v.Value)
		end
		print(">BloxBux: "..info.BloxBux.Value)
		
	end
end

function SaveDatastore(player,info)
	print("[Server] Booting up SaveDatastore function.")
	if player and info and player:IsA("Player") then
		local playerId = "user"..tostring(player.UserId)
		local playerInfo = DataStore:GetDataStore(playerId.."_info")
		local playerShop = DataStore:GetDataStore(playerId.."_store")
		local success = pcall(function()
			playerInfo:SetAsync("BombSkin", info.Skins.BombSkin.Value)
			playerInfo:SetAsync("LauncherSkin", info.Skins.LauncherSkin.Value)
			playerInfo:SetAsync("PaintballSkin", info.Skins.PaintballSkin.Value)
			playerInfo:SetAsync("SlingshotSkin", info.Skins.SlingshotSkin.Value)
			playerInfo:SetAsync("SuperballSkin", info.Skins.SuperballSkin.Value)
			playerInfo:SetAsync("SwordSkin", info.Skins.SwordSkin.Value)
			playerInfo:SetAsync("TrowelSkin", info.Skins.TrowelSkin.Value)
			playerInfo:SetAsync("BloxBux", info.BloxBux.Value)
		end)
		if success then
			print("[Server] Successfully saved "..player.Name.."'s DataStore info.")
		else
			print("[Server] ERROR: Could not save "..player.Name.."'s DataStore info.")
		end
	end
end

function GivePlayerContent(player)
	print("[Server] Booting up GivePlayerContent function.")
	if player then
		local pe = Instance.new("RemoteEvent",player)
		pe.Name = "PlayerEvent"
		
		local ps = Instance.new("StringValue",player)
		ps.Name = "Status"
		ps.Value = "AtSpawn"
		
		local sp = Instance.new("BoolValue",player)
		sp.Name = "IsSpectating"
		sp.Value = false
		
		local ip = Instance.new("BoolValue",player)
		ip.Name = "PlayedGame"
		
		sp.Changed:connect(function(v)
			if v then
				print("[Server] "..player.Name.."'s Spectate Value has changed to: "..tostring(v))
			end
		end)
		
		local pi = script.PlayerInfo:Clone()
		pi.Parent = player
		
		pi.DescendantRemoving:connect(function()
			pi.Parent = game.ServerStorage
			Debris:AddItem(pi,10)
		end)
		
		local success = pcall(function()
			CheckDatastore(player,pi)
		end)
		
		local success2, message = pcall(function()
			CheckShopData(player,pi)
		end)
		
		local success3, message2 = pcall(function()
			CheckCharacterData(player,pi)
		end)
		
		if success then
			print("[Server] Successfully set up "..player.Name.."'s general DataStore info.")
		else
			print("[Server] ERROR: Could not set up "..player.Name.."'s general DataStore info.")
		end
		
		if success2 then
			print("[Server] Successfully set up "..player.Name.."'s Shop info.")
		else
			print("[Server] ERROR: Could not set up "..player.Name.."'s Shop info.")
			print("[Server] Error Message: "..message)
		end
		
		if success3 then
			print("[Server] Successfully set up "..player.Name.."'s Character info.")
		else
			print("[Server] ERROR: Could not set up "..player.Name.."'s Character info.")
			print("[Server] Error Message: "..message2)
		end
	end
end

function ChangeUIAnim(type,message)
	local Types = {
		["Activate"] = true,
		["Deactivate"] = true,
	}
	if type and Types[type] then
		wait()
		if type == "Activate" and message then
			print("[Server] Activating UI Animation #1.")
			ActivateUIMsg.Value = message
			if ActivateUIAnim.Value == false then
				ActivateUIAnim.Value = true
			end
		elseif type == "Deactivate" then
			print("[Server] Activating UI Animation #2.")
			ActivateUIAnim.Value = false
			ActivateUIMsg.Value = " "
		end
	end
end

function ChangeUIAnim2(type,message,sub)
	local Types = {
		["Activate"] = true,
		["Deactivate"] = true,
	}
	if type and Types[type] then
		wait()
		if type == "Activate" and message and sub then
			print("[Server] Activating UI Animation #2.")
			ActivateWinnerMsg.Value = message
			ActivateWinnerSubMsg.Value = sub
			ActivateWinnerAnim.Value = true
		elseif type == "Deactivate" then
			print("[Server] Deactivating UI Animation #2.")
			ActivateWinnerAnim.Value = false
		end
	end
end

function ChangeMusic(type,name,islooped)
	print("[Server] Booting up ChangeMusic function.")
	local Types = {
		["Intermission"] = true,
		["WinnerReveal"] = true,
		["SpecificMusic"] = true,
	}
	if type and Types[type] then
		Music:Stop()
		if type == "WinnerReveal" then
			local mdr = math.random(1,#MusicList.VictoryMusic)
			Music.SoundId = RbxAssetId..MusicList.VictoryMusic[mdr].Id
			Music.TimePosition = MusicList.VictoryMusic[mdr].TimeLength
			Music.Looped = false
		elseif type == "Intermission" then
			Music.SoundId = RbxAssetId..MusicList["Intermission"]
			Music.Looped = true
		elseif type == "SpecificMusic" and name then
			Music.SoundId = RbxAssetId..name
			Music.Looped = true
			if islooped ~= nil then
				Music.Looped = islooped
			end
		end
		Music:Play()
	end
end

function SelectGamemode()
	print("[Server] Booting up SelectGamemode function.")
	return "Free For All"	
end

function SetLighting(module)
	print("[Server] Booting up SetLighting function.")
	if module then
		local modLighting = module.Lighting
		Lighting.Ambient = modLighting.Ambient 
		Lighting.ColorShift_Top = modLighting.ColorShift.Top
		Lighting.ColorShift_Bottom = modLighting.ColorShift.Bottom
		Lighting.OutdoorAmbient = modLighting.OutdoorAmbient
		Lighting.FogColor = modLighting.FogColor
		
		Lighting.Brightness = modLighting.Brightness
		Lighting.ClockTime = modLighting.ClockTime
		Lighting.GeographicLatitude = modLighting.GeographicLatitude
		Lighting.FogEnd = modLighting.FogEnd
		Lighting.FogStart = modLighting.FogStart
		
		local modSkybox = module.MapSky
		local thisSkybox = (Lighting:FindFirstChild("Skybox") or Instance.new("Sky",Lighting))
		thisSkybox.Name = "Skybox"
		thisSkybox.MoonTextureId = modSkybox.Moon
		thisSkybox.MoonAngularSize = modSkybox.MoonAngularSize
		
		thisSkybox.SunTextureId = modSkybox.Sun
		thisSkybox.SunAngularSize = modSkybox.SunAngularSize
		
		thisSkybox.SkyboxBk = modSkybox.Back
		thisSkybox.SkyboxDn = modSkybox.Down
		thisSkybox.SkyboxFt = modSkybox.Front
		thisSkybox.SkyboxLf = modSkybox.Left
		thisSkybox.SkyboxRt = modSkybox.Right
		thisSkybox.SkyboxUp = modSkybox.Up
		
		thisSkybox.StarCount = modSkybox.StarCount
		thisSkybox.CelestialBodiesShown = modSkybox.CelestialBodiesShown
	else
		Lighting.Ambient = Color3.new(0, 0, 0)
		Lighting.ColorShift_Top = Color3.new(0, 0, 0)
		Lighting.ColorShift_Bottom = Color3.new(0, 0, 0)
		Lighting.OutdoorAmbient = Color3.new(125/255, 125/255, 125/255)
		Lighting.FogColor = Color3.new(255/255, 255/255, 255/255)
		
		Lighting.Brightness = 1
		Lighting.ClockTime = 12
		Lighting.GeographicLatitude = 41.733
		Lighting.FogEnd = 100000
		Lighting.FogStart = 0
		
		if Lighting:FindFirstChild("Skybox") then
			Lighting:FindFirstChild("Skybox"):Destroy()
		end
		
		local newSky = script.Skybox:Clone()
		newSky.Parent = Lighting
	end
end

function ClearMapContent()
	print("[Server] Booting up ClearMapContent function.")
	for i,v in pairs(workspace.Map:GetChildren()) do
		v:Destroy()
	end	
	SetLighting() 
	CurrentMap.Value = "None"
end

function SelectMap()
	print("[Server] Booting up SelectMap function.")
	local selectedMap = nil
	local mapSettings = nil
	
	local mapPool = Maps:GetChildren()
	local mapNumb = math.random(1,#mapPool)
	for i = 1, #mapPool do
		if i == mapNumb then
			selectedMap = mapPool[i]
			mapSettings = mapPool[i]:WaitForChild("Settings")
		end
	end
	
	if selectedMap.Name == PreviousMap then
		selectedMap, mapSettings = SelectMap()
	end
	PreviousMap = selectedMap.Name
	if RoundInfo.CurrentMap.Value ~= "None" then
		if Maps:FindFirstChild(RoundInfo.CurrentMap.Value) then
			selectedMap = Maps:FindFirstChild(RoundInfo.CurrentMap.Value)
			mapSettings = Maps:FindFirstChild(RoundInfo.CurrentMap.Value):WaitForChild("Settings")
		end
	end
	return selectedMap, mapSettings
end

function SetGameMessage(message,submsg)
	if message then
		GameMsg.Value = message
		if submsg then
			GameSubMsg.Value = submsg
		end
	end
end

function MoveTheMapCloneToWorkspace(map,newParent)
	print("[Server] Booting up MoveTheMapCloneToWorkspace function.")
	local mClone = map:Clone()
	local mCount = 0
	for i,v in pairs(mClone:GetChildren()) do
		mCount = mCount + 1
		if mCount >= 50 then
			mCount = 0
			Run.Heartbeat:wait()
		end
		if v:IsA("Model") then
			local vModel = Instance.new("Model")
			vModel.Name = v.Name
			if v.Name == "MapContent" or v.Name == "Spawns" then
				vModel.Parent = workspace.Map
			else
				local mapContent = workspace.Map:FindFirstChild("MapContent") or Instance.new("Model",workspace.Map)
				mapContent.Name = "MapContent"
				if v.Parent ~= "MapContent" and mapContent:FindFirstChild(v.Parent.Name) then
					vModel.Parent = mapContent:FindFirstChild(v.Parent.Name)
				else
					vModel.Parent = mapContent
				end
			end
			MoveTheMapCloneToWorkspace(v,vModel)
		elseif v:IsA("BasePart") then
			v.Anchored = true
			v.Locked = false
			if v.Name == "FakeSpawn" then
				local mapSpawns = workspace.Map:FindFirstChild("Spawns") or Instance.new("Model",workspace.Map)
				mapSpawns.Name = "Spawns"
				v:Clone().Parent = mapSpawns
			else
				if newParent then
					v:Clone().Parent = newParent
				else
					local mapContent = workspace.Map:FindFirstChild("MapContent") or Instance.new("Model",workspace.Map)
					mapContent.Name = "MapContent"
					v:Clone().Parent = mapContent
				end
			end
		else
			v:Clone().Parent = newParent
		end
	end
end

function ClearMapContent2(obj)
	local mCount = 0
	for i,v in pairs(obj:GetChildren()) do
		mCount = mCount + 1
		if mCount >= 50 then
			mCount = 0
			Run.Heartbeat:wait()
		end
		if v:IsA("Model") then
			ClearMapContent(v)
		else
			v:Destroy()
		end
	end
end

function GetTheWinner()
	print("[Server] Booting up GetTheWinner function.")
	local theMVP = "No one."
	local theMVPKills = 0
	local theMVPWOs = 0
	for i,v in pairs(Players:GetPlayers()) do
		if v:FindFirstChild("leaderstats") then
			local vWOs = v.leaderstats:FindFirstChild("Wipeouts")
			for i2,v2 in pairs(v.leaderstats:GetChildren()) do
				if v2.Name == "Kills" then
					if v2.Value > theMVPKills then
						theMVP = v.Name
						theMVPKills = v2.Value
						theMVPWOs = vWOs.Value
					elseif v2.Value == theMVPKills then
						if vWOs.Value < theMVPWOs then
							theMVP = v.Name
							theMVPKills = v2.Value
							theMVPWOs = vWOs.Value
						elseif vWOs.Value == theMVPWOs then
							local mdr = math.random(1,2)
							if mdr == 2 then
								theMVP = v.Name
								theMVPKills = v2.Value
								theMVPWOs = vWOs.Value
							end
						end
					end
				end
			end
		end
	end
	local buxAwarded = math.floor(30 * (theMVPKills / theMVPWOs))
	if theMVPWOs <= 0 and theMVPKills > 0 then
		buxAwarded = 30 * theMVPKills
	end
	if buxAwarded < 0 or buxAwarded < 30 or theMVPKills <= 0 and theMVPWOs <= 0 then
		buxAwarded = 30
	end
	local themsg = "With a total of "..tostring(theMVPKills).." kills and "..tostring(theMVPWOs).." wipeouts! Awarding "..tostring(buxAwarded).." bux to "..tostring(theMVP)
	if theMVP == "No one." then
		themsg = "Better luck next time... :("
	end
	WinnerNameV.Value = theMVP
	return theMVP, themsg, buxAwarded
end

function FindASeat()
	print("[Server] Booting up FindASeat function.")
	local seatsGroup = workspace.WinnerRoom.Seats:GetChildren()
	for i = 1, #Players:GetPlayers() do
		local selectedSeat = workspace.WinnerRoom.Seats:FindFirstChild("Seat"..tostring(i))
		if selectedSeat then
			print("[Server] Selected seat: "..selectedSeat.Name)
			local vIsTaken = selectedSeat:FindFirstChild("IsTaken")
			if vIsTaken and vIsTaken.Value == false then
				vIsTaken.Value = true
				print("[Server] Found a seat!")
				return selectedSeat
			end
		end
	end
	return nil
end

function ResetSeats()
	print("[Server] Booting up ResetSeats function.")
	for i,v in pairs(workspace.WinnerRoom.Seats:GetChildren()) do
		if v:IsA("Model") then
			local vIsTaken = v:FindFirstChild("IsTaken")
			local vSeat = v:FindFirstChild("Seat")
			if vIsTaken then
				vIsTaken.Value = false
			end
			wait(.01)
		end			
	end
end

function EnableConfette(obj)
	if obj then
		for i,v in pairs(obj:GetChildren()) do
			if v:IsA("Model") or v:IsA("Part") then
				EnableConfette(v)
			elseif v:IsA("ParticleEmitter") then
				if v.Enabled == true then
					v.Enabled = false
				else
					v.Enabled = true
				end
			end
		end
	end
end

function EditWinrarScene(type)
	local Types = {
		["Start"] = true,
		["End"] = true,
	}
	
	local Light1 = workspace.WinnerRoom:WaitForChild("Light1")
	local Light2 = workspace.WinnerRoom:WaitForChild("Light2")
	local Confette = workspace.WinnerRoom:WaitForChild("Confette")
	local WinrarPad = workspace.WinnerRoom:WaitForChild("WinnerPad")
	local CameraRP = workspace.WinnerRoom:WaitForChild("CameraRootPart")
	
	local L1 = Light1:WaitForChild("Light"):WaitForChild("SpotLight")
	local L2 = Light2:WaitForChild("Light"):WaitForChild("SpotLight")
	
	local NeonPart = WinrarPad:WaitForChild("NeonPart")
	local NPLight = NeonPart:WaitForChild("SurfaceLight")
	local LightsOn = CameraRP:WaitForChild("LightsOn")
	
	if type and Types[type] then
		if type == "Start" then
			LightsOn:Play()
			L1.Enabled = true
			L2.Enabled = true
			NeonPart.Material = Enum.Material.Neon
			NPLight.Enabled = true
		elseif type == "End" then
			L1.Enabled = false
			L2.Enabled = false
			NeonPart.Material = Enum.Material.SmoothPlastic
			NPLight.Enabled = false
		end
		EnableConfette(Confette)
	end
end

function TeleportEveryone(winner)
	print("[Server] Booting up TeleportEveryone function.")
	IsInCamera.Value = true
	for i,v in pairs(Players:GetPlayers()) do
		local vChar = v.Character
		if vChar then
			local vTorso = vChar:FindFirstChild("HumanoidRootPart")
			local vHumanoid = vChar:FindFirstChild("Humanoid")
			if vTorso and vHumanoid then
				vHumanoid.JumpPower = 0
				vHumanoid.WalkSpeed = 0
				if v.Name == winner then
					vTorso.CFrame = workspace.WinnerRoom.WinnerSpawnPoint.CFrame
				else
					local vSeat = FindASeat()
					if vSeat then
						vTorso.CFrame = vSeat.Seat.CFrame + Vector3.new(0, 5, 0)
					end 
				end
			end
			wait(.01)
		end
	end
end

function PlayerStatusStuffThing(value)
	print("[Server] Booting up PlayerStatusStuffThing function.")
	if value == true then
		for i,v in pairs(Players:GetPlayers()) do
			local vChar = v.Character
			if vChar then
				local vHumanoid = vChar:FindFirstChild("Humanoid")
				if vHumanoid then
					vHumanoid.JumpPower = 0
					vHumanoid.WalkSpeed = 0
				end
				wait(.01)
			end
		end
	else
		for i,v in pairs(Players:GetPlayers()) do
			local vChar = v.Character
			if vChar then
				local vHumanoid = vChar:FindFirstChild("Humanoid")
				if vHumanoid then
					vHumanoid.JumpPower = 55
					vHumanoid.WalkSpeed = 20
				end
			end
		end
	end
end

function ClearStats()
	print("[Server] Booting up ClearStats function.")
	for i,v in pairs(Players:GetPlayers()) do
		if v:FindFirstChild("leaderstats") then
			for i2,v2 in pairs(v.leaderstats:GetChildren()) do
				v2.Value = 0
				if v2.Name == "Caps" then
					v2:Destroy()
				end
				wait(.01)
			end
		end
	end
end

function SpawnPlayer(hrp,target)
	if hrp and target then
		hrp.CFrame = target.CFrame + Vector3.new(0, 5, 0)
	end
end

function SetPlayerStatus(type)
	print("[Server] Booting up SetPlayerStatus function.")
	if type then
		if type == "InGame" then
			for i,v in pairs(Players:GetPlayers()) do
				if v:FindFirstChild("Status") and v.Character then
					local vChar = v.Character
					local vHRP = vChar:FindFirstChild("HumanoidRootPart")
					local vStatus = v:FindFirstChild("Status")
					local vSpectating = v:FindFirstChild("IsSpectating")
					local vPlayedGame = v:FindFirstChild("PlayedGame")
					if vStatus and vHRP and vSpectating.Value == false then
						if vStatus.Value == "InGame" then
							-- do nothing
						else
							vStatus.Value = "InGame"
							wait(.2)
							if workspace.Map:FindFirstChild("Spawns") then
								local spawns = workspace.Map:FindFirstChild("Spawns"):GetChildren()
								local selectedLol = math.random(1,#spawns)
								for i = 1, #spawns do
									if i == selectedLol then
										SpawnPlayer(vHRP,spawns[i])
									end
								end
							end
							vPlayedGame.Value = false
							PlayersPlaying = PlayersPlaying + 1
						end
					end
					wait(.1)
				end
			end
		elseif type == "AtSpawn" then
			for i,v in pairs(Players:GetPlayers()) do
				if v:FindFirstChild("Status") and v.Character then
					local vChar = v.Character
					local vHRP = vChar:FindFirstChild("HumanoidRootPart")
					local vStatus = v:FindFirstChild("Status")
					local vSpectating = v:FindFirstChild("IsSpectating")
					local vPlayedGame = v:FindFirstChild("PlayedGame")
					if vStatus.Value == "InGame" then
						vPlayedGame.Value = true
					end
					vStatus.Value = "AtSpawn" -- just in case some shit happens or w/e
					if vSpectating.Value == false and vHRP then
						wait(.2)
						if workspace.Lobby:FindFirstChild("Spawns") then
							local spawns = workspace.Lobby:FindFirstChild("Spawns"):GetChildren()
							local selectedLol = math.random(1,#spawns)
							for i = 1, #spawns do
								if i == selectedLol then
									SpawnPlayer(vHRP,spawns[i])
								end
							end
						end
						for i2,v2 in pairs(vChar:GetChildren()) do
							if v2:IsA("Tool") then
								v2:Destroy()
							end
						end
					end
					wait(.1)
				end
			end
		end
	end
end

function StopRound()
	print("[Server] Booting up StopRound function.")
	ClearStats()
	ClearMapContent()
	ResetSeats()
	GameTime.Value = 20
	GameMode.Value = "Intermission"
end

function GameLogic()
	if GameTime.Value > 0 then
		GameTime.Value = GameTime.Value - 1
		if GameMode.Value == "Intermission" then
			SetGameMessage("Intermission ("..GameTime.Value..")","Please wait...")
		else
			SetGameMessage("Time ("..GameTime.Value..")"," ")
		end
	else
		if GameMode.Value == "Intermission" then
			SetGameMessage("Selecting map..."," ")
			local newMap, mapSettings = SelectMap()
			mapSettings = require(mapSettings)
			wait(3)
			SetGameMessage("Map Selected: "..mapSettings.MapName,"by "..mapSettings.MapCreator)
			wait(4)
			SetGameMessage("Loading map...","Please be patient. The server may lag out depending on the brick count.")
			MoveTheMapCloneToWorkspace(newMap,workspace.Map)
			SetLighting(mapSettings)
			Music:Stop()
			PlayersPlaying = 0
			SetPlayerStatus("InGame")
			if PlayersPlaying < 2 then
				local PLimit = 2
				if Run:IsStudio() or RoundInfo.DebugMode.Value == true then
					PLimit = 1
				else
					PLimit = 2
				end
				while PlayersPlaying < PLimit do
					SetGameMessage("There are no players playing!","Please uncheck spectate mode so the game can start.")
					SetPlayerStatus("InGame")
					if PlayersPlaying > PLimit then
						break
					end
					wait(1)
				end
			end
			PlayerStatusStuffThing(true)
			for i = 10, 1, -1 do
				ChangeUIAnim("Activate","Starting match in "..i.."...")
				wait(1)
			end
			PlayerStatusStuffThing(false)
			ChangeMusic("SpecificMusic",mapSettings.MusicId)
			ChangeUIAnim("Deactivate")
			SetGameMessage("Match has begun!"," ")
			GameMode.Value = "Free For All"
			GameTime.Value = 180
			wait(.5)
		else
			ChangeUIAnim("Activate","Round has ended!")
			wait(.5)
			Music:Stop()
			wait(.5)
			SetGameMessage(" "," ")
			wait(.5)
			PlayerStatusStuffThing(true)
			wait(2)
			
			SetPlayerStatus("AtSpawn")
			GameMode.Value = "SelectingWinner"
			wait(1.5)
			
			local winnerName, winnerMessage, winnerReward = GetTheWinner()
			ChangeUIAnim("Activate","Gathering results...")
			RoundInfo.WinnerName.Value = tostring(winnerName)
			TeleportEveryone(winnerName)
			ResetSeats()
			ClearMapContent2(workspace.Map)
			wait()
			ClearMapContent()
			wait(2)
			
			ChangeUIAnim("Deactivate")
			wait(.7)
			EditWinrarScene("Start")
			wait(1.3)
			ChangeMusic("WinnerReveal")
			ChangeUIAnim2("Activate", winnerName, winnerMessage)
			workspace.Sounds.Congrats:Play()
			wait(.1)
			if string.find(tostring(workspace.Sounds.Music.SoundId),"712611949") then
				wait(15)
			else
				wait(26.5)
			end
			
			for i,v in pairs(Players:GetPlayers()) do
				if v:FindFirstChild("PlayedGame") and v:FindFirstChild("IsSpectating") then
					local vSpectating = v:FindFirstChild("IsSpectating")
					local vPlayedGame = v:FindFirstChild("PlayedGame")
					if vPlayedGame.Value == true then
						vSpectating.Value = false
					end
				end
				if v:FindFirstChild("PlayerInfo") and v.Name == tostring(winnerName) then
					v.PlayerInfo.BloxBux.Value = v.PlayerInfo.BloxBux.Value + tonumber(winnerReward)
				end
			end
			
			for i,v in pairs(Players:GetPlayers()) do
				if v:IsA("Player") then
					v:LoadCharacter()
				end
			end
			
			IsInCamera.Value = false
			ChangeMusic("Intermission","Intermission")
			EditWinrarScene("End")
			ChangeUIAnim2("Deactivate")
			StopRound()
		end
	end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Networking Functions / Methods
--------------------------------------------------------------------------------------------------------------------------------------------------------------

Networking.Functions = {
	SendChatMessage = function(pname,message)
		if pname and message then
			local newMessage = message
			if Players:FindFirstChild(pname) then
				-- Chat:FilterStringForBroadcast(message,Players:FindFirstChild(pname))
				newMessage = Chat:FilterStringAsync(message,Players:FindFirstChild(pname),Players:FindFirstChild(pname))
				print("[Server] New Message: "..newMessage)
			end
			EventHandler:FireAllClients("ChatMessage",pname,newMessage)
		end
	end,
	
	SendSpecificMessage = function(pname,message)
		if pname and message then
			EventHandler:FireAllClients("GenerateSpecMessage",pname,message)
		end
	end,
	
	GiveBadgeToPlayer = function(player,id,bname,playsound)
		if player and id and bname then -- and BadgeService:UserHasBadge(player.userId, id)
			if playsound then
				--BadgeSound:Play()
			end
			EventHandler:FireAllClients("GenerateSpecMessage","Server",player.Name.." has obtained the "..bname.." badge!")
			--BadgeService:AwardBadge(player.userId,id)
		end
	end,
	
	MoveToolToBackpack = function(character)
		if character then
			local cPlayer = Players:GetPlayerFromCharacter(character)
			if cPlayer then
				local cBackpack = cPlayer:FindFirstChild("Backpack")
				if cBackpack then
					for i,v in pairs(character:GetChildren()) do
						if v:IsA("Tool") then
							v.Parent = cBackpack
						end
					end
				end
			end
		end
	end,
	
	SetBackpackUI = function(ui,enabled)
		if ui then
			ui.Enabled = enabled
		end
	end,
	
	SetStatusValue = function(value,player)
		if value and player then
			value.Value = "InGame"
			player:LoadCharacter()
		end
	end,
	
	SetSpectateMode = function(player)
		if player and player:FindFirstChild("IsSpectating") then
			player:FindFirstChild("IsSpectating").Value = not player:FindFirstChild("IsSpectating").Value
		end
	end,
}

EventHandler.OnServerEvent:connect(function(player,fname,...)
	if fname then
		Networking.Functions[fname](...)
	end
end)

Rep.SetSpectateMode.OnServerEvent:connect(function(player,isSpawning)
	if player and player:FindFirstChild("IsSpectating") then
		if player:FindFirstChild("IsSpectating").Value == true then
			player:FindFirstChild("IsSpectating").Value = false
		else
			player:FindFirstChild("IsSpectating").Value = true
		end
		print("[Server] Set "..player.Name.."'s Spectate Value to: "..tostring(player:FindFirstChild("IsSpectating").Value))
		if isSpawning == true then
			player.Status.Value = "InGame"
			player:LoadCharacter()
		end
	end
end)

Rep.SetSpecificChar.OnServerEvent:connect(function(player,type,newVal,newVal2)
	local Types = {
		["BodyColor"] = true,
		["Hat"] = true,
		["TShirt"] = true,
	}
	if player and type and Types[type] and newVal then
		local pInfo = player:FindFirstChild("PlayerInfo")
		if pInfo then
			local pChar = pInfo:FindFirstChild("Character")
			if type == "BodyColor" and newVal2 then
				local pBCol = pChar:FindFirstChild("BodyColors")
				if pBCol then
					local pVal = pBCol:FindFirstChild(tostring(newVal))
					if pVal then
						pVal.Value = newVal2
					end
				end
			elseif type == "Hat" then
				local pHat = pChar:FindFirstChild("Hat")
				if pHat then
					pHat.Value = tostring(newVal)
				end
			elseif type == "TShirt" then
				local pTS = pChar:FindFirstChild("TShirt")
				if pTS then
					pTS.Value = tostring(newVal)
				end
			end
		end
	end
end)

Rep.BuyItemEvent.OnServerEvent:connect(function(player,type,itemName,cost)
	local Types = {
		["BoughtHats"] = true,
		["ShopItems"] = true,
	}
	local ShopModule = require(Rep:FindFirstChild("ShopModule"))
	if player and type and Types[type] and itemName and cost then
		local pInfo = player:FindFirstChild("PlayerInfo")
		if pInfo then
			local pBux = pInfo:FindFirstChild("BloxBux")
			local pLoL = pInfo:FindFirstChild(type)
			if pLoL and pBux then
				local pItem = pLoL:FindFirstChild(itemName)
				if pItem then
					if pBux.Value >= cost then
						print("[Server] Removing "..player.Name.."'s Cash.")
						pBux.Value = pBux.Value - cost
						pItem.Value = true
					end
				end
			end
		end
	end
end)

Rep.ResetBind.OnServerEvent:connect(function(player)
	if player then
		if GameMode.Value == "SelectingWinner" then
			-- do nothing
		else
			local pChar = player.Character
			if pChar then
				local pHum = pChar:FindFirstChild("Humanoid")
				if pHum then
					pHum:TakeDamage(math.huge)
				end
			end
		end
	end
end)

--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Setting up the Server
--------------------------------------------------------------------------------------------------------------------------------------------------------------

Players.PlayerAdded:connect(function(player)
	Networking.Functions["SendSpecificMessage"]("Server",player.Name.." has joined the server.")
	GivePlayerContent(player)
end)

Players.PlayerRemoving:connect(function(player)
	Networking.Functions["SendSpecificMessage"]("Server",player.Name.." has left the server.")
end)

if Run:IsStudio() then
	GameMode.Value = "Intermission"
end

Music:Play()

while true do
	if Run:IsStudio() then -- basically an automatic debug enabler
		GameLogic()
	else
		if #Players:GetPlayers() > 1 or RoundInfo.DebugMode.Value == true then
			if GameMode.Value == "Waiting" then
				GameMode.Value = "Intermission"
			end
			GameLogic()
		else
			if GameMode.Value == "Waiting" or GameMode.Value == "Intermission" then
				SetGameMessage("You must wait until 2 or more players join the server.","(Note: You can also invite your friends to the server too.)")
			end
		end
	end
	wait(1)
end