local RbxAssetId = "rbxassetid://"
local module = {
	MapName = "Castle Invasion",
	MapCreator = "shloid",
	TeamEnabled = false,
	MusicId = 201535584,
	MapSky = {
		CelestialBodiesShown = true,
		MoonAngularSize = 11,
		SunAngularSize = 21,
		StarCount = 3000,
		
		Moon = "rbxasset://sky/moon.jpg",
		Sun = "rbxasset://sky/sun.jpg",
		
		Back = RbxAssetId..1013844,
		Down = RbxAssetId..1013845,
		Front = RbxAssetId..1013842,
		Left = RbxAssetId..1013843,
		Right = RbxAssetId..1013841,
		Up = RbxAssetId..1013848,
	},
	Lighting = {
		Ambient = Color3.new(84/255, 77/255, 39/255),
		Brightness = .4,
		ColorShift = {
			Top = Color3.new(0,0,0),
			Bottom = Color3.new(0,0,0),
		},
		
		OutdoorAmbient = Color3.new(26/255, 26/255, 26/255),
		ClockTime = 15,
		GeographicLatitude = 41.733,
		
		FogColor = Color3.new(255/255,255/255,255/255),
		FogEnd = 100000,
		FogStart = 0,
	}
}

return module
