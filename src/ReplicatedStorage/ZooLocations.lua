local ZooLocations = {}

ZooLocations.WorldSettings = {
	BaseplateSize = Vector3.new(800, 1, 800),
	BaseplateCenter = Vector3.new(0, -0.5, -100),
	DefaultWalkSpeed = 14, -- Gentle default
}

ZooLocations.Zones = {
	WelcomeCenter = {
		Order = 1,
		DisplayName = "Veterinary Health & Welcome Center",
		Center = Vector3.new(0, 14, 40),
		Size = Vector3.new(120, 28, 70),
		Waypoint = Vector3.new(0, 15, 25),
		WalkSpeedOverride = nil,
		Species = "Black-Footed Ferret",
		WoodyQuote = "Hoo-ray! Welcome to the Veterinary Health & Welcome Center. Look through the glass to see our Black-Footed Ferrets—one of North America's greatest conservation comebacks!",
		EncyclopediaFact = "Every living black-footed ferret today descends from a small wild population rescued in Wyoming.",
	},
	CommissaryOverview = {
		Order = 2,
		DisplayName = "Animal Nutrition Commissary",
		Center = Vector3.new(0, 4, 52),
		Size = Vector3.new(80, 12, 35),
		Waypoint = Vector3.new(0, 15, 42),
		WalkSpeedOverride = nil,
		Species = "Nutrition & Diet Prep",
		WoodyQuote = "Peek over the railing! Down below, keepers weigh and prep custom bowls of greens, insects, and browse for every animal in the park.",
		EncyclopediaFact = "Each animal's daily diet is measured to the gram on the commissary wall boards to match seasonal metabolic needs.",
	},
	ExitCourtyardAndArch = {
		Order = 3,
		DisplayName = "Exit Courtyard & Historic Arch",
		Center = Vector3.new(0, 0, -25),
		Size = Vector3.new(65, 18, 55),
		Waypoint = Vector3.new(0, 1.5, -50),
		WalkSpeedOverride = nil,
		Species = "Pollinator Garden",
		WoodyQuote = "Step across the fox-emblem plaza and under the historic red archway! Notice the native hibiscus and salvia feeding local pollinators.",
		EncyclopediaFact = "Elmwood Park Zoo was founded in 1924 and plants native Pennsylvania perennials to support monarch butterflies and native bees.",
	},
	PicnicGroveTrail = {
		Order = 4,
		DisplayName = "Calle-Mart Picnic Grove & S-Curve Trail",
		Center = Vector3.new(0, -1, -85),
		Size = Vector3.new(70, 16, 60),
		Waypoint = Vector3.new(0, 0.5, -85),
		WalkSpeedOverride = nil,
		Species = "Barnyard & Paddock",
		WoodyQuote = "Follow the shaded S-curve down past the green-roofed picnic pavilion. Take your time—there is never a rush on the trail.",
		EncyclopediaFact = "Shaded woodland trails keep temperatures cool for both visitors and hoofstock during warm Pennsylvania summers.",
	},
	HarmonyHideaway = {
		Order = 5,
		DisplayName = "Harmony Hideaway",
		Center = Vector3.new(-10, 0, -175),
		Size = Vector3.new(74, 22, 64),
		Waypoint = Vector3.new(-10, 1.5, -165),
		WalkSpeedOverride = 10, -- Automatic therapeutic calm pacing inside the rainforest
		Species = "Linnaeus's Two-Toed Sloth & African Spurred Tortoise",
		WoodyQuote = "Pass gently through the airlock and bamboo curtain. Look up at the overhead ropes for Liana the sloth and Scarlet Ibis, and down by the heat box for our Sulcata tortoise!",
		EncyclopediaFact = "Two-toed sloths move slowly to conserve energy, resting up to 20 hours a day, while tortoises use warm basking spots to aid digestion.",
	},
	NorthAviaryBoulevard = {
		Order = 6,
		DisplayName = "North Aviary Boulevard & Terraced Gardens",
		Center = Vector3.new(42, 0, -115),
		Size = Vector3.new(40, 18, 115),
		Waypoint = Vector3.new(42, 1.5, -115),
		WalkSpeedOverride = nil,
		Species = "Ambassador Raptors & Songbirds",
		WoodyQuote = "Stroll up the interlocking paver boulevard between the cedar aviary flights and terraced stone flower beds.",
		EncyclopediaFact = "Ambassador birds participate voluntarily in glove and target-stick training using positive reinforcement.",
	},
	ClockTowerAndStaffPavilion = {
		Order = 7,
		DisplayName = "Clock Tower Courtyard & Staff Pavilion",
		Center = Vector3.new(25, 0, -42),
		Size = Vector3.new(45, 24, 40),
		Waypoint = Vector3.new(22, 1.5, -42),
		WalkSpeedOverride = nil,
		Species = "Conservation Trading Post & Duty Lockers",
		WoodyQuote = "Full circle! Visit the Staff Pavilion lockers to swap Duty Badges, or stop by the Conservation Trading Post to stamp your Keeper Passbook.",
		EncyclopediaFact = "Every badge you unlock stays in your career toolbox forever—switch roles anytime to help around the zoo.",
	},
}

return ZooLocations
