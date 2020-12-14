local RbxAssetId = "rbxassetid://"
local module = {
	MapName = "Mountain Village",
	MapCreator = "FranklinEinstein",
	TeamEnabled = false,
	MusicId = 1372262,
	MapSky = {
		CelestialBodiesShown = true,
		MoonAngularSize = 11,
		SunAngularSize = 21,
		StarCount = 3000,
		
		Moon = "rbxasset://sky/moon.jpg",
		Sun = "rbxasset://sky/sun.jpg",
		
		Back = RbxAssetId..1013852,
		Down = RbxAssetId..1013853,
		Front = RbxAssetId..1013850,
		Left = RbxAssetId..1013851,
		Right = RbxAssetId..1013849,
		Up = RbxAssetId..1013854,
	},
	Lighting = {
		Ambient = Color3.new(97/255, 94/255, 86/255),
		Brightness = .6,
		ColorShift = {
			Top = Color3.new(0,0,0),
			Bottom = Color3.new(0,0,0),
		},
		
		OutdoorAmbient = Color3.new(83/255,83/255,83/255),
		ClockTime = 8,
		GeographicLatitude = 41.733,
		
		FogColor = Color3.new(255/255,255/255,255/255),
		FogEnd = 100000,
		FogStart = 0,
	}
}

return module
