newspeed = 8
script.Parent.Parent.Name = "Walkspeed "..newspeed

script.Parent.Touched:connect(function (hit)
local human = hit.Parent:findFirstChild("Humanoid")
if human then
	human.WalkSpeed = newspeed
	end
end)