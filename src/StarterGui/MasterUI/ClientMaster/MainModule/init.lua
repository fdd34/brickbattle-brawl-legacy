-- // Written by AsetCreator_ii 9.11.2019
-- To fix type the following piece of code in your script whitoit the quotes "local LoadLibrary=require(4339982685)"
local container=script:WaitForChild("LoadLibrary", math.huge)
local RbxGui=container:WaitForChild("RbxGui", math.huge)
local RbxStamper=container:WaitForChild("RbxStamper", math.huge)
local RbxUtility=container:WaitForChild("RbxUtility", math.huge)
return function(Lib)
	if Lib == "RbxGui" then
		return require(RbxGui)
	elseif Lib == "RbxStamper" then
		return require(RbxStamper)
	elseif Lib == "RbxUtility" then
		return require(RbxUtility)
	end
end
																																																											--[[
  _                 _ _    _ _                         __ _     
 | |   ___  __ _ __| | |  (_) |__ _ _ __ _ _ _ _  _   / _(_)_ __
 | |__/ _ \/ _` / _` | |__| | '_ \ '_/ _` | '_| || | |  _| \ \ /
 |____\___/\__,_\__,_|____|_|_.__/_| \__,_|_|  \_, | |_| |_/_\_\
                                               |__/             																																												]]