-- Read the Documentation for more information about this.

local RbxAssetId = "rbxassetid://"
local module = {
	MapName = "Defrost",
	MapCreator = "shayne024",
	TeamEnabled = false,
	MusicId = 1008483331,
	MapSky = {
		CelestialBodiesShown = true,
		MoonAngularSize = 11,
		SunAngularSize = 21,
		StarCount = 3000,
		
		Moon = "rbxasset://sky/moon.jpg",
		Sun = "rbxasset://sky/sun.jpg",
		
		Back = RbxAssetId..155657655,
		Down = RbxAssetId..155674246,
		Front = RbxAssetId..155657609,
		Left = RbxAssetId..155657671,
		Right = RbxAssetId..155657619,
		Up = RbxAssetId..155674931,
	},
	Lighting = {
		Ambient = Color3.new(0/255, 0/255, 0/255),
		Brightness = 1,
		ColorShift = {
			Top = Color3.new(0,0,0),
			Bottom = Color3.new(0,0,0),
		},
		
		OutdoorAmbient = Color3.new(180/255, 180/255, 180/255),
		ClockTime = 18.167,
		GeographicLatitude = 41.733,
		
		FogColor = Color3.new(225/255, 225/255, 225/255),
		FogEnd = 250,
		FogStart = 0,
	}
}

return module
