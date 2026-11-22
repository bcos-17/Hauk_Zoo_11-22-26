local GameConfig = {}

GameConfig.SeasonDurationSeconds = 900 -- 15 minutes per season (1 hour = 1 in-game year)
GameConfig.Seasons = { "Spring", "Summer", "Autumn", "Winter" }

GameConfig.PaceModes = {
	{ Name = "Gentle", Speed = 14 },
	{ Name = "Brisk", Speed = 22 },
	{ Name = "Express", Speed = 28 },
}

GameConfig.CareerYears = {
	[1] = {
		RoleName = "Guest Engagement & Tour Volunteer",
		BadgeId = "Badge_Year1_Tour",
		GiftName = "Carousel Ticket",
		GiftPerk = "Unlimited free rides on the Elmwood Carousel",
		Description = "Lead peaceful walking tours and gently reunite wandering field trip students.",
	},
	[2] = {
		RoleName = "Park Stewardship & Habitat Facilities",
		BadgeId = "Badge_Year2_Stewardship",
		GiftName = "Barrel Train Pass",
		GiftPerk = "Unlimited rides on the Park Barrel Train",
		Description = "Maintain crystal-clear water filters, algae screens, and seasonal trough heaters.",
	},
	[3] = {
		RoleName = "Commissary & Botanical Nutrition",
		BadgeId = "Badge_Year3_Commissary",
		GiftName = "Snack Voucher",
		GiftPerk = "Free treats at the Conservation Field Depot",
		Description = "Weigh fresh browse, prepare measured animal bowls, and craft summer ice treats.",
	},
	[4] = {
		RoleName = "Community Educator & Workshops",
		BadgeId = "Badge_Year4_Educator",
		GiftName = "Giraffe Browse Branch",
		GiftPerk = "Anytime romaine & browse feeding access at the Giraffe Deck",
		Description = "Host Zoo-at-Home terrarium, bird-tracking, and enrichment workshops.",
	},
	[5] = {
		RoleName = "Behavioral Husbandry & Training Specialist",
		BadgeId = "Badge_Year5_Husbandry",
		GiftName = "Behind-the-Scenes Pass",
		GiftPerk = "Access to Harmony Hideaway & Jaguar backstage care decks",
		Description = "Practice positive-reinforcement target training as either Keeper or Animal.",
	},
	[6] = {
		RoleName = "Conservation Ambassador & Habitat Curator",
		BadgeId = "Badge_Year6_Curator",
		GiftName = "Golden Master Key",
		GiftPerk = "Electric Golf Cart access & panoramic canopy overlooks",
		Description = "Curate natural habitats and mentor new Year 1 volunteers.",
	},
}

GameConfig.Encyclopedia = {
	BlackFootedFerret = {
		CommonName = "Black-Footed Ferret",
		ScientificName = "Mustela nigripes",
		Zone = "Welcome Center",
		Diet = "Whole prey & specialized carnivore mix",
		ConservationStatus = "Endangered (Recovery Success)",
		Fact = "Every living black-footed ferret today descends from a small wild population rescued in Wyoming.",
		TrainingCues = { "Tunnel Check", "Scale Station" },
	},
	TwoToedSloth = {
		CommonName = "Linnaeus's Two-Toed Sloth (Liana)",
		ScientificName = "Choloepus didactylus",
		Zone = "Harmony Hideaway",
		Diet = "Cooked sweet potatoes, squash, leafy greens",
		ConservationStatus = "Least Concern",
		Fact = "Two-toed sloths move slowly to conserve metabolic energy, resting up to 20 hours a day.",
		TrainingCues = { "Target Pole Touch", "Limb Presentation" },
	},
	AfricanSpurredTortoise = {
		CommonName = "African Spurred Tortoise",
		ScientificName = "Centrochelys sulcata",
		Zone = "Harmony Hideaway",
		Diet = "High-fiber grasses, collard greens, squash",
		ConservationStatus = "Endangered",
		Fact = "Sulcata tortoises rely on warm basking zones to regulate their body temperature and digestion.",
		TrainingCues = { "Heat Box Station", "Shell Inspection" },
	},
	ScarletIbis = {
		CommonName = "Scarlet Ibis",
		ScientificName = "Eudocimus ruber",
		Zone = "Harmony Hideaway",
		Diet = "Crustacean-rich pellet blend",
		ConservationStatus = "Least Concern",
		Fact = "Their brilliant crimson feathers come from natural carotenoid pigments found in the crustaceans they eat.",
		TrainingCues = { "Perch Hop", "Voluntary Weigh-In" },
	},
	ReticulatedGiraffe = {
		CommonName = "Reticulated Giraffe (Gerald & Dhourba)",
		ScientificName = "Giraffa camelopardalis reticulata",
		Zone = "Giraffe Feeding Deck",
		Diet = "Romaine lettuce, willow & acacia browse",
		ConservationStatus = "Endangered",
		Fact = "Giraffes have prehensile blue-black tongues up to 18 inches long that protect against sunburn while browsing.",
		TrainingCues = { "Deck Stationing", "Hoof Presentation" },
	},
	Jaguar = {
		CommonName = "Jaguar",
		ScientificName = "Panthera onca",
		Zone = "Trail of the Jaguar",
		Diet = "Lean carnivore diet & enrichment ice treats",
		ConservationStatus = "Near Threatened",
		Fact = "Unlike most big cats, jaguars are strong swimmers that actively enjoy soaking in water pools.",
		TrainingCues = { "Target Stick Touch", "Open Mouth Check" },
	},
}

return GameConfig
