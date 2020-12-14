repeat wait () until script.Parent.Cutscene.Value ~= nil

function onClicked()
	script.Parent.Cutscene.Value:Destroy()
	game.Workspace.CurrentCamera.CameraType = "Custom"
	game.Workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
	game.Workspace.CurrentCamera.FieldOfView = 70
	script.Parent:Destroy()
end

script.Parent.Skip.MouseButton1Down:connect(onClicked)