local RbxAssetId = "rbxassetid://"
local module = {
	MapName = "Snapper Canal",
	MapCreator = "shayne024",
	TeamEnabled = false,
	MusicId = 1092814049,
	MapSky = {
		CelestialBodiesShown = true,
		MoonAngularSize = 11,
		SunAngularSize = 21,
		StarCount = 3000,
		
		Moon = "rbxasset://sky/moon.jpg",
		Sun = "rbxasset://sky/sun.jpg",
		
		Back = RbxAssetId..591058823,
		Down = RbxAssetId..591059876,
		Front = RbxAssetId..591058104,
		Left = RbxAssetId..591057861,
		Right = RbxAssetId..591057625,
		Up = RbxAssetId..591059642,
	},
	Lighting = {
		Ambient = Color3.new(165/255, 176/255, 188/255),
		Brightness = .8,
		ColorShift = {
			Top = Color3.new(0,0,0),
			Bottom = Color3.new(0,0,0),
		},
		
		OutdoorAmbient = Color3.new(180/255, 180/255, 180/255),
		ClockTime = 13,
		GeographicLatitude = 41.733,
		
		FogColor = Color3.new(255/255,255/255,255/255),
		FogEnd = 100000,
		FogStart = 0,
	}
}

return module
