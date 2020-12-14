local MOUSE_ICON = 'rbxasset://textures/GunCursor.png'
local RELOADING_ICON = 'rbxasset://textures/GunWaitCursor.png'

local Tool = script.Parent
local Mouse = nil
local EventHandler = Tool:WaitForChild("EventHandler")
local UIS = game:GetService("UserInputService")
local Equipped = false

UIS.InputBegan:connect(function(input)
	if input and Equipped then
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			print("Firing")
			EventHandler:FireServer("OnActivation",Mouse.Hit.p)
		end
	end
end)

Tool.Equipped:connect(function(mouse)
	Equipped = true
	Mouse = mouse
end)

Tool.Unequipped:connect(function()
	Equipped = false
end)

--[[local function UpdateIcon()
	if Mouse then
		Mouse.Icon = Tool.Enabled and MOUSE_ICON or RELOADING_ICON
	end
end

local function OnEquipped(mouse)
	Mouse = mouse
	UpdateIcon()
end

local function OnChanged(property)
	if property == 'Enabled' then
		UpdateIcon()
	end
end

Tool.Equipped:connect(OnEquipped)
Tool.Changed:connect(OnChanged)]]
