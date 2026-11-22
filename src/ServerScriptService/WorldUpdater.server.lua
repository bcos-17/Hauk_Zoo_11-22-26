local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ZooLocations = require(ReplicatedStorage:WaitForChild("ZooLocations"))

local function configureLighting()
	Lighting.Technology = Enum.Technology.Future
	Lighting.ClockTime = 10.5
	Lighting.GeographicLatitude = 40.12 -- Norristown, PA latitude
	Lighting.Brightness = 2.2
	Lighting.Ambient = Color3.fromRGB(115, 125, 115)
	Lighting.OutdoorAmbient = Color3.fromRGB(130, 140, 125)
	Lighting.ShadowSoftness = 0.35

	-- Clear old post-processing effects before re-applying
	for _, child in ipairs(Lighting:GetChildren()) do
		if child:IsA("Atmosphere") or child:IsA("PostEffect") or child:IsA("Sky") then
			child:Destroy()
		end
	end

	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Density = 0.26
	atmosphere.Offset = 0.15
	atmosphere.Color = Color3.fromRGB(215, 228, 220)
	atmosphere.Decay = Color3.fromRGB(185, 200, 190)
	atmosphere.Glare = 0.1
	atmosphere.Haze = 1.2
	atmosphere.Parent = Lighting

	local sunRays = Instance.new("SunRaysEffect")
	sunRays.Intensity = 0.08
	sunRays.Spread = 0.65
	sunRays.Parent = Lighting

	local colorCorrection = Instance.new("ColorCorrectionEffect")
	colorCorrection.Saturation = 0.08
	colorCorrection.Contrast = 0.04
	colorCorrection.TintColor = Color3.fromRGB(252, 255, 250)
	colorCorrection.Parent = Lighting

	local bloom = Instance.new("BloomEffect")
	bloom.Intensity = 0.25
	bloom.Size = 20
	bloom.Threshold = 1.1
	bloom.Parent = Lighting
end

local function makePart(props)
	local p = Instance.new("Part")
	p.Name = props.Name or "ZooPart"
	p.Size = props.Size or Vector3.new(4, 1, 4)
	p.CFrame = props.CFrame or CFrame.new(props.Position or Vector3.zero)
	p.Color = props.Color or Color3.fromRGB(200, 200, 200)
	p.Material = props.Material or Enum.Material.SmoothPlastic
	p.Transparency = props.Transparency or 0
	p.Anchored = true
	p.CanCollide = (props.CanCollide ~= nil) and props.CanCollide or true
	p.Parent = props.Parent
	return p
end

local function addLabelSign(parentPart, titleText, subtitleText)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 35
	gui.Parent = parentPart

	local bg = Instance.new("Frame")
	bg.Size = UDim2.fromScale(1, 1)
	bg.BackgroundColor3 = Color3.fromRGB(245, 248, 246)
	bg.BorderSizePixel = 0
	bg.Parent = gui

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -16, 0.55, 0)
	title.Position = UDim2.new(0, 8, 0.05, 0)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.TextScaled = true
	title.TextColor3 = Color3.fromRGB(55, 85, 65)
	title.Text = titleText
	title.Parent = bg

	local sub = Instance.new("TextLabel")
	sub.Size = UDim2.new(1, -16, 0.35, 0)
	sub.Position = UDim2.new(0, 8, 0.6, 0)
	sub.BackgroundTransparency = 1
	sub.Font = Enum.Font.Gotham
	sub.TextScaled = true
	sub.TextColor3 = Color3.fromRGB(90, 105, 95)
	sub.Text = subtitleText or ""
	sub.Parent = bg
end

local function buildZooWorld()
	-- Remove existing generated world if refreshing
	local existing = Workspace:FindFirstChild("ElmwoodParkZoo_World")
	if existing then
		existing:Destroy()
	end

	local world = Instance.new("Folder")
	world.Name = "ElmwoodParkZoo_World"
	world.Parent = Workspace

	local archFolder = Instance.new("Folder")
	archFolder.Name = "Architecture"
	archFolder.Parent = world

	local waypointsFolder = Instance.new("Folder")
	waypointsFolder.Name = "TourWaypoints"
	waypointsFolder.Parent = world

	local zonesFolder = Instance.new("Folder")
	zonesFolder.Name = "ZoneTriggers"
	zonesFolder.Parent = world

	-- Baseplate (LeafyGrass)
	makePart({
		Name = "ParkGround_800x800",
		Size = ZooLocations.WorldSettings.BaseplateSize,
		Position = ZooLocations.WorldSettings.BaseplateCenter,
		Color = Color3.fromRGB(108, 134, 96),
		Material = Enum.Material.LeafyGrass,
		Parent = archFolder,
	})

	-- =========================================================================
	-- 1. WELCOME CENTER & LOWER COMMISSARY (Two-Story Split Level)
	-- =========================================================================
	-- Lower Commissary Floor (Y = 0)
	makePart({ Name = "Commissary_Floor", Size = Vector3.new(120, 1, 70), Position = Vector3.new(0, 0.5, 40), Color = Color3.fromRGB(215, 220, 222), Material = Enum.Material.Concrete, Parent = archFolder })
	-- Upper Visitor Atrium Floor (Y = 14, leaves opening at Z = 45..68 to overlook Commissary)
	makePart({ Name = "WelcomeCenter_UpperDeck", Size = Vector3.new(120, 1.5, 42), Position = Vector3.new(0, 13.5, 26), Color = Color3.fromRGB(195, 205, 202), Material = Enum.Material.Concrete, Parent = archFolder })
	-- Ramp connecting Exit Courtyard (Y=0, Z=-5) up to Welcome Center Upper Deck (Y=14, Z=6)
	makePart({
		Name = "WelcomeCenter_EntryRamp",
		Size = Vector3.new(22, 1.5, 32),
		CFrame = CFrame.new(0, 7, -6) * CFrame.Angles(math.rad(25), 0, 0),
		Color = Color3.fromRGB(210, 208, 200),
		Material = Enum.Material.Concrete,
		Parent = archFolder,
	})
	-- Commissary Viewing Glass & Safety Railing
	makePart({ Name = "Commissary_GlassWindow", Size = Vector3.new(60, 9, 0.6), Position = Vector3.new(0, 18.5, 47), Color = Color3.fromRGB(185, 225, 240), Material = Enum.Material.Glass, Transparency = 0.55, Parent = archFolder })
	-- Commissary Prep Tables & Diet Board
	makePart({ Name = "Commissary_PrepTable_1", Size = Vector3.new(14, 3.2, 5), Position = Vector3.new(-15, 2.5, 56), Color = Color3.fromRGB(190, 195, 200), Material = Enum.Material.Metal, Parent = archFolder })
	makePart({ Name = "Commissary_PrepTable_2", Size = Vector3.new(14, 3.2, 5), Position = Vector3.new(15, 2.5, 56), Color = Color3.fromRGB(190, 195, 200), Material = Enum.Material.Metal, Parent = archFolder })
	local dietBoard = makePart({ Name = "Commissary_DietBoard", Size = Vector3.new(26, 6, 0.5), Position = Vector3.new(0, 6, 68), Color = Color3.fromRGB(245, 248, 246), Parent = archFolder })
	addLabelSign(dietBoard, "DAILY ANIMAL DIET BOARD", "Ferrets: Whole Prey | Sloth: Squash & Greens | Tortoise: Collards")

	-- Black-Footed Ferret Exhibit (Upper Atrium)
	local ferretGlass = makePart({ Name = "Ferret_Vivarium", Size = Vector3.new(18, 8, 8), Position = Vector3.new(-36, 18, 28), Color = Color3.fromRGB(125, 148, 110), Material = Enum.Material.WoodPlanks, Parent = archFolder })
	addLabelSign(ferretGlass, "BLACK-FOOTED FERRETS", "Saved From Extinction - Mustela nigripes")

	-- =========================================================================
	-- 2. EXIT COURTYARD, FOX PLAZA & HISTORIC RED ARCHWAY
	-- =========================================================================
	makePart({ Name = "FoxEmblem_Plaza", Size = Vector3.new(56, 0.8, 42), Position = Vector3.new(0, 0.4, -26), Color = Color3.fromRGB(218, 212, 200), Material = Enum.Material.Pavement, Parent = archFolder })
	local foxMedallion = Instance.new("Part")
	foxMedallion.Name = "FoxMedallion_Inlay"
	foxMedallion.Shape = Enum.PartType.Cylinder
	foxMedallion.Size = Vector3.new(0.85, 22, 22)
	foxMedallion.CFrame = CFrame.new(0, 0.45, -24) * CFrame.Angles(0, 0, math.rad(90))
	foxMedallion.Color = Color3.fromRGB(186, 115, 88)
	foxMedallion.Material = Enum.Material.SmoothPlastic
	foxMedallion.Anchored = true
	foxMedallion.Parent = archFolder

	-- Historic Red & Gold Archway (Z = -50)
	makePart({ Name = "Arch_Pillar_Left", Size = Vector3.new(3, 16, 3), Position = Vector3.new(-9, 8, -50), Color = Color3.fromRGB(168, 48, 48), Material = Enum.Material.Metal, Parent = archFolder })
	makePart({ Name = "Arch_Pillar_Right", Size = Vector3.new(3, 16, 3), Position = Vector3.new(9, 8, -50), Color = Color3.fromRGB(168, 48, 48), Material = Enum.Material.Metal, Parent = archFolder })
	local archSign = makePart({ Name = "Arch_Banner", Size = Vector3.new(21, 4, 2.5), Position = Vector3.new(0, 17, -50), Color = Color3.fromRGB(168, 48, 48), Material = Enum.Material.Metal, Parent = archFolder })
	addLabelSign(archSign, "ELMWOOD PARK ZOO", "Est. 1924 • Conservation & Education")

	-- =========================================================================
	-- 3. PICNIC GROVE, DRAINAGE GRATE & S-CURVE TRAIL
	-- =========================================================================
	makePart({ Name = "Trail_Connector_North", Size = Vector3.new(14, 0.8, 56), Position = Vector3.new(0, 0.4, -78), Color = Color3.fromRGB(98, 98, 102), Material = Enum.Material.Asphalt, Parent = archFolder })
	makePart({ Name = "Drainage_Grate", Size = Vector3.new(14, 0.85, 2.5), Position = Vector3.new(0, 0.42, -68), Color = Color3.fromRGB(55, 60, 62), Material = Enum.Material.DiamondPlate, Parent = archFolder })
	-- Calle-Mart Picnic Grove
	makePart({ Name = "PicnicGrove_Pad", Size = Vector3.new(34, 0.8, 28), Position = Vector3.new(26, 0.4, -76), Color = Color3.fromRGB(145, 128, 105), Material = Enum.Material.Pebble, Parent = archFolder })
	makePart({ Name = "PicnicGrove_Roof", Size = Vector3.new(36, 1.5, 30), Position = Vector3.new(26, 12, -76), Color = Color3.fromRGB(52, 96, 68), Material = Enum.Material.Metal, Parent = archFolder })
	-- S-Curve connecting down toward Harmony Hideaway
	makePart({ Name = "Trail_SCurve_West", Size = Vector3.new(12, 0.8, 42), CFrame = CFrame.new(-5, 0.4, -122) * CFrame.Angles(0, math.rad(14), 0), Color = Color3.fromRGB(195, 188, 175), Material = Enum.Material.Concrete, Parent = archFolder })
	makePart({ Name = "PrivacyFence_Backstage", Size = Vector3.new(1.5, 11, 44), Position = Vector3.new(-16, 5.5, -118), Color = Color3.fromRGB(138, 114, 86), Material = Enum.Material.WoodPlanks, Parent = archFolder })

	-- =========================================================================
	-- 4. HARMONY HIDEAWAY (Priority Enclosure: Sloth, Tortoise, Pool, Airlock)
	-- =========================================================================
	local hhCenter = Vector3.new(-10, 0, -175)
	makePart({ Name = "HH_Floor", Size = Vector3.new(72, 1, 62), Position = hhCenter + Vector3.new(0, 0.5, 0), Color = Color3.fromRGB(214, 198, 182), Material = Enum.Material.Concrete, Parent = archFolder })
	-- Exterior Board & Batten Walls + Skylight Roof
	makePart({ Name = "HH_Wall_Back", Size = Vector3.new(72, 20, 2), Position = hhCenter + Vector3.new(0, 10, -31), Color = Color3.fromRGB(152, 142, 122), Material = Enum.Material.WoodPlanks, Parent = archFolder })
	makePart({ Name = "HH_Wall_Left", Size = Vector3.new(2, 20, 62), Position = hhCenter + Vector3.new(-36, 10, 0), Color = Color3.fromRGB(152, 142, 122), Material = Enum.Material.WoodPlanks, Parent = archFolder })
	makePart({ Name = "HH_Wall_Right", Size = Vector3.new(2, 20, 62), Position = hhCenter + Vector3.new(36, 10, 0), Color = Color3.fromRGB(152, 142, 122), Material = Enum.Material.WoodPlanks, Parent = archFolder })
	makePart({ Name = "HH_Wall_Front_L", Size = Vector3.new(28, 20, 2), Position = hhCenter + Vector3.new(-22, 10, 31), Color = Color3.fromRGB(152, 142, 122), Material = Enum.Material.WoodPlanks, Parent = archFolder })
	makePart({ Name = "HH_Wall_Front_R", Size = Vector3.new(28, 20, 2), Position = hhCenter + Vector3.new(22, 10, 31), Color = Color3.fromRGB(152, 142, 122), Material = Enum.Material.WoodPlanks, Parent = archFolder })
	-- Skylight Glass Ceiling
	makePart({ Name = "HH_SkylightRoof", Size = Vector3.new(72, 1, 62), Position = hhCenter + Vector3.new(0, 20.5, 0), Color = Color3.fromRGB(220, 238, 232), Material = Enum.Material.Glass, Transparency = 0.45, Parent = archFolder })

	-- Airlock Vestibule & Beaded Bamboo Curtain
	makePart({ Name = "HH_Airlock_Wall_L", Size = Vector3.new(1, 12, 14), Position = hhCenter + Vector3.new(-6, 6, 24), Color = Color3.fromRGB(235, 232, 224), Material = Enum.Material.WoodPlanks, Parent = archFolder })
	makePart({ Name = "HH_Airlock_Wall_R", Size = Vector3.new(1, 12, 14), Position = hhCenter + Vector3.new(6, 6, 24), Color = Color3.fromRGB(235, 232, 224), Material = Enum.Material.WoodPlanks, Parent = archFolder })
	local bambooCurtain = makePart({ Name = "HH_BambooCurtain", Size = Vector3.new(11, 10, 0.4), Position = hhCenter + Vector3.new(0, 5.5, 17), Color = Color3.fromRGB(196, 164, 114), Material = Enum.Material.Wood, Transparency = 0.35, CanCollide = false, Parent = archFolder })
	local hhSign = makePart({ Name = "HH_SlothEntrySign", Size = Vector3.new(8, 10, 1.5), Position = hhCenter + Vector3.new(14, 5, 34), Color = Color3.fromRGB(124, 96, 68), Material = Enum.Material.Wood, Parent = archFolder })
	addLabelSign(hhSign, "HARMONY HIDEAWAY", "A Rainforest of Resources • Walk Gently")

	-- Central Freshwater Wading Pool
	makePart({ Name = "HH_WadingPool", Size = Vector3.new(22, 1.1, 16), Position = hhCenter + Vector3.new(4, 0.6, -2), Color = Color3.fromRGB(95, 155, 165), Material = Enum.Material.Glass, Transparency = 0.25, Parent = archFolder })
	-- Bamboo-Fenced African Spurred Tortoise Corner & Heat Box
	makePart({ Name = "HH_Tortoise_Substrate", Size = Vector3.new(16, 1.2, 16), Position = hhCenter + Vector3.new(-24, 0.6, -18), Color = Color3.fromRGB(112, 86, 62), Material = Enum.Material.Ground, Parent = archFolder })
	local heatBox = makePart({ Name = "HH_Tortoise_HeatBox", Size = Vector3.new(7, 3.5, 5), Position = hhCenter + Vector3.new(-26, 2.8, -21), Color = Color3.fromRGB(210, 188, 145), Material = Enum.Material.WoodPlanks, Parent = archFolder })
	local heatLight = Instance.new("PointLight")
	heatLight.Color = Color3.fromRGB(255, 175, 95)
	heatLight.Range = 14
	heatLight.Brightness = 1.5
	heatLight.Parent = heatBox
	-- Overhead Sloth & Scarlet Ibis Canopy Ropes
	makePart({ Name = "HH_CanopyRope_Main", Size = Vector3.new(42, 0.5, 0.5), CFrame = CFrame.new(hhCenter + Vector3.new(0, 13.5, -4)) * CFrame.Angles(0, math.rad(15), 0), Color = Color3.fromRGB(185, 158, 118), Material = Enum.Material.Fabric, Parent = archFolder })
	makePart({ Name = "HH_CanopyRope_Cross", Size = Vector3.new(0.5, 0.5, 36), CFrame = CFrame.new(hhCenter + Vector3.new(-6, 14.5, -6)) * CFrame.Angles(0, math.rad(-20), 0), Color = Color3.fromRGB(185, 158, 118), Material = Enum.Material.Fabric, Parent = archFolder })

	-- =========================================================================
	-- 5. RETURN BOULEVARD, AVIARY RUNS & STAFF PAVILION
	-- =========================================================================
	-- Connector from Harmony Hideaway to Return Boulevard
	makePart({ Name = "Trail_HH_Connector", Size = Vector3.new(34, 0.8, 12), Position = Vector3.new(22, 0.4, -155), Color = Color3.fromRGB(206, 194, 176), Material = Enum.Material.Pavement, Parent = archFolder })
	-- Main Interlocking Paver Return Boulevard
	makePart({ Name = "NorthAviary_Boulevard", Size = Vector3.new(16, 0.8, 115), Position = Vector3.new(42, 0.4, -100), Color = Color3.fromRGB(206, 194, 176), Material = Enum.Material.Pavement, Parent = archFolder })
	-- Cedar Aviary Flight Enclosures (West side of Boulevard)
	makePart({ Name = "Aviary_FlightRow", Size = Vector3.new(14, 13, 85), Position = Vector3.new(25, 6.5, -102), Color = Color3.fromRGB(122, 96, 70), Material = Enum.Material.WoodPlanks, Parent = archFolder })
	-- Terraced Stone Flower Wall & Historic Red Barn (East side of Boulevard)
	makePart({ Name = "Terraced_StonePlanter", Size = Vector3.new(5, 2.8, 85), Position = Vector3.new(53, 1.4, -102), Color = Color3.fromRGB(135, 126, 118), Material = Enum.Material.Cobblestone, Parent = archFolder })
	makePart({ Name = "Historic_RedBarn", Size = Vector3.new(24, 18, 28), Position = Vector3.new(68, 9, -110), Color = Color3.fromRGB(148, 48, 44), Material = Enum.Material.WoodPlanks, Parent = archFolder })

	-- Clock Tower & Staff Pavilion (Duty Badge Lockers + Conservation Trading Post)
	makePart({ Name = "ClockTower_Post", Size = Vector3.new(3.5, 22, 3.5), Position = Vector3.new(22, 11, -44), Color = Color3.fromRGB(42, 62, 52), Material = Enum.Material.Metal, Parent = archFolder })
	local staffPavilion = makePart({ Name = "Staff_Pavilion", Size = Vector3.new(24, 14, 20), Position = Vector3.new(42, 7, -32), Color = Color3.fromRGB(92, 122, 98), Material = Enum.Material.WoodPlanks, Parent = archFolder })
	addLabelSign(staffPavilion, "STAFF PAVILION & FIELD DEPOT", "Duty Badge Lockers • Conservation Trading Post")

	-- =========================================================================
	-- 6. GENERATE WAYPOINTS & ZONE TRIGGERS FROM ZOOLOCATIONS
	-- =========================================================================
	for zoneKey, data in pairs(ZooLocations.Zones) do
		-- Tour Waypoint Marker
		local wp = makePart({
			Name = string.format("WP_%02d_%s", data.Order, zoneKey),
			Size = Vector3.new(3.5, 0.3, 3.5),
			Position = data.Waypoint,
			Color = Color3.fromRGB(120, 210, 185),
			Material = Enum.Material.Neon,
			Transparency = 0.65,
			CanCollide = false,
			Parent = waypointsFolder,
		})

		-- Invisible Zone Trigger Box (handles Harmony Hideaway calm pacing & HUD updates)
		local trigger = makePart({
			Name = zoneKey,
			Size = data.Size,
			Position = data.Center,
			Transparency = 1,
			CanCollide = false,
			Parent = zonesFolder,
		})

		trigger.Touched:Connect(function(hit)
			local character = hit.Parent
			local player = Players:GetPlayerFromCharacter(character)
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if player and humanoid then
				local targetSpeed = data.WalkSpeedOverride or player:GetAttribute("PreferredPace") or ZooLocations.WorldSettings.DefaultWalkSpeed
				if humanoid.WalkSpeed ~= targetSpeed then
					humanoid.WalkSpeed = targetSpeed
				end
				if player:GetAttribute("CurrentZone") ~= data.DisplayName then
					player:SetAttribute("CurrentZone", data.DisplayName)
				end
			end
		end)
	end

	print("[Elmwood Park Zoo] World built successfully with " .. #waypointsFolder:GetChildren() .. " waypoints.")
end

-- Expose live refresh function for Roblox Studio Command Bar
_G.RefreshZoo = function()
	configureLighting()
	buildZooWorld()
end

-- Initial build on server start
_G.RefreshZoo()
