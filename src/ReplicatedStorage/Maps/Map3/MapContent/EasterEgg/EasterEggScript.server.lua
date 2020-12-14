local debounce = false
script.Parent.Touched:connect(function(hit)
	if hit and hit.Parent and hit.Parent:FindFirstChild("Humanoid") and debounce == false then
		debounce = true
		script.Parent.Song:Play()
		wait(script.Parent.Song.TimeLength + 3)
		debounce = false
	end
end)