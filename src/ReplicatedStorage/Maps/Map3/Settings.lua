local RbxAssetId = "rbxassetid://"
local module = {
	MapName = "Skyline",
	MapCreator = "shayne024",
	MusicId = 1071911495,
	TeamEnabled = false,
	MapSky = {
		CelestialBodiesShown = true,
		MoonAngularSize = 11,
		SunAngularSize = 21,
		StarCount = 3000,
		
		Moon = "rbxasset://sky/moon.jpg",
		Sun = "rbxasset://sky/sun.jpg",
		
		Back = RbxAssetId..1014350,
		Down = RbxAssetId..1014351,
		Front = RbxAssetId..1014348,
		Left = RbxAssetId..1014349,
		Right = RbxAssetId..1014347,
		Up = RbxAssetId..1014352,
	},
	Lighting = {
		Ambient = Color3.new(79/255, 71/255, 58/255),
		Brightness = .85,
		ColorShift = {
			Top = Color3.new(0,0,0),
			Bottom = Color3.new(0,0,0),
		},
		
		OutdoorAmbient = Color3.new(67/255, 67/255, 67/255),
		ClockTime = 8,
		GeographicLatitude = 41.733,
		
		FogColor = Color3.new(255/255,255/255,255/255),
		FogEnd = 100000,
		FogStart = 0,
	}
}

return module
