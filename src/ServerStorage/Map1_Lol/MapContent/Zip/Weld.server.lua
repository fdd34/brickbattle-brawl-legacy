local prev
local parts = script.Parent:GetChildren()
for i = 1,#parts do
	if parts[i].className == "Part" then
		if prev ~= nil then
			local weld = Instance.new("Weld")
			weld.Part0 = prev
			weld.Part1 = parts[i]
			weld.C0 = prev.CFrame:inverse()
			weld.C1 = parts[i].CFrame:inverse()
			weld.Parent = prev
		end
		prev = parts[i]
	end
end
wait(1)
for i = 1,#parts do
	if parts[i].className == "Part" then
		parts[i].Anchored = false
	end
end
