repeat wait () until script.CutsceneScript ~= nil
debounce = false

function onTouched(hit)
	if debounce == true then return end
	if hit.Parent:findFirstChild("CutsceneScript") then return end -- If theres already a cutscene running, then don't do anything.
	if not hit.Parent:findFirstChild("Humanoid") then return end -- If theres no humanoid,  then don't do anything
	if not game.Players:GetPlayerFromCharacter(hit.Parent) then return end -- If its not a player, then don't do anything.
	debounce = true
	local cutsceneScript = script.CutsceneScript:clone()
	cutsceneScript.Parent = hit.Parent
	cutsceneScript.Disabled = false
	repeat wait () until cutsceneScript.Parent == nil
	wait(3)
	debounce = false
end

script.Parent.Touched:connect(onTouched)