script.Parent.Touched:connect(function(p)
local h = p.Parent:FindFirstChild("Humanoid")
if h ~= nil then
if p:FindFirstChild("Fire")==nil then
Instance.new("Fire").Parent = p
script.Script:Clone().Parent = p
end 
end
end)