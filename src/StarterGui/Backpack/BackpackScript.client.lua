--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RbxClient Backpack UI
--------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Services
local Rep = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")

local RoundInfo = Rep:WaitForChild("RoundInfo")
local GameMode = RoundInfo:WaitForChild("Gamemode")

-- Self Variables
local self = script.Parent
local currentLoadout = self:WaitForChild("Backpack")
local currentTempSlot = currentLoadout:WaitForChild("TempSlot")
local currentSlotNumb = currentTempSlot:WaitForChild("SlotNumber")

-- Player Variables
repeat wait(.1) until Players.LocalPlayer
repeat wait(.1) until Players.LocalPlayer.Character

local Player = Players.LocalPlayer
local PlayerBP = Player:WaitForChild("Backpack")
local Character = Player.Character
local humanoid = Character:WaitForChild('Humanoid')

-- Important Variables
local Settings = {
	CharacterChildAddedCon = nil,
	Debounce = false,
	EnlargeFactor = 1.18,
	EnlargeOverride = true,
	GuiTweenSpeed = 0.5,
}
local inventory = {}
local gearSlots = {}

local buttonSizeEnlarge = UDim2.new(1 * Settings.EnlargeFactor, 0, 1 * Settings.EnlargeFactor, 0)
local buttonSizeNormal = UDim2.new(1,0,1,0)

for i = 1,10 do
	gearSlots[i] = "empty"
end

local keyEvent = Instance.new("BindableEvent", script)
keyEvent.Name = "KeyNumberEvent"

--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Functions / Methods
--------------------------------------------------------------------------------------------------------------------------------------------------------------

local function kill(prop,con,gear)
	if con then con:disconnect() end
	if prop == true and gear then
		reorganizeLoadout(gear,false)
	end
end

function registerNumberKeys()
	local mouse = game.Players.LocalPlayer:GetMouse()
	mouse.KeyDown:connect(function (key)
		if tonumber(key) then
			keyEvent:Fire(key)
		end
	end)
end

function characterInWorkspace()
	if Player and Player.Character and Player.Character.Parent == workspace then
		return true
	end
	return false
end

function centerGear()
	local loadoutChildren = currentLoadout:GetChildren()
	local gearButtons = {}
	local lastSlotAdd = nil
	for i = 1,#loadoutChildren do
		if loadoutChildren[i]:IsA("Frame") and #loadoutChildren[i]:GetChildren() > 0  then
			if loadoutChildren[i].Name == "Slot0" then 
				lastSlotAdd = loadoutChildren[i]
			else
				table.insert(gearButtons,loadoutChildren[i])
			end
			loadoutChildren[i].BackgroundTransparency = 1
		end
	end
	
	if lastSlotAdd then table.insert(gearButtons,lastSlotAdd) end
	
	local startPos = ( 1 - (#gearButtons * 0.1) ) / 2
	for i = 1,#gearButtons do			
		gearButtons[i]:TweenPosition(UDim2.new(startPos + ((i - 1) * 0.1),0,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.25,true)
	end
end

function removeGear(gear)
	local emptySlot = nil
	for i = 1,#gearSlots do
		if gearSlots[i] == gear and gear.Parent ~= nil then
			emptySlot = i
			break
		end
	end
	if emptySlot then
		if gearSlots[emptySlot].GearReference.Value then
			if gearSlots[emptySlot].GearReference.Value.Parent == Character then 
				gearSlots[emptySlot].GearReference.Value.Parent = PlayerBP
			end
		end
		gearSlots[emptySlot] = "empty"
		local centerizeX = gear.Size.X.Scale/2
		local centerizeY = gear.Size.Y.Scale/2		
		delay(0,function ()
			gear:remove()
		end)	
	end	
end

function insertGear(gear,addToSlot)
	local pos = nil
	if not addToSlot then
		for i = 1,#gearSlots do
			if gearSlots[i] == "empty" then
				pos = i
				break
			end
		end
		if pos == 1 and gearSlots[1] ~= "empty" then gear:remove() return end
	else
		pos = addToSlot
		local start = 1
		for i = 1,#gearSlots do
			if gearSlots[i] == "empty" then
				start = i
				break
			end
		end
		for i = start,pos + 1,-1 do
			gearSlots[i] = gearSlots[i - 1]
			if i == 10 then
				gearSlots[i].SlotNumber.Text = "0"
				gearSlots[i].SlotNumberDownShadow.Text = "0"
				gearSlots[i].SlotNumberUpShadow.Text = "0"
			else
				gearSlots[i].SlotNumber.Text = i
				gearSlots[i].SlotNumberDownShadow.Text = i
				gearSlots[i].SlotNumberUpShadow.Text = i
			end
		end
	end

	gearSlots[pos] = gear
	if pos ~= 10 then
		if(type(tostring(pos)) == "string") then
			local posString = tostring(pos)
			gear.SlotNumber.Text = posString
			gear.SlotNumberDownShadow.Text = posString
			gear.SlotNumberUpShadow.Text = posString
		end
	else
		gear.SlotNumber.Text = "0"
		gear.SlotNumberDownShadow.Text = "0"
		gear.SlotNumberUpShadow.Text = "0"
	end
	gear.Visible = true

	local con = nil
	con = gear.Kill.Changed:connect(function (prop) kill(prop,con,gear) end)
end


function reorganizeLoadout(gear,inserting,equipped,addToSlot)
	if inserting then
		insertGear(gear,addToSlot)
	else
		removeGear(gear)
	end
	if gear ~= "empty" then	
		gear.ZIndex = 1 
	end
	centerGear()
end

function removeAllEquippedGear(physGear)
	local stuff = Character:GetChildren()
	for i = 1,#stuff do
		if stuff[i]:IsA("Tool") and stuff[i] ~= physGear then
			stuff[i].Parent = PlayerBP 
		end
	end
end

function toolSwitcher(numKey)
	if not gearSlots[numKey] then return end
	local physGear = gearSlots[numKey].GearReference.Value
	if physGear == nil then return end
	removeAllEquippedGear(physGear)
	local key = numKey
	if numKey == 0 then key = 10 end
	for i = 1,#gearSlots do
		if gearSlots[i] and gearSlots[i] ~= "empty" and i ~= key then
			normalizeButton(gearSlots[i])
			gearSlots[i].Selected = false
		end
	end
	if physGear.Parent == Character then
		physGear.Parent = PlayerBP	
		if gearSlots[numKey] ~= "empty" then
			gearSlots[numKey].Selected = false
			normalizeButton(gearSlots[numKey])
		end
	else
		physGear.Parent = Character
		gearSlots[numKey].Selected = true

		enlargeButton(gearSlots[numKey])
	end
end

function activateGear(num)
	local EnumKeys = {
		[Enum.KeyCode.One] = 1,
		[Enum.KeyCode.Two] = 2,
		[Enum.KeyCode.Three] = 3,
		[Enum.KeyCode.Four] = 4,
		[Enum.KeyCode.Five] = 5,
		[Enum.KeyCode.Six] = 6,
		[Enum.KeyCode.Seven] = 7,
		[Enum.KeyCode.Eight] = 8,
		[Enum.KeyCode.Nine] = 9,
		[Enum.KeyCode.Zero] = 0,
	}
	if num and EnumKeys[num] then
		local numKey = EnumKeys[num]
		if gearSlots[numKey] and gearSlots[numKey] ~= "empty" then
			toolSwitcher(numKey)
		end
	end
end

enlargeButton = function (button)
	if button.Size.Y.Scale > 1 then return end
	if not button.Parent then return end
	if not button.Selected then return end
	for i = 1,#gearSlots do
		if gearSlots[i] == "empty" then break end
		if gearSlots[i] ~= button then
			normalizeButton(gearSlots[i])
		end
	end
	if not Settings.EnlargeOverride then
		return
	end
	if button:FindFirstChild('Highlight') then
		button.Highlight.Visible = true
	end 

	if button:IsA("ImageButton") or button:IsA("TextButton") then
		button.ZIndex = 5
		local centerizeX = -(buttonSizeEnlarge.X.Scale - button.Size.X.Scale)/2
		local centerizeY = -(buttonSizeEnlarge.Y.Scale - button.Size.Y.Scale)/2
		button:TweenSizeAndPosition(buttonSizeEnlarge,UDim2.new(button.Position.X.Scale + centerizeX,button.Position.X.Offset,button.Position.Y.Scale + centerizeY,button.Position.Y.Offset),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,Settings.GuiTweenSpeed/5,Settings.EnlargeOverride)
	end
end

normalizeAllButtons = function ()
	for i = 1,#gearSlots do
		if gearSlots[i] == "empty" then break end
		if gearSlots[i] ~= button then
			normalizeButton(gearSlots[i],0.1)
		end
	end
end


normalizeButton = function (button,speed)
	if not button or button:IsA("Tool") then return end
	if button.Size.Y.Scale <= 1 then return end
	if button.Selected then return end
	if not button.Parent then return end
	local moveSpeed = speed
	if moveSpeed == nil or type(moveSpeed) ~= "number" then moveSpeed = Settings.GuiTweenSpeed/5 end
	if button:FindFirstChild('Highlight') then
		button.Highlight.Visible = false 
	end 
	if button:IsA("ImageButton") or button:IsA("TextButton") then
		button.ZIndex = 1
		local inverseEnlarge = 1 / Settings.EnlargeFactor
		local centerizeX = -(buttonSizeNormal.X.Scale - button.Size.X.Scale)/2
		local centerizeY = -(buttonSizeNormal.Y.Scale - button.Size.Y.Scale)/2
		button:TweenSizeAndPosition(buttonSizeNormal,UDim2.new(button.Position.X.Scale + centerizeX,button.Position.X.Offset,button.Position.Y.Scale + centerizeY,button.Position.Y.Offset),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,moveSpeed,Settings.EnlargeOverride)
	end
end

local waitForDebounce = function ()
	while debounce do
		wait()
	end
end

function unequipAllItems(dontEquipThis)
	for i = 1,#gearSlots do
		if gearSlots[i] == "empty" then break end
		if gearSlots[i].GearReference.Value and gearSlots[i].GearReference.Value ~= dontEquipThis then
			gearSlots[i].GearReference.Value.Parent = PlayerBP
			gearSlots[i].Selected = false
		end
	end
end

function showToolTip(button,tip)
	if button and button:FindFirstChild("ToolTipLabel") and button.ToolTipLabel:IsA("TextLabel") then
		button.ToolTipLabel.Text = tostring(tip)
		local xSize = button.ToolTipLabel.TextBounds.X + 6
		button.ToolTipLabel.Size = UDim2.new(0,xSize,0,20)
		button.ToolTipLabel.Position = UDim2.new(0.5,-xSize/2,0,-30)
		button.ToolTipLabel.Visible = true
	end
end

function hideToolTip(button,tip)
	if button and button:FindFirstChild("ToolTipLabel") and button.ToolTipLabel:IsA("TextLabel") then
		button.ToolTipLabel.Visible = false
	end
end

function delayCenter()
	-- I had no other solution here. This is the only solution to recentering the gui when a tool is dropped - CloneTrooper1019
	delay(0.1,function ()
		centerGear()
	end)
end

local addingPlayerChild = function (child,equipped,addToSlot,inventoryGearButton)	
	waitForDebounce()
	debounce = true
	if child:FindFirstChild("RobloxBuildTool") then debounce = false return end
	if not child:IsA("Tool") then
		debounce = false
		return
	end
	if not addToSlot then
		for i = 1,#gearSlots do
			if gearSlots[i] ~= "empty" and gearSlots[i].GearReference.Value == child then 
				debounce = false
				return
			end		
		end
	end
	local gearClone = currentLoadout.TempSlot:clone()
	gearClone.Name = child.Name
	gearClone.GearImage.Image = child.TextureId
	if gearClone.GearImage.Image == "" then
		gearClone.GearText.Text = child.Name
	end
	gearClone.GearReference.Value = child
	gearClone.MouseEnter:connect(function ()
		if gearClone.GearReference and gearClone.GearReference.Value["ToolTip"] and gearClone.GearReference.Value.ToolTip ~= "" then
			showToolTip(gearClone,gearClone.GearReference.Value.ToolTip)
		end
	end)
	gearClone.MouseLeave:connect(function ()
		if gearClone.GearReference and gearClone.GearReference.Value["ToolTip"] and gearClone.GearReference.Value.ToolTip ~= "" then
			hideToolTip(gearClone,gearClone.GearReference.Value.ToolTip)
		end
	end)
	
	local slotToMod = -1
	if not addToSlot then
		for i = 1,#gearSlots do
			if gearSlots[i] == "empty" then
				slotToMod = i
				break
			end
		end
	else
		slotToMod = addToSlot
	end
	if slotToMod == - 1 then
		debounce = false
		return 
	end
	local slotNum = slotToMod % 10
	local parent = currentLoadout:FindFirstChild("Slot"..tostring(slotNum))
	gearClone.Parent = parent
	if inventoryGearButton then
		local absolutePositionFinal = inventoryGearButton.AbsolutePosition
		local currentAbsolutePosition = gearClone.AbsolutePosition
		local diff = absolutePositionFinal - currentAbsolutePosition
		gearClone.Position = UDim2.new(gearClone.Position.X.Scale,diff.x,gearClone.Position.Y.Scale,diff.y)
		gearClone.ZIndex = 4
	end
	if addToSlot then
		reorganizeLoadout(gearClone,true,equipped,addToSlot)
	else
		reorganizeLoadout(gearClone,true)
	end
	if gearClone.Parent == nil then debounce = false return end
	if equipped then
		gearClone.Selected = true
		unequipAllItems(child)
		delay(Settings.GuiTweenSpeed + 0.01,function ()
			if gearClone:FindFirstChild("GearReference") and gearClone.GearReference.Value.Parent == Character then
				enlargeButton(gearClone)
			end
		end)
	end
	local dragBeginPos = nil
	local clickCon,buttonDeleteCon,mouseEnterCon,mouseLeaveCon,dragStop,dragBegin = nil
	gearClone.MouseButton1Click:connect(function () 
		local specNumbs = {
			[1] = Enum.KeyCode.One,
			[2] = Enum.KeyCode.Two,
			[3] = Enum.KeyCode.Three,
			[4] = Enum.KeyCode.Four,
			[5] = Enum.KeyCode.Five,
			[6] = Enum.KeyCode.Six,
			[7] = Enum.KeyCode.Seven,
			[8] = Enum.KeyCode.Eight,
			[9] = Enum.KeyCode.Nine,
			[0] = Enum.KeyCode.Zero,
		}
		if characterInWorkspace() then
			if not gearClone.Draggable then
				activateGear(specNumbs[tonumber(gearClone.SlotNumber.Text)])
			end
		end
	end)
	buttonDeleteCon = gearClone.AncestryChanged:connect(function ()
		if gearClone.Parent and gearClone.Parent.Parent == currentLoadout then return end
		if clickCon then clickCon:disconnect() end
		if buttonDeleteCon then buttonDeleteCon:disconnect() end
		if mouseEnterCon then mouseEnterCon:disconnect() end
		if mouseLeaveCon then mouseLeaveCon:disconnect() end
		if dragStop then dragStop:disconnect() end
		if dragBegin then dragBegin:disconnect() end
	end)
	local childCon = nil
	local childChangeCon = nil
	childCon = child.AncestryChanged:connect(function (newChild,parent)
		if parent == workspace then
			delayCenter()
			if gearClone:findFirstChild("Kill") then
				gearClone.Kill.Value = true
			end
		elseif Character and parent == Character then
			gearClone.Selected = true
			enlargeButton(gearClone)
		elseif parent == PlayerBP then
			gearClone.Selected = false
			normalizeButton(gearClone)
		end
		centerGear()
	end)
	childChangeCon = child.Changed:connect(function (prop)
		if prop == "Name" then
			if gearClone and gearClone.GearImage.Image == "" then
				gearClone.GearText.Text = child.Name
			end
		elseif prop == "TextureId" then
			gearClone.GearImage.Image = child.TextureId
		end
	end)
	debounce = false
end

function addToInventory(child)
	if not child:IsA("Tool") then return end

	local slot = nil
	for i = 1,#inventory do
		if inventory[i] and inventory[i] == child then return end
		if not inventory[i] then slot = i end
	end
	if slot then
		inventory[slot] = child
	elseif #inventory < 1 then
		inventory[1] = child
	else
		inventory[#inventory + 1] = child
	end
end

function removeFromInventory(child)
	for i = 1,#inventory do
		if inventory[i] == child then
			table.remove(inventory,i)
			inventory[i] = nil
		end
	end
end

function playerCharacterChildAdded(child)
	addingPlayerChild(child,true)
	addToInventory(child)
end

function activateLoadout()
	currentLoadout.Visible = true
end

function deactivateLoadout()
	currentLoadout.Visible = false
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Setting up the Backpack
--------------------------------------------------------------------------------------------------------------------------------------------------------------

registerNumberKeys()
wait()

delay(1,function ()	
	local backpackChildren = PlayerBP:GetChildren()
	local size = math.min(10,#backpackChildren)
	for i = 1,size do
		addingPlayerChild(backpackChildren[i],false)
	end
end)

delay(2,function ()	 
	if script.Parent.AbsoluteSize.Y <= 320 then 		
		local cChildren = currentLoadout:GetChildren()
		for i = 1,#cChildren do 
			local slotNum = tonumber(string.sub(cChildren[i].Name,5,string.len(cChildren[i].Name)))			
			if type(slotNum) == 'number' then 				
				cChildren[i].Position = UDim2.new(0,(slotNum-1) * 60,0,0)
			end 
		end 
	end 
end)

for i,v in ipairs(Character:GetChildren()) do
	playerCharacterChildAdded(v)
end

Settings.CharacterChildAddedCon = Character.ChildAdded:connect(function (child) 
	playerCharacterChildAdded(child) 
end)

humanoidDiedCon = Character:WaitForChild("Humanoid").Died:connect(function ()
	if humanoidDiedCon then 
		humanoidDiedCon:disconnect() 
		humanoidDiedCon = nil 
	end
	deactivateLoadout()
end)

Player.CharacterRemoving:connect(function ()
	for i = 1,#gearSlots do
		if gearSlots[i] ~= "empty" then
			gearSlots[i].Parent = nil
			gearSlots[i] = "empty"
		end
	end
end)

Player.CharacterAdded:connect(function ()		
	player = game.Players.LocalPlayer
	delay(1,function ()	
		local backpackChildren = player:WaitForChild("Backpack"):GetChildren()
		local size = math.min(10,#backpackChildren)
		for i = 1,size do
			addingPlayerChild(backpackChildren[i],false)
		end
	end)
	activateLoadout()	
	if Settings.CharacterChildAddedCon then 
		Settings.CharacterChildAddedCon:disconnect()
		Settings.CharacterChildAddedCon = nil
	end
	Settings.CharacterChildAddedCon = Character.ChildAdded:connect(function (child)
		addingPlayerChild(child,true)
	end)
	humanoidDiedCon = Character:WaitForChild("Humanoid").Died:connect(function ()
		deactivateLoadout()								
		if humanoidDiedCon then 
			humanoidDiedCon:disconnect() 
			humanoidDiedCon = nil 
		end
	end)
	delay(2,function ()	
		if script.Parent.AbsoluteSize.Y <= 320 then 		
			local cChildren = currentLoadout:GetChildren()
			for i = 1,#cChildren do 
				local slotNum = tonumber(string.sub(cChildren[i].Name,5,string.len(cChildren[i].Name)))			
				if type(slotNum) == 'number' then 				
					cChildren[i].Position = UDim2.new(0,(slotNum-1) * 60,0,0)
				end 
			end 
		end 
	end) 	
end)

function FindIfChildMatches(child)
	for i,v in pairs(script.Parent.Backpack:GetChildren()) do
		for i2,v2 in pairs(v:GetChildren()) do
			local vGearReference = v2:FindFirstChild("GearReference")
			if vGearReference and vGearReference.Value == child then
				return true
			end
		end
	end
	return false
end

function FindIfChildMatches2(child)
	for i,v in pairs(script.Parent.Backpack:GetChildren()) do
		for i2,v2 in pairs(v:GetChildren()) do
			local vGearReference = v2:FindFirstChild("GearReference")
			if vGearReference and vGearReference.Value == child then
				return v2
			end
		end
	end
	return nil
end

PlayerBP.ChildAdded:connect(function(child)
	print("Child added.")
	if child:IsA("Tool") and FindIfChildMatches(child) == false then
		print("Adding to inventory.")
		playerCharacterChildAdded(child)
	end
end)

PlayerBP.ChildRemoved:connect(function(child)
	if child then
		if child.Parent and child.Parent == Character then
			-- do nothing
		else
			local LoL = FindIfChildMatches2(child)
			if LoL then
				reorganizeLoadout(LoL,false)
			end
		end
	end
end)

function CheckForBtnActivity()
	if characterInWorkspace() and GameMode.Value ~= "Intermission" and GameMode.Value ~= "SelectingWinner" and self.Enabled then
		return true
	end
	return false
end

UIS.InputBegan:connect(function(input)
	if input then
		if CheckForBtnActivity() == true then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				if input.KeyCode then
					activateGear(input.KeyCode)
				end
			end
		end
	end
end)

self.Changed:connect(function()
	if self.Enabled then
		-- do nothing
	else
		for i,v in pairs(Character:GetChildren()) do
			if v:IsA("Tool") then
				v.Parent = PlayerBP
			end
		end
	end
end)