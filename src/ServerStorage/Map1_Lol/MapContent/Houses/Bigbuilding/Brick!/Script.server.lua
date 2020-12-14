function mode1()
--good flashing
script.Parent.Color = randval1 --Color3.new(math.random(), math.random(), math.random()) 
wait(0.5)
script.Parent.Color = randval3 --Color3.new(math.random(), math.random(), math.random()) 
wait(0.5)
script.Parent.Color = randval1 --Color3.new(math.random(), math.random(), math.random()) 
wait(0.5)
script.Parent.Color = randval3 --Color3.new(math.random(), math.random(), math.random()) 
wait(0.5)
script.Parent.Color = randval1 --Color3.new(math.random(), math.random(), math.random()) 
wait(0.5)
script.Parent.Color = randval3 --Color3.new(math.random(), math.random(), math.random()) 
wait(0.5)
script.Parent.Color = randval2 --Color3.new(math.random(), math.random(), math.random()) 
wait(0.5)
script.Parent.Color = randval4 --Color3.new(math.random(), math.random(), math.random()) 
wait(0.5)
script.Parent.Color = randval2 --Color3.new(math.random(), math.random(), math.random()) 
wait(0.5)
script.Parent.Color = randval4 --Color3.new(math.random(), math.random(), math.random()) 
wait(0.5)
script.Parent.Color = randval2 --Color3.new(math.random(), math.random(), math.random()) 
wait(0.5)
script.Parent.Color = randval4 --Color3.new(math.random(), math.random(), math.random()) 
wait(0.5)
script.Parent.Color = randval5 --Color3.new(math.random(), math.random(), math.random()) 
wait(0.5)
script.Parent.Color = randval6 --Color3.new(math.random(), math.random(), math.random()) 
wait(0.5)
script.Parent.Color = randval5 --Color3.new(math.random(), math.random(), math.random()) 
wait(0.5)
script.Parent.Color = randval6 --Color3.new(math.random(), math.random(), math.random()) 
wait(0.5)
script.Parent.Color = randval5 --Color3.new(math.random(), math.random(), math.random()) 
wait(0.5)
script.Parent.Color = randval6 --Color3.new(math.random(), math.random(), math.random()) 
wait(0.5)
mode1()
end

function mode2()
--slow transitions, looks slick
script.Parent.Color = Color3.new(1,0,0) --Color3.new(math.random(), math.random(), math.random()) 
wait(0.2)
script.Parent.Color = Color3.new(.8,.2,0) --Color3.new(math.random(), math.random(), math.random()) 
wait(0.2)
script.Parent.Color = Color3.new(.6,.4,0) --Color3.new(math.random(), math.random(), math.random()) 
wait(0.2)
script.Parent.Color = Color3.new(.4,.6,0) --Color3.new(math.random(), math.random(), math.random()) 
wait(0.2)
script.Parent.Color = Color3.new(.2,.8,0) --Color3.new(math.random(), math.random(), math.random()) 
wait(0.2)
script.Parent.Color = Color3.new(0,1,0) --Color3.new(math.random(), math.random(), math.random()) 
wait(0.2)
script.Parent.Color = Color3.new(0,0.8,.2) --Color3.new(math.random(), math.random(), math.random()) 
wait(0.2)
script.Parent.Color = Color3.new(0,0.6,.4) --Color3.new(math.random(), math.random(), math.random()) 
wait(0.2)
script.Parent.Color = Color3.new(0,0.4,.6) --Color3.new(math.random(), math.random(), math.random()) 
wait(0.2)
script.Parent.Color = Color3.new(0,0.2,.8) --Color3.new(math.random(), math.random(), math.random()) 
wait(0.2)
script.Parent.Color = Color3.new(0,0,1) --Color3.new(math.random(), math.random(), math.random()) 
wait(0.2)
script.Parent.Color = Color3.new(.2,0,.8) --Color3.new(math.random(), math.random(), math.random()) 
wait(0.2)
script.Parent.Color = Color3.new(.4,0,.6) --Color3.new(math.random(), math.random(), math.random()) 
wait(0.2)
script.Parent.Color = Color3.new(.6,0,.4) --Color3.new(math.random(), math.random(), math.random()) 
wait(0.2)
script.Parent.Color = Color3.new(.8,0,.2) --Color3.new(math.random(), math.random(), math.random()) 
wait(0.2)
mode2()
end

function mode3()
--v fast
script.Parent.Color = Color3.new(math.random(),math.random(),math.random())
wait(0.1)
mode3()
end

function mode4()
--fast
script.Parent.Color = Color3.new(math.random(),math.random(),math.random())
wait(1)
mode4()
end

function mode5()
--reg
script.Parent.Color = Color3.new(math.random(),math.random(),math.random())
wait(1)
mode5()
end

function mode6()
--slow
script.Parent.Color = Color3.new(math.random(),math.random(),math.random())
wait(5)
mode6()
end

function mode7()
--slowest
-- ONLY ONE MODE AT A TIME, LOLOLOLOL
script.Parent.Color = Color3.new(math.random(),math.random(),math.random())
wait(10)
mode7()
end

function mode8()
--blacknwhite
script.Parent.Color = randval7 --Color3.new(math.random(), math.random(), math.random()) 
wait(0.5)
script.Parent.Color = randval8 --Color3.new(math.random(), math.random(), math.random()) 
wait(0.5)
mode8()
end

function mode9()
--redgreen -xmas
script.Parent.Color = randval2 --Color3.new(math.random(), math.random(), math.random()) 
wait(0.5)
script.Parent.Color = randval1 --Color3.new(math.random(), math.random(), math.random()) 
wait(0.5)
mode9()
end

function mode10()
--ice
script.Parent.Color = randval6 --Color3.new(math.random(), math.random(), math.random()) 
wait(0.5)
script.Parent.Color = randval7 --Color3.new(math.random(), math.random(), math.random()) 
wait(0.5)
mode10()
end

while true do 
randval1 = Color3.new(1,0,0) --Red
randval2 = Color3.new(0,1,0) --Green
randval3 = Color3.new(0,0,1) --Blue
randval4 = Color3.new(1,1,0) --yellow
randval5 = Color3.new(1,0,1) --mag
randval6 = Color3.new(0,1,1) --cyn
randval7 = Color3.new(1,1,1) --white
randval8 = Color3.new(0,0,0) --blk

mode9()
end 