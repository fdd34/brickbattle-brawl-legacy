while true do
wait()
if script.Parent:findFirstChild("SeatWeld") ~= nil then
while true do
wait()
if script.Parent:findFirstChild("SeatWeld") == nil then
script.Parent.Parent:remove()
end
end
end
end
