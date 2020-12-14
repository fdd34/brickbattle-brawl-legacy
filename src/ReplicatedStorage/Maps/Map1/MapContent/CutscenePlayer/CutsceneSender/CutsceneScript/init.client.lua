-- DO NOT MESS WITH ANYTHING BELOW UNLESS YOU KNOW WHAT YOUR DOING.

repeat wait () until game.Workspace.CurrentCamera ~= nil
wait()
c = game.Workspace.CurrentCamera

function tweenCam(c1,f1,time,fov,roll)
	local c0,f0,fv0,r0,frames = c.CoordinateFrame,c.Focus,c.FieldOfView,c:GetRoll(),time/0.03
	for i = 1,frames do
		c.CameraType = "Scriptable"
		c.CoordinateFrame = CFrame.new(c0.p:lerp(c1.p,i/frames))
		c.Focus = CFrame.new(f0.p:lerp(f1.p,i/frames))
		c.CoordinateFrame = CFrame.new(c.CoordinateFrame.p,c.Focus.p)
		c.FieldOfView = (fv0+(fov-fv0)*(i*(1/frames)))
		c:SetRoll(r0+(roll-r0)*(i*(1/frames)))
		wait()
	end
end

print("Running")
c.CameraSubject = nil	
c.CameraType = "Scriptable"
local cutsceneData = script.CutsceneData:GetChildren()
c.CoordinateFrame = script.CutsceneData["1"].c1.Value
c.Focus = script.CutsceneData["1"].f1.Value
c.FieldOfView = script.CutsceneData["1"].FOV.Value
c:SetRoll(script.CutsceneData["1"].Roll.Value)
if script:findFirstChild("SkipCutscene") then
	local gui = script.SkipCutsceneGui:clone()
	gui.Parent = game.Players.LocalPlayer.PlayerGui
	gui.Cutscene.Value = script
	gui.Main.Debug.Disabled = false
	script.SkipCutscene.Value = gui
end
for i = 2,#cutsceneData do
	local dataHolder = script.CutsceneData[tostring(i)]
	local c = dataHolder.c1.Value
	local f = dataHolder.f1.Value
	local s = dataHolder.step.Value	
	local fov = dataHolder.FOV.Value
	local r = dataHolder.Roll.Value
	tweenCam(c,f,s,fov,r)
end
c.CameraSubject = game.Players.LocalPlayer.Character.Humanoid	
c.CameraType = "Custom"
c.FieldOfView = 70
if script:findFirstChild("SkipCutscene") then
	if script.SkipCutscene.Value ~= nil then
		script.SkipCutscene.Value:Destroy()
	end
end
script:Destroy()
	