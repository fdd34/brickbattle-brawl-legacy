seat=script.Parent
cam=seat.Cam:clone()
RArmMotor=CFrame.new(1, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, -0, -0)
LArmMotor=CFrame.new(-1, 0.5, 0, -0, -0, -1, 0, 1, 0, 1, 0, 0)
RArmSit=RArmMotor*CFrame.fromEulerAnglesXYZ(0,0,1.5)+Vector3.new(0,.5,0)
LArmSit=LArmMotor*CFrame.fromEulerAnglesXYZ(0,0,-1.5)+Vector3.new(0,.5,0)
rotation=0
debounce=false
dir=1
function Arms()
	if character==nil then return end
	if character.Torso:findFirstChild("Right Shoulder")~=nil then
		character.Torso["Right Shoulder"].C0=RArmSit*CFrame.fromEulerAnglesXYZ(0,0,math.pi/6*seat.Throttle)--*dir)
	end
	if character.Torso:findFirstChild("Left Shoulder")~=nil then
		character.Torso["Left Shoulder"].C0=LArmSit*CFrame.fromEulerAnglesXYZ(0,0,-math.pi/6*seat.Throttle)--*dir)
	end
end
function rotate(steer)
	if steer~=0 and debounce==false then
		debounce=true
		if seat:findFirstChild("SeatWeld")~=nil then
			rotation=rotation+(math.pi/2*steer)
			seat.SeatWeld.C0=CFrame.new(0,2.3+(seat.Throttle*.4),0)*CFrame.fromEulerAnglesXYZ(-math.pi/2+(-math.pi/8*seat.Throttle*dir),0,rotation)
			rotation=rotation+(math.pi/2*steer)
		end
		wait(.5)
		if seat:findFirstChild("SeatWeld")~=nil then
			seat.SeatWeld.C0=CFrame.new(0,2.3+(seat.Throttle*.4),0)*CFrame.fromEulerAnglesXYZ(-math.pi/2+(-math.pi/8*seat.Throttle*dir),0,rotation)
		end
		debounce=false
	elseif steer==0 then
		seat.SeatWeld.C0=CFrame.new(0,2.3+(seat.Throttle*.4),0)*CFrame.fromEulerAnglesXYZ(-math.pi/2+(-math.pi/8*seat.Throttle*dir),0,rotation)
	end
	if (rotation/math.pi)%2==0 then
		dir=1
	else
		dir=-1
	end
end
function swing()
	rotate(0)
	seat.BodyThrust.force=Vector3.new(0,0,1000*seat.Throttle*dir)
	Arms()
end
function change(prop)
	if prop=="Throttle" then
		swing()
	elseif prop=="Steer" then
		rotate(seat.Steer)
	end
end
function added(child)
	if child.Name=="SeatWeld" then
		character=child.Part1.Parent
		child.C0=CFrame.new(0,0.9,0)*CFrame.fromEulerAnglesXYZ(-math.pi/2,0,0)
		camscript=cam:clone()
		camscript.Disabled=false
		camscript.Parent=game.Players:playerFromCharacter(character).Backpack
		Arms()
	end
end
function removed(child)
	if child.Name=="SeatWeld" then
		while seat.Throttle~=0 do wait() end --prevents arms from changing before the swing function is changed.
		character.Torso["Right Shoulder"].C0=RArmMotor
		character.Torso["Left Shoulder"].C0=LArmMotor
		rotation=0
		debounce=false
	end
end
seat.Changed:connect(change)
seat.ChildAdded:connect(added)
seat.ChildRemoved:connect(removed)