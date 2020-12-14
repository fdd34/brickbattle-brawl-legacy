local MOUSE_ICON = 'rbxasset://textures/GunCursor.png'
local RELOADING_ICON = 'rbxasset://textures/GunWaitCursor.png'

local Tool = script.Parent
local Mouse = nil
local EventHandler = Tool:WaitForChild("EventHandler")
local UIS = game:GetService("UserInputService")
local Equipped = false

function UpdateIcon()
	local MOUSE_ICON = 'rbxasset://textures/GunCursor.png'
	local RELOADING_ICON = 'rbxasset://textures/GunWaitCursor.png'
	if Mouse then
		Mouse.Icon = Tool.Enabled and MOUSE_ICON or RELOADING_ICON
	end
end

function OnChanged(property)
	if property == 'Enabled' then
		UpdateIcon()
	end
end

UIS.InputBegan:connect(function(input)
	if input and Equipped then
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			EventHandler:FireServer("OnActivation",Mouse.Hit.p)
		end
	end
end)

UIS.InputEnded:connect(function(input)
	if input and Equipped then
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			EventHandler:FireServer("OnDeactivation")
		end
		
	end
end)

Tool.Equipped:connect(function(mouse)
	Mouse = mouse
	--mouse.Icon = "rbxasset://textures\\GunCursor.png"
	Equipped = true
end)

Tool.Unequipped:connect(function()
	if Mouse then
		--Mouse.Icon = "rbxassetid://1075016657"
	end
	Equipped = false
	EventHandler:FireServer("OnDeactivation")
end)

Tool.Changed:connect(OnChanged)