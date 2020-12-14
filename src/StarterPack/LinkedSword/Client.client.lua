local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Tool = script.Parent
local Event = Tool:WaitForChild("Event")
local Enabled = true
local Equipped = false

UIS.InputBegan:connect(function(input)
	if input and Equipped then
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			Event:FireServer("OnActivation")
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
end)