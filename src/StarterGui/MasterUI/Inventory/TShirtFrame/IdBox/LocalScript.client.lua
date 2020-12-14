script.Parent.Changed:connect(function()
	if script.Parent:IsFocused() then
		script.Parent.Text = string.gsub(script.Parent.Text,"%a","")
	end
end)