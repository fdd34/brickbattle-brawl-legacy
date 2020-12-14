while true do
	for i=1, 9, 1 do
		-- Go up
		script.Parent.Reflectance = i * .1
		wait(.1)
	end
	for i=9, 1, -1 do
		-- Go down
		script.Parent.Reflectance = i * .1
		wait(.1)
	end
end
