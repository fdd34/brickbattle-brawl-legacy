--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Brickbattle Brawl [Client]
--------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Services
local Run = game:GetService("RunService")
local Rep = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local Teams = game:GetService("Teams")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local LoadLibrary = require(script:WaitForChild("MainModule"))
local EventHandler = Rep:WaitForChild("EventHandler")

-- Rep Variables
local RoundInfo = Rep:WaitForChild("RoundInfo")
local CurrentMap = RoundInfo:WaitForChild("CurrentMap")
local GameTime = RoundInfo:WaitForChild("GameTime")
local GameMode = RoundInfo:WaitForChild("Gamemode")
local GameMsg = RoundInfo:WaitForChild("GameMessage")
local IsInCamera = RoundInfo:WaitForChild("IsInCamera")
local GameSubMsg = GameMsg:WaitForChild("SubMessage")
local WinnerName = RoundInfo:WaitForChild("WinnerName")
local SetSpecificChar = Rep:WaitForChild("SetSpecificChar")

local ActivateUIAnim = RoundInfo:WaitForChild("ActivateUIAnim")
local ActivateUIMsg = ActivateUIAnim:WaitForChild("Message")

local ActivateWinnerAnim = RoundInfo:WaitForChild("ActivateWinnerAnim")
local ActivateWinnerMsg = ActivateWinnerAnim:WaitForChild("Message")
local ActivateWinnerSubMsg = ActivateWinnerAnim:WaitForChild("SubMessage")
local ShopModule = require(Rep:FindFirstChild("ShopModule"))
local Module3D = require(Rep:FindFirstChild("Module3D"))
local RbxGui = LoadLibrary("RbxGui")

-- Player Content
repeat wait() until Players.LocalPlayer
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local PlayerGui = Player:WaitForChild("PlayerGui")
local PlayerBP = PlayerGui:WaitForChild("Backpack")
local PlayerEvent = Player:WaitForChild("PlayerEvent")
local PlayerStatus = Player:WaitForChild("Status")
local PlayerInfo = Player:WaitForChild("PlayerInfo")
local BloxBux = PlayerInfo:WaitForChild("BloxBux")
local BoughtHats = PlayerInfo:WaitForChild("BoughtHats")
local PI_Character = PlayerInfo:WaitForChild("Character")
local PI_BodyColors = PI_Character:WaitForChild("BodyColors")
local PlayerScripts = Player:WaitForChild("PlayerScripts")
local CameraScript = PlayerScripts:WaitForChild("CameraScript")
local ShiftLockEnabled = CameraScript:WaitForChild("ShiftlockEnabled")

local Character = Player.Character or nil
local Humanoid = nil
if Character then 
	Humanoid = Character:WaitForChild("Humanoid") 
	Humanoid.HealthChanged:connect(function() 
		print("[Client] Current Health: "..Humanoid.Health) 
		UpdateHealthbar(Humanoid) 
	end)
end

-- Self Variables
local self = script.Parent
local ChatBox = self:WaitForChild("ChatBox")
local ChatList = self:WaitForChild("Chat")
local HealthBar = self:WaitForChild("Health")
local HBar = HealthBar:WaitForChild("Score")
local GoToGame = self:WaitForChild("GoToGame")
local InvInfo = self:WaitForChild("InvInfo")
local MenuFrames = {
	Inventory = self:WaitForChild("Inventory"),
	Settings = self:WaitForChild("Settings"),
	Shop = self:WaitForChild("Shop")
}

local AnimFrame1 = self:WaitForChild("AnimFrame1")
local AnimFrame2 = self:WaitForChild("AnimFrame2")
local MessageLabel = self:WaitForChild("MessageLabel")
local SubMessageLabel = MessageLabel:WaitForChild("SubMsgLabel")

-- Other Variables
local RbxAssetId = "rbxassetid://"
local ChatColors = {
	BrickColor.new("Bright red").Color,
	BrickColor.new("Bright blue").Color,
	BrickColor.new("Earth green").Color,
	BrickColor.new("Bright violet").Color,
	BrickColor.new("Bright orange").Color,
	BrickColor.new("Bright yellow").Color,
	BrickColor.new("Light reddish violet").Color,
	BrickColor.new("Brick yellow").Color,
}
local Admins = {
	["teambrickbattle"] = true,
	["fezezen"] = true,
	["cy1ia"] = true,
	["shloid"] = true,
	["tbouy"] = true,
	["shayne024"] = true,
	["semperfid_elis"] = true,
}
local Networking = {}
local PlayerNetworking = {}
local playersTable = {}
local teamsTable = {}

-- Fake Mouse Setup
local MIcons = {
	-- regular stuff
	["Regular"] = RbxAssetId..1075016657,
	["FarAway"] = RbxAssetId..1075016355,
	["Click"] = RbxAssetId..1078189583,
	
	-- tool stuff
	["Gun"]= "rbxasset://textures/GunCursor.png", -- convert to regular id
	["GunReload"] = "rbxasset://textures/GunWaitCursor.png", -- convert to regular id
	["Custom"] = true, -- this is in case for custom use
	["CustomIcon"] = "",
}
local MouseMode = "Regular"
local TabMode = "AllPlayers"
local selectedBodyPart = "None"
local SelectedShopItem = "None"
local ShopItemType = "None"
local IsMouseRegular = true
local IsAllowedToChat = true
local IsPlayingAnim = false
local SpectateDebounce = false
local canPlayUuh = false
local SpamFilter = 0
local CurrentVolume = 1
local CurrentVolume2 = 1
local PreviousCashValue = BloxBux.Value
local animTrack = nil
local userIconURL1 = "https://www.roblox.com/bust-thumbnail/image?userId="
local userIconURL2 = "&width=420&height=420&format=png"

local Cursor = Instance.new('ImageLabel', script.Parent)
Cursor.Name = "FakeCursor"
Cursor.BackgroundTransparency = 1
Cursor.Size = UDim2.new(0, 80, 0, 80)
Cursor.Image = RbxAssetId..1075016657
Cursor.ZIndex = 99

local ThisMessage = 'To chat click here or press "/" key'
local VolumeBar, vbPosition = RbxGui.CreateSliderNew(10,260,UDim2.new(0.5,0,0,50))
local VolumeBar2, vbPosition2 = RbxGui.CreateSliderNew(10,260,UDim2.new(0.5,0,0,100))
VolumeBar.Parent = MenuFrames.Settings
VolumeBar2.Parent = MenuFrames.Settings

-- Setting up the UI
UIS.MouseIconEnabled = false
StarterGui:SetCore("TopbarEnabled", false)

--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Functions / Methods
--------------------------------------------------------------------------------------------------------------------------------------------------------------

function ChangePlayerLabel(label,id)
	if label:IsA("ImageLabel") or label:IsA("ImageButton") and id then
		label.Image = userIconURL1..tostring(id)..userIconURL2
		label["PlayerName"].Text = Player.Name
		label["PlayerName"].Shadow.Text = Player.Name
	end	
end

ChangePlayerLabel(self.PlayerLabel,Player.UserId)

vbPosition.Changed:connect(function(v)
	CurrentVolume = v / 10
	if canPlayUuh then
		script.Sounds.Slider.Volume = CurrentVolume
		script.Sounds.Slider:Play()
	end
	if workspace.Sounds.Music.Volume > 0 then
		workspace.Sounds.Music.Volume = CurrentVolume
	end
end)

vbPosition2.Changed:connect(function(v)
	CurrentVolume2 = v / 10
	if canPlayUuh then
		script.Sounds.Slider.Volume = CurrentVolume
		script.Sounds.Slider:Play()
	end
	for i,v in pairs(script.Sounds:GetChildren()) do
		if v:IsA("Sound") then
			v.Volume = CurrentVolume2
		end
	end
end)

function HumAnimHandler()
	if IsPlayingAnim then
		if IsInCamera.Value == false then
			if animTrack then
				animTrack:Stop()
			end
			IsPlayingAnim = false
		end
	else
		if Humanoid and IsInCamera.Value == true then
			if WinnerName.Value == Player.Name then
				script.AnimHander.AnimationId = ""
			else
				script.AnimHander.AnimationId = "rbxassetid://1146483574"
			end
			pcall(function()
				animTrack = Humanoid:LoadAnimation(script.AnimHander)
				animTrack:Play()
			end)
			IsPlayingAnim = true
		end
	end
end

function DoColorChangerBtns(frame)
	if frame then
		for i,v in pairs(frame:GetChildren()) do
			if v:IsA("TextButton") then
				local vColorName = v:FindFirstChild("ColorName")
				v.MouseEnter:connect(function()
					script.Sounds.Hover:Play()
					v.BorderColor3 = Color3.new(0/255, 170/255, 255/255)
					v.BorderSizePixel = 3
				end)
				v.MouseLeave:connect(function()
					spawn(function()
						wait()
						v.BorderColor3 = Color3.new(166/255, 166/255, 166/255)
						v.BorderSizePixel = 1
					end)
				end)
				v.MouseButton1Click:connect(function()
					if vColorName then
						SetSpecificChar:FireServer("BodyColor",selectedBodyPart,vColorName.Value)
					end
					v.BorderColor3 = Color3.new(166/255, 166/255, 166/255)
					v.BorderSizePixel = 1
					selectedBodyPart = "None"
					frame.Visible = false
				end)
			end
		end
	end
end

function UpdateInvInfo(item,numb)
	if item and numb then
		print("[Client] Updating inventory info.")
		local itemName = item.Name
		local itemValue = BoughtHats:FindFirstChild(tostring(itemName))
		local itemDesc = ShopModule.Hats[tonumber(numb)]
		print("[Client] itemValue: "..tostring(itemValue))
		print("[Client] itemDesc: "..tostring(itemDesc))
		if itemValue and itemDesc then
			print("[Client] Values have passed!")
			InvInfo["ItemName"].Text = tostring(itemDesc.Name)
			if itemValue.Value == true then
				InvInfo["OwnsItem"].Text = "You own this hat!"
			else
				InvInfo["OwnsItem"].Text = "You do not own this item!"
			end
		end
	end
end

local SelectedInvPart = nil
local ThreeDmodel = nil

function SetupShopButton(btn)
	if btn then
		print("[Server] Setting up button functionality for: "..btn.Name)
		local btnHover = btn:FindFirstChild("HoverLabel")
		btn.MouseEnter:connect(function()
			script.Sounds.Hover:Play()
			if btnHover then
				btnHover.Visible = true
			end
		end)
		
		btn.MouseLeave:connect(function()
			spawn(function()
				wait()
				if btnHover then
					btnHover.Visible = false
				end
			end)
		end)
		
		btn.MouseButton1Click:connect(function()
			script.Sounds.Click:Play()
			btn.Shadow:TweenPosition(UDim2.new(0,0,0,0),"Out", "Quad",.01)
			btn:TweenPosition(UDim2.new(tonumber(btn.Position.X.Scale),tonumber(btn.Position.X.Offset) + 1,tonumber(btn.Position.Y.Scale),tonumber(btn.Position.Y.Offset) + 1),"Out", "Quad",.01)
			wait(.01)
			btn.Shadow:TweenPosition(UDim2.new(0,1,0,1),"Out", "Quad",.01)
			btn:TweenPosition(UDim2.new(tonumber(btn.Position.X.Scale),tonumber(btn.Position.X.Offset) - 1,tonumber(btn.Position.Y.Scale),tonumber(btn.Position.Y.Offset) - 1),"Out", "Quad",.01)
			if btn.Name == "Hat" then
				MenuFrames.Shop.HatFrame.Visible = true
			elseif btn.Parent.Name == "Container" then
				if btn.Parent.Parent.name == "HatFrame" then
					local btnInfo = nil
					for i,v in pairs(ShopModule.Hats) do
						if v.HatName == btn.Name then
							btnInfo = v
						end
					end
					if btnInfo ~= nil then
						MenuFrames.Shop.Info.BuyButton.Visible = true
						MenuFrames.Shop.Info.PriceLabel.Visible = true
						MenuFrames.Shop.Info.PriceLabel.PriceText.Text = tostring(btnInfo.Cost)
						MenuFrames.Shop.Info.PriceLabel.PriceText.Shadow.Text = tostring(btnInfo.Cost)
						MenuFrames.Shop.Info.ItemDesc.Text = btnInfo.Desc
						MenuFrames.Shop.Info.ItemName.Text = btnInfo.Name
						SelectedShopItem = btn.Name
						ShopItemType = "Hat"
						if btn:IsA("ImageButton") then
							MenuFrames.Shop.Info.ItemIcon.Image = btn.Image
						end
						--[[local itmInHats = Rep.Hats:FindFirstChild(btn.Name)
						if itmInHats and itmInHats:FindFirstChild("Handle") then
							local itmHat = itmInHats:FindFirstChild("Handle")
							if ThreeDmodel ~= nil then
								ThreeDmodel:SetActive(false)
								ThreeDmodel = nil
							end
							ThreeDmodel = Module3D:Attach3D(MenuFrames.Shop.Info["3DFrame"],itmHat)
							ThreeDmodel:SetActive(true)
						end]]
					end
				end
			elseif btn.Name == "BuyButton" then
				local modStuff = nil
				local itmValue = BoughtHats:FindFirstChild(SelectedShopItem)
				if ShopItemType == "Hat" then
					for i,v in pairs(ShopModule.Hats) do
						if v.HatName == SelectedShopItem then
							modStuff = v
						end
					end
				end
				if itmValue and modStuff then
					print("[Server] Found Value for Item: "..SelectedShopItem)
					if itmValue.Value == true then
						print("[Server] Item has already been purchased.")
						btn.Text = "Already Purchased."
					else
						print("[Server] Item has not been purchased yet!")
						btn.Text = "Buy Item"
					end
					if BloxBux.Value >= modStuff.Cost and btn.Text == "Buy Item" then
						print("[Server] Buying item.")
						if ShopItemType == "Hat" then
							Rep.BuyItemEvent:FireServer("BoughtHats",SelectedShopItem,modStuff.Cost)
						end
						spawn(function()
							btn.Text = "Bought item!"
							wait(1.5)
							btn.Text = "Already Purchased."
						end)
					end
				end
			elseif btn.Name == "ExitButton" then
				MenuFrames.Shop.Visible = false
			end
		end)
	end	
end

function SetupShopFrame(frame)
	if frame then
		for i,v in pairs(frame:GetChildren()) do
			if v:IsA("Frame") then
				SetupShopFrame(v)
			elseif v:IsA("TextButton") or v:IsA("ImageButton") then
				SetupShopButton(v)
			end
		end
	end
end

SetupShopFrame(MenuFrames.Shop)
SetupShopFrame(MenuFrames.Shop.HatFrame.Container)

function SetupInvButton(btn)
	if btn then
		print("[Client] Updating button: "..tostring(btn.Name))
		local btnNumb = btn:FindFirstChild("ModuleNumb")
		local btnHover = btn:FindFirstChild("HoverLabel")
		btn.MouseEnter:connect(function()
			script.Sounds.Hover:Play()
			if btnHover then
				btnHover.Visible = true
			end
			if btn.Parent.Name == "Container" then
				if btnNumb then
					UpdateInvInfo(btn,btnNumb.Value)
					InvInfo.Visible = true
				end
			end
		end)
		btn.MouseLeave:connect(function()
			spawn(function()
				InvInfo.Visible = false
				wait()
				if btnHover then
					btnHover.Visible = false
				end
			end)
		end)
		btn.MouseButton1Click:connect(function()
			script.Sounds.Click:Play()
			btn.Shadow:TweenPosition(UDim2.new(0,0,0,0),"Out", "Quad",.01)
			btn:TweenPosition(UDim2.new(0,tonumber(btn.Position.X.Offset) + 1,tonumber(btn.Position.Y.Scale),tonumber(btn.Position.Y.Offset) + 1),"Out", "Quad",.01)
			wait(.01)
			btn.Shadow:TweenPosition(UDim2.new(0,1,0,1),"Out", "Quad",.01)
			btn:TweenPosition(UDim2.new(0,tonumber(btn.Position.X.Offset) - 1,tonumber(btn.Position.Y.Scale),tonumber(btn.Position.Y.Offset) - 1),"Out", "Quad",.01)
			if btn.Name == "Hat" then
				MenuFrames.Inventory.TShirtFrame.Visible = false
				MenuFrames.Inventory.HatFrame.Visible = true
			elseif btn.Name == "TShirt" then
				MenuFrames.Inventory.TShirtFrame.Visible = true
				MenuFrames.Inventory.HatFrame.Visible = false 
			end
			if btnNumb then
				-- switch hat
				SetSpecificChar:FireServer("Hat",btn.Name)
				MenuFrames.Inventory.HatFrame.Visible = false
				self.InvInfo.Visible = false
			end
		end)
	end
end

function SetupInventoryFrame(frame)
	if frame then
		for i,v in pairs(frame:GetChildren()) do
			if v:IsA("Frame") then
				SetupInventoryFrame(v)
			elseif v:IsA("ImageButton") then
				SetupInvButton(v)
			elseif v:IsA("TextButton") then
				local bcValue = PI_BodyColors:FindFirstChild(v.Name)
				local bcHL = v:FindFirstChild("HoverLabel")
				if bcValue then
					v.BackgroundColor3 = BrickColor.new(tostring(bcValue.Value)).Color
					bcValue.Changed:connect(function(v2)
						v.BackgroundColor3 = BrickColor.new(tostring(v2)).Color
					end)
				end
				if v.Name:lower() == "setdefault" and v.Parent.Name:lower() == "container" then
					v.Parent = v.Parent.Parent
					v.Position = UDim2.new(1, 10, 0, 0)
				end
				v.MouseEnter:connect(function()
					script.Sounds.Hover:Play()
					if bcHL then
						bcHL.Visible = true
					end
				end)
				v.MouseLeave:connect(function()
					spawn(function()
						wait()
						if bcHL then
							bcHL.Visible = false
						end
					end)
				end)
				v.MouseButton1Click:connect(function(v2)
					if frame.Name == "Char" then
						selectedBodyPart = v.Name
						self.ColorChanger.Position = UDim2.new(0, Mouse.X + 40, 0, Mouse.Y + 40)
						self.ColorChanger.Visible = true
					elseif frame.Name == "TShirtFrame" then
						-- change the player's tshirt
						if v.Name == "Confirm" and v.Parent:FindFirstChild("Confirm") then
							SetSpecificChar:FireServer("TShirt", v.Parent.IdBox.Text)
						elseif v.Name == "SetDefault" then
							--{1, 10},{0, 0}
							SetSpecificChar:FireServer("TShirt","Default")
						end
						frame.Visible = false
					elseif frame.Parent.Name == "HatFrame" then
						if v.Name == "SetDefault" then
							SetSpecificChar:FireServer("Hat","None")
							self.InvInfo.Visible = false
						end
					elseif v.Name == "ExitButton" then
						frame.Visible = false
						self.ColorChanger.Visible = false
						selectedBodyPart = "None"
						self.InvInfo.Visible = false
					end
				end)
			end
		end
	end
end

SetupInventoryFrame(MenuFrames.Inventory)
SetupInventoryFrame(MenuFrames.Inventory.HatFrame.Container)
SetupInventoryFrame(MenuFrames.Inventory.TShirtFrame)

function PlayFrameAnim(type,seconds)
	local Types = {
		["Start"] = true,
		["End"] = true,
	}
	if type and Types[type] then
		local TransTime = .8
		script.Sounds.Swoosh2:Play() 
		if type == "Start" then
			for i,v in pairs(AnimFrame1:GetChildren()) do
				v.Visible = true
			end
			AnimFrame1.TopFrame:TweenPosition(UDim2.new(0,0,0,-35),"Out", "Quad", TransTime)
			AnimFrame1.BottomFrame:TweenPosition(UDim2.new(0,0,0.5,-33),"Out", "Quad", TransTime)
			
			AnimFrame1.LeftFrame:TweenPosition(UDim2.new(0,0,0.5,-50),"Out", "Quad", TransTime)
			AnimFrame1.RightFrame:TweenPosition(UDim2.new(.5,0,.5,-50),"Out", "Quad", TransTime)
			
			AnimFrame1.LogoLabel:TweenPosition(UDim2.new(0.5,-195,0.5,-195),"Out", "Quad", TransTime)
			AnimFrame1.InfoText:TweenPosition(UDim2.new(0,0,0.5,150),"Out", "Quad", TransTime)
			wait(TransTime)
		elseif type == "End" then
			AnimFrame1.TopFrame:TweenPosition(UDim2.new(0,0,-1,-35),"Out", "Quad", TransTime)
			AnimFrame1.BottomFrame:TweenPosition(UDim2.new(0,0,1,35),"Out", "Quad", TransTime)
			
			AnimFrame1.LeftFrame:TweenPosition(UDim2.new(-0.6,0,0.5,-50),"Out", "Quad", TransTime)
			AnimFrame1.RightFrame:TweenPosition(UDim2.new(1.1,0,0.5,-50),"Out", "Quad", TransTime)
			
			AnimFrame1.LogoLabel:TweenPosition(UDim2.new(0.5,-195,0,-390),"Out", "Quad", TransTime)
			AnimFrame1.InfoText:TweenPosition(UDim2.new(0,0,1,50),"Out", "Quad", TransTime)
			wait(TransTime + .3)
			for i,v in pairs(AnimFrame1:GetChildren()) do
				v.Visible = false
			end
		end
		AnimFrame1.InfoText.Text = ActivateUIMsg.Value
		AnimFrame1.InfoText.Shadow.Text = ActivateUIMsg.Value
	end
end

if script.Parent.AbsoluteSize.X < 1280 then
	AnimFrame2.Label.Position = UDim2.new(0,-280,0,-150)
else
	AnimFrame2.Label.Position = UDim2.new(0,-460,0,-135)	
end

function PlayFrame2Anim(type,seconds)
	local Types = {
		["Start"] = true,
		["End"] = true,
	}
	if type and Types[type] then
		--[[ 
			start pos:
			label: {0, -150},{0, -50}
			winnerlabel: {0.5, 300},{1, -80}
			end pos: 
			label: {0, -280},{0, -5}
			WinnerLabel: {0.5, -5},{1, -80}
		]]--
		local TransTime = seconds
		if seconds == nil then TransTime = .8 end
		script.Sounds.Swoosh2:Play() 
		if type == "Start" then
			for i,v in pairs(AnimFrame2:GetChildren()) do
				v.Visible = true
			end
			if script.Parent.AbsoluteSize.X < 1000 then
				AnimFrame2.Label:TweenPosition(UDim2.new(0,-280,0,-5),"Out", "Quad", TransTime)
			else
				AnimFrame2.Label:TweenPosition(UDim2.new(0,-460,0,25),"Out", "Quad", TransTime)
			end
			
			wait(TransTime + .5)
			AnimFrame2.WinnerLabel:TweenPosition(UDim2.new(0.5,-5,1,-95),"Out", "Quad", TransTime)
			wait(TransTime)
		elseif type == "End" then			
			if script.Parent.AbsoluteSize.X < 1000 then
				AnimFrame2.Label:TweenPosition(UDim2.new(0,-280,0,-150),"Out", "Quad", TransTime)
			else
				AnimFrame2.Label:TweenPosition(UDim2.new(0,-460,0,-135),"Out", "Quad", TransTime)
			end
			AnimFrame2.WinnerLabel:TweenPosition(UDim2.new(0.5,500,1,-95),"Out", "Quad", TransTime)
			wait(TransTime + .3)
			for i,v in pairs(AnimFrame2:GetChildren()) do
				v.Visible = false
			end
		end
	end
end

function ChangeCursorState(type,ico)
	if type and MIcons[type] then
		if type == "Custom" and ico then
			Cursor.Image = MIcons["CustomIcon"]
		else
			Cursor.Image = MIcons[type]
		end
	end
end

function ChangeCursorMode(type,ico)
	if type and MIcons[type] then
		if ico then
			MIcons["CustomIcon"] = RbxAssetId..ico
		end
		MouseMode = type
		ChangeCursorState(type)
	end
end

function UpdateHealthbar(hum)
	if hum and hum:IsA("Humanoid") then
		local hp = hum.Health / hum.MaxHealth
		if hum.Health >= math.huge then
			HBar.Size = UDim2.new(1,0,1,0)
		else
			HBar.Size = UDim2.new(1,0,-hp,0)
		end
		if hum.Health >= math.huge then
			HBar.BackgroundColor3 = Color3.new(31/255, 195/255, 197/255)
		else
			if hum.MaxHealth > 100 then
				HBar.BackgroundColor3 = Color3.new(31/255, 195/255, 197/255)
			else
				HBar.BackgroundColor3 = Color3.new(129/255, 197/255, 22/255)
			end
		end
	end
end

function UpdateList()
	local chats = ChatList:GetChildren()
	for i = 1, #chats do
		chats[i].Position = UDim2.new(0, 0, 0, (i * 14) - 14)
	end
end

function UpdateFeedList()
	local chats = self.KillFeed:GetChildren()
	for i = 1, #chats do
		chats[i].Position = UDim2.new(0, 0, 0, (i * 40) - 40)
	end
end

function SendChatMessage(message)
	if message then
		EventHandler:FireServer("SendChatMessage",Player.Name,message)
	end
end

local CurrentAnim = nil
local PlayingAnim = false

function ChangeAnim(id)
	local NonLoopIds = {
		[1173876659] = true,
		[1173930484] = true,
	}
	if CurrentAnim ~= nil then
		CurrentAnim:Stop()
		PlayingAnim = false
	end
	if id then
		script.AnimHander.AnimationId = RbxAssetId..tostring(id)
		CurrentAnim = Humanoid:LoadAnimation(script.AnimHander)
		if NonLoopIds[id] == true then
			CurrentAnim.Looped = false
		else			
			CurrentAnim.Looped = true
		end
		CurrentAnim:Play()
		PlayingAnim = true
	end
end

function OnFocusLost(enterPressed)
	if enterPressed then
		--if ChatBox.Text == "/god" and Admins[Player.Name:lower()] and Humanoid.MaxHealth ~= math.huge then
		--	Humanoid.MaxHealth = math.huge
		--	Networking.Functions["GenerateSpecMessage"]("Client","God mode has been enabled.")
		--else
			if string.sub(ChatBox.Text,1,1) == "/" then
				if string.find(ChatBox.Text,"emote") or string.find(ChatBox.Text,"e") then
					print("[Client] Text contained: 'emote' (or 'e').")
					if string.find(ChatBox.Text,"dance") then
						if GameMode.Value == "SelectingWinner" and tostring(RoundInfo.WinnerName.Value) ~= Player.Name then
							Networking.Functions["GenerateSpecMessage"]("Client","You can't dance at this time! That would be rude for the winner.")
						else
							ChangeAnim(161099825)
							Networking.Functions["GenerateSpecMessage"]("Client","Playing dancing emote.")
						end
					elseif string.find(ChatBox.Text,"clap") then
						ChangeAnim(1146483574)
						Networking.Functions["GenerateSpecMessage"]("Client","Playing clap emote.")
					elseif string.find(ChatBox.Text,"doit") then
						ChangeAnim(1173882177)
						Networking.Functions["GenerateSpecMessage"]("Client","Playing doit emote.")
					elseif string.find(ChatBox.Text,"dab") then
						ChangeAnim(1173876659)
						Networking.Functions["GenerateSpecMessage"]("Client","Playing dab emote.")
					elseif string.find(ChatBox.Text,"wryyy") then
						ChangeAnim(1173930484)
						Networking.Functions["GenerateSpecMessage"]("Client","Playing wryyy emote.")
					else
						Networking.Functions["GenerateSpecMessage"]("Client","Error: unknown command. Type '/h' to get some help.")
					end	
				else
					if string.find(ChatBox.Text,"h") then
						print("[Client] Text contained: 'help'")
						Networking.Functions["GenerateSpecMessage"]("Client","Basic Commands: help, emote, e.")
						Networking.Functions["GenerateSpecMessage"]("Client","Emotes: dance, clap, doit, wryyy, dab.")
					else
						Networking.Functions["GenerateSpecMessage"]("Client","Error: unknown command. Type '/h' to get some help.")
					end
				end
			else
				if IsAllowedToChat then
					SpamFilter = SpamFilter + 1
					SendChatMessage(ChatBox.Text)
				else
					Networking.Functions["GenerateSpecMessage"]("Client","You have been spamming too many times. Please wait til the cooldown ("..SpamFilter.." second cooldown) is done.")
				end
			end
		--end
	end
	ChatBox.Text = 'To chat click here or press "/" key'
end

function GetNameValue(name)
	local value = 0
	for index = 1, #name do 
		local cValue = string.byte(string.sub(name, index, index))
		local reverseIndex = #name - index + 1
		if #name % 2 == 1 then 
			reverseIndex = reverseIndex - 1			
		end
		if reverseIndex % 4 >= 2 then 
			cValue = -cValue 			
		end 
		value = value + cValue 
	end 
	return value % 8
end

function UpdateBackpackUI()
	if PlayerStatus.Value == "InGame" then
		PlayerBP.Enabled = true
	else
		PlayerBP.Enabled = false
		EventHandler:FireServer("MoveToolToBackpack",Character)
	end
end

function ChangeMessage()
	MessageLabel.Text = GameMsg.Value
	MessageLabel:FindFirstChild("Shadow").Text = GameMsg.Value
	
	SubMessageLabel.Text = GameSubMsg.Value
	SubMessageLabel:FindFirstChild("Shadow").Text = GameSubMsg.Value
end

function ChangeCamera()
	HumAnimHandler()
	if IsInCamera.Value == true then
		workspace.CurrentCamera.CameraSubject = workspace.WinnerRoom.CameraRootPart
		workspace.CurrentCamera.CFrame = workspace.WinnerRoom.CameraRootPart.CFrame
	else
		if Humanoid then
			workspace.CurrentCamera.CameraSubject = Humanoid
		end
	end
end

function GiveButtonLife(btn,endwaittime)
	if btn and btn:IsA("ImageButton") then
		btn.MouseEnter:connect(function()
			btn.HoverLabel.Visible = true
			script.Sounds.Hover:Play()
		end)
		btn.MouseLeave:connect(function()
			spawn(function()
				wait()
				btn.HoverLabel.Visible = false
			end)
		end)
		btn.MouseButton1Click:connect(function()
			script.Sounds.Click:Play()
			btn.Shadow:TweenPosition(UDim2.new(0,0,0,0),"Out", "Quad",.01)
			btn:TweenPosition(UDim2.new(0,tonumber(btn.Position.X.Offset) + 1,tonumber(btn.Position.Y.Scale),tonumber(btn.Position.Y.Offset) + 1),"Out", "Quad",.01)
			wait(.01)
			btn.Shadow:TweenPosition(UDim2.new(0,1,0,1),"Out", "Quad",.01)
			btn:TweenPosition(UDim2.new(0,tonumber(btn.Position.X.Offset) - 1,tonumber(btn.Position.Y.Scale),tonumber(btn.Position.Y.Offset) - 1),"Out", "Quad",.01)
		end)
		
		if btn.Name == "5Mute" or btn.Name == "4Settings" then
			-- do nothing
		else
			local activateBtnAnim = Instance.new("BoolValue",btn)
			activateBtnAnim.Name = "ActivateAnimation"
			activateBtnAnim.Value = false
			activateBtnAnim.Changed:connect(function(v)
				wait(.2)
				if v == true then
					btn:TweenPosition(UDim2.new(0,8,tonumber(btn.Position.Y.Scale),tonumber(btn.Position.Y.Offset)),"Out", "Quad",endwaittime)
					wait(endwaittime + .04)
					btn:TweenPosition(UDim2.new(0,-45,tonumber(btn.Position.Y.Scale),tonumber(btn.Position.Y.Offset)),"Out", "Quad",endwaittime)
					spawn(function()
						wait(endwaittime + .02)
						btn.Visible = false
					end)
				elseif v == false then
					btn.Visible = true
					btn:TweenPosition(UDim2.new(0,8,tonumber(btn.Position.Y.Scale),tonumber(btn.Position.Y.Offset)),"Out", "Quad",endwaittime)
					wait(endwaittime + .04)
					btn:TweenPosition(UDim2.new(0,5,tonumber(btn.Position.Y.Scale),tonumber(btn.Position.Y.Offset)),"Out", "Quad",endwaittime)
				end
			end)
		end
	end
end

local PlayerList = self:WaitForChild("PlayerList")

function UpdatePlayerlist()
	local FPlayers = Players:GetPlayers()
	local FTeams = Teams:GetChildren()
	playersTable = {}
	teamsTable = {}
	table.insert(playersTable, #playersTable, Player)
	
	for i,v in pairs(PlayerList:GetChildren()) do
		if not string.find(v.Name,"_Label") then
			v:Destroy()
		end
	end
	
	for i = 1,#FPlayers do
		if FPlayers[i]:IsA("Player") then
			table.insert(playersTable, #playersTable + 1, FPlayers[i])
		end
	end
	
	for i = 1,#FTeams do
		if FTeams[i]:IsA("Team") then
			table.insert(teamsTable, #teamsTable + 1, FTeams[i])
		end
	end
	
	--[[if #teamsTable > 0 then --Player Names
		PlayerList:WaitForChild("_Label1").Text = "Team"
		local teamspace = 0
		for i2=1,#teamsTable do
			local labelt = script.Team:Clone()
			labelt:WaitForChild("_Label2").Text = teamsTable[i2].Name
			labelt:WaitForChild("_Label2").TextColor3 = teamsTable[i2].TeamColor.Color
			labelt:WaitForChild("_Label3").BackgroundColor3 = teamsTable[i2].TeamColor.Color
			local vplayers = {}
			for i=1,#playersTable do
				if not playersTable[i].Neutral and playersTable[i].TeamColor == playersTable[i2].TeamColor then
					table.insert(vplayers,#vplayers+1,playersTable[i])
				end
			end
			for i=1,#vplayers do
				local label = script:WaitForChild("Player"):Clone()
				label.Text = vplayers[i].Name
				label.Position = UDim2.new(0,0,0,30+(20*(i-1)))
				label.Parent = labelt
				label.TextColor3 = vplayers[i].TeamColor.Color
			end
			labelt.Position = UDim2.new(0,5,0,20+teamspace)
			labelt.Size = UDim2.new(1,0,0,40+(20*#vplayers))
			teamspace = teamspace + labelt.Size.Y.Offset
			labelt.Parent = PlayerList
		end
		PlayerList.Size = UDim2.new(0,168,0,40+teamspace)
	else]]
	if TabMode == "AllPlayers" then
		for i = 1, #playersTable do
			local label = script:WaitForChild("Player"):Clone()
			label.Text = FPlayers[i].Name
			label.Position = UDim2.new(0,5,0,40 + (20 * (i-1))) -- original: (20 + (i-1)
			label.Parent = PlayerList
			if Admins[FPlayers[i].Name:lower()] then
				spawn(function()
					while label do
						local r = (math.sin(workspace.DistributedGameTime/2)/2)+0.5
						local g = (math.sin(workspace.DistributedGameTime)/2)+0.5
						local b = (math.sin(workspace.DistributedGameTime*1.5)/2)+0.5
						local color = Color3.new(r, g, b)
						if label then
							label.TextColor3 = color
						end
						Run.Heartbeat:wait()
					end
				end)
			else
				label.TextColor3 = ChatColors[GetNameValue(FPlayers[i].Name) + 1]
			end
			local pStatus = FPlayers[i]:FindFirstChild("leaderstats")
			if pStatus then
				print("[Client] Found "..tostring(FPlayers[i].Name).."'s Stats.")
				--[[pStatus.Kills.Changed:connect(function(v)
					if label and label:FindFirstChild("KillScore") then
						label:FindFirstChild("KillScore").Text = tostring(v)
					end
				end)
				pStatus.Wipeouts.Changed:connect(function(v)
					if label and label:FindFirstChild("WipeoutScore") then
						label:FindFirstChild("WipeoutScore").Text = tostring(v)
					end
				end)]]
				if label and label:FindFirstChild("KillScore") then
					label:FindFirstChild("KillScore").Text = tostring(pStatus.Kills.Value)
				end
				if label and label:FindFirstChild("WipeoutScore") then
					label:FindFirstChild("WipeoutScore").Text = tostring(pStatus.Wipeouts.Value)
				end
				spawn(function()
					while label do
						if label and label:FindFirstChild("KillScore") and label:FindFirstChild("WipeoutScore") then
							label:FindFirstChild("KillScore").Text = tostring(pStatus.Kills.Value)
							label:FindFirstChild("WipeoutScore").Text = tostring(pStatus.Wipeouts.Value)
						end
						Run.Heartbeat:wait()
					end
				end)
			end
		end
		PlayerList.Size = UDim2.new(0, 278, 0, 45 + (20 * #playersTable))
	else
		local label = script:WaitForChild("Player"):Clone()
		label.Text = Player.Name
		label.Position = UDim2.new(0,5,0,40 + (20 * (1-1))) -- original: (20 + (i-1)
		label.Parent = PlayerList
		if Admins[Player.Name:lower()] then
			spawn(function()
				while label do
					local r = (math.sin(workspace.DistributedGameTime/2)/2)+0.5
					local g = (math.sin(workspace.DistributedGameTime)/2)+0.5
					local b = (math.sin(workspace.DistributedGameTime*1.5)/2)+0.5
					local color = Color3.new(r, g, b)
					if label then
						label.TextColor3 = color
					end
					Run.Heartbeat:wait()
				end
			end)
		else
			label.TextColor3 = ChatColors[GetNameValue(Player.Name) + 1]
		end
		
		local pStatus = Player:FindFirstChild("leaderstats")
		if pStatus then
			print("[Client] Found "..tostring(Player.Name).."'s Stats.")
			pStatus.Kills.Changed:connect(function(v)
				wait()
				if label and label:FindFirstChild("KillScore") then
					label:FindFirstChild("KillScore").Text = tostring(v)
				end
			end)
			pStatus.Wipeouts.Changed:connect(function(v)
				wait()
				if label and label:FindFirstChild("WipeoutScore") then
					label:FindFirstChild("WipeoutScore").Text = tostring(v)
				end
			end)
			if label and label:FindFirstChild("KillScore") then
				label:FindFirstChild("KillScore").Text = tostring(pStatus.Kills.Value)
			end
			if label and label:FindFirstChild("WipeoutScore") then
				label:FindFirstChild("WipeoutScore").Text = tostring(pStatus.Wipeouts.Value)
			end
		end
		--{0, 278},{0, 65}
		PlayerList.Size = UDim2.new(0, 278, 0, 65)
	end
	--end
end

PlayerList.Position = UDim2.new(1, -288, 0, -25) -- {1, -288},{0, -25}

function ChangeTabMode()
	if TabMode == "AllPlayers" then
		TabMode = "OnePlayer"
		PlayerList:WaitForChild("_Label").Text = "↓"
	else
		TabMode = "AllPlayers"
		PlayerList:WaitForChild("_Label").Text = "↑"
	end
	UpdatePlayerlist()
end

local ButtonTableOfEpic = {
	[1] = "1Shop",
	[2] = "2Inventory",
	[3] = "3Spectate",
	[4] = "4Settings",
	[5] = "5Mute",
}

--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Networking Functions / Methods
--------------------------------------------------------------------------------------------------------------------------------------------------------------

Networking.Functions = {
	ChatMessage = function(pname,message)
		if pname and message and Players:FindFirstChild(pname) then
			local msgPlayer = Players:FindFirstChild(pname)
			local newMsg = script.Message:Clone()
			newMsg.Message.Text = " "..message
			newMsg:WaitForChild("Username").Text = pname .. ":"
			newMsg.Parent = ChatList
			
			if Admins[pname:lower()] then
				spawn(function()
					while newMsg do
						local r = (math.sin(workspace.DistributedGameTime/2)/2)+0.5
						local g = (math.sin(workspace.DistributedGameTime)/2)+0.5
						local b = (math.sin(workspace.DistributedGameTime*1.5)/2)+0.5
						local color = Color3.new(r, g, b)
						if newMsg and newMsg:FindFirstChild("Username") then
							newMsg.Username.TextColor3 = color
						end
						Run.Heartbeat:wait()
					end
				end)
			end
			local wid1 = newMsg.Message.TextBounds.X
			local wid2 = newMsg.Username.TextBounds.X
			local wid3 = wid1 + wid2
			
			print(wid1..", "..wid2..", "..wid3)
			
			newMsg:WaitForChild("Username").Size = UDim2.new(0,wid2,0,14)
			newMsg.Message.Size = UDim2.new(0,wid1,0,14)
			newMsg.Message.Position = UDim2.new(0,wid2,0,0)
			newMsg.Size = UDim2.new(0,wid3,0,16)
			
			if msgPlayer.Neutral then
				newMsg:WaitForChild("Username").TextColor3 = ChatColors[GetNameValue(pname) + 1]
			else
				newMsg:WaitForChild("Username").TextColor3 = msgPlayer.TeamColor.Color
			end
			
			local chats = ChatList:GetChildren()
			if #chats == 10 or #chats > 10 then
				chats[1]:Destroy()
			end
			spawn(function()
				wait(20)
				newMsg:Destroy()
			end)
		end
	end,
	
	UpdateKillFeed = function(killer,victim,img)
		if killer and victim then
			print("[Client] Finding killer and victim.")
			local mKiller = Players:FindFirstChild(killer)
			local mVictim = Players:FindFirstChild(victim)
			if mKiller and mVictim then
				print("[Client] Placing new feed.")
				local newFeed = script.Feed:Clone()
				newFeed:FindFirstChild("Killer").Text = mKiller.Name
				newFeed:FindFirstChild("Victim").Text = mVictim.Name
				if img == nil then
					newFeed:FindFirstChild("Weapon").Image = RbxAssetId..1160790275
				else
					newFeed:FindFirstChild("Weapon").Image = RbxAssetId..img
				end
				newFeed:FindFirstChild("Weapon"):FindFirstChild("Shadow").Image = newFeed:FindFirstChild("Weapon").Image
				
				if Admins[killer:lower()] then
					spawn(function()
						while newFeed do
							local r = (math.sin(workspace.DistributedGameTime/2)/2)+0.5
							local g = (math.sin(workspace.DistributedGameTime)/2)+0.5
							local b = (math.sin(workspace.DistributedGameTime*1.5)/2)+0.5
							local color = Color3.new(r, g, b)
							if newFeed and newFeed:FindFirstChild("Killer") then
								newFeed:FindFirstChild("Killer").TextColor3 = color
							end
							Run.Heartbeat:wait()
						end
					end)
				end
				
				if Admins[victim:lower()] then
					spawn(function()
						while newFeed do
							local r = (math.sin(workspace.DistributedGameTime/2)/2)+0.5
							local g = (math.sin(workspace.DistributedGameTime)/2)+0.5
							local b = (math.sin(workspace.DistributedGameTime*1.5)/2)+0.5
							local color = Color3.new(r, g, b)
							if newFeed and newFeed:FindFirstChild("Victim") then
								newFeed:FindFirstChild("Victim").TextColor3 = color
							end
							Run.Heartbeat:wait()
						end
					end)
				end
				
				local chats = self.KillFeed:GetChildren()
				if #chats == 4 or #chats > 4 then
					chats[1]:Destroy()
				end
				
				newFeed.Parent = self.KillFeed
				print("[Client] Everything is finished.")
				spawn(function()
					wait(25)
					newFeed:Destroy()
				end)
			end
		end
	end,	
	
	GenerateSpecMessage = function(name,message)
		local types = {
			["Server"] = true,
			["Client"] = true,
		}
		if name and message and types[name] then
			print("[Client] Firing up specific message.")
			local newMsg = script.Message:Clone()
			newMsg.Message.Text = " "..message
			newMsg:WaitForChild("Username").Text = name .. ":"
			newMsg.Parent = ChatList
			
			local wid1 = newMsg.Message.TextBounds.X
			local wid2 = newMsg.Username.TextBounds.X
			local wid3 = wid1 + wid2
			
			newMsg.Username.Size = UDim2.new(0,wid2,0,14)
			newMsg.Message.Size = UDim2.new(0,wid1,0,14)
			newMsg.Message.Position = UDim2.new(0,wid2,0,0)
			newMsg.Size = UDim2.new(0,wid3,0,16)
			
			if name == "Server" then
				newMsg.Username.TextColor3 = BrickColor.new("Bright yellow").Color
			elseif name == "Client" then
				newMsg.Username.TextColor3 = BrickColor.new("Bright bluish green").Color
			end
			
			local chats = ChatList:GetChildren()
			if #chats == 10 or #chats > 10 then
				chats[1]:Destroy()
			end
			spawn(function()
				wait(20)
				newMsg:Destroy()
			end)
		end
	end
}

PlayerNetworking.Functions = {
	UpdateMouseStatus = function(type,ico)
		if type then
			if type == "Regular" then
				IsMouseRegular = true
			else
				IsMouseRegular = false
			end
			if ico then
				ChangeCursorMode(type,ico)
			else
				ChangeCursorMode(type)
			end
		end
	end,
}

EventHandler.OnClientEvent:connect(function(fname,...)
	if fname then
		Networking.Functions[fname](...)
	end	
end)

PlayerEvent.OnClientEvent:connect(function(fname,...)
	if fname then
		PlayerNetworking.Functions[fname](...)
	end	
end)

--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Setting up Client
--------------------------------------------------------------------------------------------------------------------------------------------------------------

local timeLimit = .2
vbPosition.Value = 5
vbPosition2.Value = 3
canPlayUuh = true

for i = 1, 5 do
	local thisBtn = self:FindFirstChild(ButtonTableOfEpic[i])
	if thisBtn then
		GiveButtonLife(thisBtn,timeLimit)
		timeLimit = timeLimit + .04
	end
end

ChatList.ChildAdded:connect(UpdateList)
ChatList.ChildRemoved:connect(UpdateList)
self.KillFeed.ChildAdded:connect(UpdateFeedList)
self.KillFeed.ChildRemoved:connect(UpdateFeedList)
DoColorChangerBtns(self.ColorChanger)
ChatBox.FocusLost:connect(OnFocusLost)
PlayerList:WaitForChild("_Label").MouseButton1Click:connect(ChangeTabMode)

Mouse.Move:connect(function()
	Cursor.Position = UDim2.new(0, Mouse.X - 40, 0, Mouse.Y - 40)
	InvInfo.Position = UDim2.new(0, Mouse.X + 40, 0, Mouse.Y + 40)
	if IsMouseRegular then
		if Mouse.Target and Mouse.Target:IsA("BasePart") then
			if Mouse.Target.Transparency >= 1 then
				-- do nothing
			else
				ChangeCursorState("Regular")
			end
		else
			ChangeCursorState("FarAway")
		end
	end
end)

Humanoid.Running:connect(function()
	if PlayingAnim then
		CurrentAnim:Stop()
		PlayingAnim = false
	end
end)

Player.CharacterAdded:connect(function(char)
	Character = char
	Humanoid = Character:WaitForChild("Humanoid") 
	Humanoid.HealthChanged:connect(function() 
		print("[Client] Current Health: "..Humanoid.Health) 
		UpdateHealthbar(Humanoid) 
	end)
	Humanoid.Running:connect(function()
		if PlayingAnim then
			CurrentAnim:Stop()
			PlayingAnim = false
		end
	end)
	PlayerBP = PlayerGui:WaitForChild("Backpack")
	UpdateBackpackUI()
	UpdateHealthbar(Humanoid)
end)

GameMsg.Changed:connect(ChangeMessage)
GameSubMsg.Changed:connect(ChangeMessage)
PlayerStatus.Changed:connect(UpdateBackpackUI)
Players.PlayerAdded:connect(UpdatePlayerlist)
Players.PlayerRemoving:connect(UpdatePlayerlist)

UIS.InputBegan:connect(function(input)
	if input then
		if not ChatBox:IsFocused() then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				if input.KeyCode == Enum.KeyCode.Slash then
					ChatBox:CaptureFocus()
					delay(0.01, function() 
						ChatBox.Text = ""	
					end)
				elseif input.KeyCode == Enum.KeyCode.Tab then
					-- {0, 278},{0, 65}
					ChangeTabMode()
				end
			end
		end
	end	
end)

ActivateUIAnim.Changed:connect(function()
	wait(.1)
	local ActValue = tostring(ActivateUIAnim.Value)
	print("[Client] Animation UI has changed to: "..ActValue)
	if ActivateUIAnim.Value == true then
		PlayFrameAnim("Start")
	else
		PlayFrameAnim("End")
	end
end)

self.Settings.EnableSLock.MouseButton1Click:connect(function()
	if ShiftLockEnabled.Value == false then
		self.Settings.EnableSLock.Text = "X"
		ShiftLockEnabled.Value = true
	else
		self.Settings.EnableSLock.Text = " "
		ShiftLockEnabled.Value = false
	end
end)

ActivateWinnerAnim.Changed:connect(function()
	wait(.1)
	local ActValue = tostring(ActivateWinnerAnim.Value)
	print("[Client] Animation 2 UI has changed to: "..ActValue)
	if ActivateWinnerAnim.Value == true then
		PlayFrame2Anim("Start")
	else
		PlayFrame2Anim("End")
	end
end)

ActivateUIMsg.Changed:connect(function()
	AnimFrame1.InfoText.Text = ActivateUIMsg.Value
	AnimFrame1.InfoText.Shadow.Text = ActivateUIMsg.Value
end)

ActivateUIMsg.Changed:connect(function()
	AnimFrame1.InfoText.Text = ActivateUIMsg.Value
	AnimFrame1.InfoText.Shadow.Text = ActivateUIMsg.Value
end)

ActivateWinnerMsg.Changed:connect(function()
	AnimFrame2.WinnerLabel.Text = ActivateWinnerMsg.Value
	AnimFrame2.WinnerLabel.Shadow.Text = ActivateWinnerMsg.Value
end)

ActivateWinnerSubMsg.Changed:connect(function()
	AnimFrame2.WinnerLabel.SubMessage.Text = ActivateWinnerSubMsg.Value
	AnimFrame2.WinnerLabel.SubMessage.Shadow.Text = ActivateWinnerSubMsg.Value
end)

ChangeMessage()
Run.RenderStepped:connect(ChangeCamera)

PlayerStatus.Changed:connect(function(va)
	wait(.1)
	if va == "AtSpawn" then
		for i = 1, 4 do
			local thisBtn = self:FindFirstChild(ButtonTableOfEpic[i])
			if thisBtn and thisBtn:FindFirstChild("ActivateAnimation") then
				print("[Client] Found Activate Anim Value in: "..thisBtn.Name)
				thisBtn:FindFirstChild("ActivateAnimation").Value = false
			end
		end
	elseif va == "InGame" then
		for i = 1, 4 do
			local thisBtn = self:FindFirstChild(ButtonTableOfEpic[i])
			if thisBtn and thisBtn:FindFirstChild("ActivateAnimation") then
				print("[Client] Found Activate Anim Value in: "..thisBtn.Name)
				thisBtn:FindFirstChild("ActivateAnimation").Value = true
			end
		end
		for i,v in pairs(MenuFrames) do
			if v:IsA("Frame") then
				if v.Name == "Settings" then
					-- do nothing
				else
					v.Visible = false
				end
			end
		end
	end
end)

GameMode.Changed:connect(function()
	wait(.1)
	if GameMode.Value == "Intermission" or GameMode.Value == "SelectingWinner" then
		GoToGame.Visible = false
		for i,v in pairs(self.KillFeed:GetChildren()) do
			v:Destroy()
		end
	else
		if PlayerStatus.Value == "AtSpawn" then
			GoToGame.Visible = true
		else
			GoToGame.Visible = false
		end
	end
end)

GoToGame.MouseButton1Click:connect(function()
	if Player.IsSpectating.Value == false then
		Rep.SetSpectateMode:FireServer(true)
		GoToGame.Visible = false
	else
		GoToGame.Text = "You are in spectate mode!"
		wait(2)
		GoToGame.Text = "Join the Match!"
	end
end)

self["1Shop"].MouseButton1Click:connect(function()
	if MenuFrames.Shop.Visible == false then
		for i,v in pairs(MenuFrames) do
			if v.Name == "Shop" then
				-- do nothing
			else
				v.Visible = false
			end
		end
		MenuFrames.Shop.Visible = true
	else
		MenuFrames.Shop.Visible = false
	end
end)

self["2Inventory"].MouseButton1Click:connect(function()
	if MenuFrames.Inventory.Visible == false then
		for i,v in pairs(MenuFrames) do
			if v.Name == "Inventory" then
				-- do nothing
			else
				v.Visible = false
			end
		end
		MenuFrames.Inventory.Visible = true	
	else
		MenuFrames.Inventory.Visible = false
	end
end)

self["3Spectate"].MouseButton1Click:connect(function()
	Rep.SetSpectateMode:FireServer(false)
end)

self["4Settings"].MouseButton1Click:connect(function()
	if MenuFrames.Settings.Visible == false then
		for i,v in pairs(MenuFrames) do
			if v.Name == "Settings" then
				-- do nothing
			else
				v.Visible = false
			end
		end
		MenuFrames.Settings.Visible = true	
	else
		MenuFrames.Settings.Visible = false
	end
end)

local MuteMode = false

self["5Mute"].MouseButton1Click:connect(function()
	if MuteMode == true then
		workspace.Sounds.Music.Volume = CurrentVolume
		self["5Mute"].Image = RbxAssetId..1161665597
		self["5Mute"]["HoverLabel"].Text = "Mute"
		MuteMode = false
	else		
		workspace.Sounds.Music.Volume = 0
		self["5Mute"].Image = RbxAssetId..1161667159
		self["5Mute"]["HoverLabel"].Text = "Unmute"
		MuteMode = true
	end
	self["5Mute"]["HoverLabel"]["Shadow"].Text = self["5Mute"]["HoverLabel"].Text
end)

MenuFrames.Settings.ExitButton.MouseEnter:connect(function()
	script.Sounds.Hover:Play()
end)

MenuFrames.Settings.ExitButton.MouseButton1Click:connect(function()
	MenuFrames.Settings.Visible = false
end)

Player.IsSpectating.Changed:connect(function(v)
	wait(.1)
	if v == true then
		self["3Spectate"].HoverLabel.PlayingIndicator.Text = "You are currently in: Spectate mode."
	elseif v == false then
		self["3Spectate"].HoverLabel.PlayingIndicator.Text = "You are currently in: Playing mode."
	end	
	self["3Spectate"].HoverLabel.PlayingIndicator.Shadow.Text = self["3Spectate"].HoverLabel.PlayingIndicator.Text
	print("[Client] Spectating Value set to: "..tostring(v))
end)

local JustJoined = true
BloxBux.Changed:connect(function(v)
	wait(.1)
	if JustJoined == true then
		JustJoined = false
		self.BuxLabel.BuxText.Text = tostring(v)
		self.BuxLabel.BuxText.Shadow.Text = tostring(v)
	else
		self.BuxLabel.BuxText.Text = tostring(v)	
		self.BuxLabel.BuxText.Shadow.Text = tostring(v)
		script.Sounds.CashObtain:Play()
	end
end)

print("[Client] "..Player.Name.."'s client has successfully loaded.") 

UpdatePlayerlist()

if GameMode.Value == "Intermission" or GameMode.Value == "SelectingWinner" or GameMode.Value == "Waiting" then
	GoToGame.Visible = false
else
	if PlayerStatus.Value == "AtSpawn" then
		GoToGame.Visible = true
	else
		GoToGame.Visible = false
	end
end

spawn(function()
	while wait() do
		if MuteMode == true and workspace.Sounds.Music.Volume > 0 then
			workspace.Sounds.Music.Volume = 0
		end
	end	
end)

workspace.Sounds.Music.Played:connect(function()
	workspace.Sounds.Music.Volume = CurrentVolume
	if MuteMode == true and workspace.Sounds.Music.Volume > 0 then
		 workspace.Sounds.Music.Volume = 0
	end
end)

spawn(function()
	while true do
		if RoundInfo.DebugMode.Value == true or Run:IsStudio() then
			print("[Client] Spam Filter Number: "..tostring(SpamFilter)..".")
		end
		if SpamFilter > 0 then
			if SpamFilter >= 4 then
				IsAllowedToChat = false
			end
			SpamFilter = SpamFilter - 1
		else
			if IsAllowedToChat == false then
				IsAllowedToChat = true
			end
		end
		wait(1)
	end
end)

spawn(function()
	local resetEnabled = false
	script.OnReset.Event:connect(function()
		Rep.ResetBind:FireServer()
		if GameMode.Value == "SelectingWinner" then
			Networking.Functions["GenerateSpecMessage"]("Client","You cannot reset at this time. It would be very rude of you to do so.")
		end
	end)
	
	while resetEnabled == false do
		local success = pcall(function()
			StarterGui:SetCore("ResetButtonCallback", script.OnReset)
		end)
		if success then
			resetEnabled = true
			StarterGui:SetCore("ResetButtonCallback", script.OnReset)
		end
		wait()
	end
end)