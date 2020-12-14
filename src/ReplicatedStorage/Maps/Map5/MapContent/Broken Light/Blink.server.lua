while wait() do
	local n = math.random(10)
	if n == 1 then
		script.Parent.PointLight.Enabled = false
	else
		script.Parent.PointLight.Enabled = true
	end
end