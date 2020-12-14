local debounce = false 
local HealthLoss = 25 
function OnTouched(Part) 
if Part.Parent ~= nil then 
if debounce == false and Part.Parent:findFirstChild("Humanoid") ~= nil then 
debounce = true 
Part.Parent:findFirstChild("Humanoid"):TakeDamage(HealthLoss) 
wait(0.5)
debounce = false 
end 
end 
end 
script.Parent.Touched:connect(OnTouched)