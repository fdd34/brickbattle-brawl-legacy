local trampoline = script.Parent
local bounceSpeed = 200
trampoline.Velocity = Vector3.new(0, bounceSpeed, 0)
script:Destroy()