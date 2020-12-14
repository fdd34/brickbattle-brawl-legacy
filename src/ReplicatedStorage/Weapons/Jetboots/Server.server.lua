--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RbxClient Jetboots [Server]
--------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Tool Variables
local Tool = script.Parent
local EventHandler = Tool:WaitForChild("EventHandler")

-- Important Variables
local Settings = {
	ReloadTime = 0,
	Velocity = 0,
	MaxVelocity = 30,
	FlightTime = 6,
}
local Walking = false
local Equipped = false
local Networking = {}

local currentSound = nil
local currentThrust = nil

-- Other Variables
local Thrust = Instance.new("BodyVelocity")
local JetbootsSound = Instance.new("Sound")
JetbootsSound.Name = "JetbootSound"
JetbootsSound.SoundId = "rbxasset://sounds\\Rocket whoosh 01.wav"
JetbootsSound.Looped = true

--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Functions / Methods
--------------------------------------------------------------------------------------------------------------------------------------------------------------

function onStart()
	if Equipped and not Walking and Character then
		print("Activating.")
		Walking = true
		Settings.ReloadTime = 4
		currentThrust = Thrust:Clone()
		currentThrust.Parent = Character.PrimaryPart
		currentThrust.Velocity = Vector3.new(0,velocity,0)
		currentThrust.maxForce = Vector3.new(0,4e+003,0) 
		
		currentSound  = JetbootsSound:Clone()
		currentSound.Parent = Character.PrimaryPart
		currentSound:Play()
	end
end

function onEnd()
	print("Deactivating.")
	Walking = false
	currentThrust:Destroy()
	currentThrust = nil
	currentSound:Stop()
	currentSound:Destroy()
	wait(4)
	Settings.ReloadTIme = 0
end

function OnActivated(mouse)
	if Equipped and Settings.ReloadTime == 0 and not Walking then 
		print("OnActivated is working.")
		onStart()
		
		local time = 0
		while Walking do
			wait(.2)
			print("Loop is working.")
			time = time + .2
			velocity = (Settings.MaxVelocity  * (time / Settings.FlightTime)) + 3 
			currentThrust.velocity = Vector3.new(0,velocity,0)
			if time > Settings.FlightTime then 
				Deactivate()
			end
		end
		
		onEnd()
	end
end

function Deactivate()
	Walking = false
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Networking Functions / Methods
--------------------------------------------------------------------------------------------------------------------------------------------------------------

Networking.Functions = {
	OnActivation = function(mouse)
		OnActivated(mouse)
	end,
	
	OnDeactivation = function()
		Deactivate()
	end
}

EventHandler.OnServerEvent:connect(function(player,fname,...)
	if fname then
		Networking.Functions[fname](...)
	end
end)

--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Setting up the Tool
--------------------------------------------------------------------------------------------------------------------------------------------------------------

Tool.Equipped:connect(function()
	Equipped = true
	Character = Tool.Parent
end)

Tool.Unequipped:connect(function()
	Equipped = false
	if Walking then
		Deactivate()
	end
end)