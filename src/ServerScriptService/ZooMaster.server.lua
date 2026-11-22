local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local ZooLocations = require(ReplicatedStorage:WaitForChild("ZooLocations"))

local PlayerStore = DataStoreService:GetDataStore("EPZ_Simulator_v1")

-- Create Remotes Folder cleanly
local Remotes = ReplicatedStorage:FindFirstChild("ZooRemotes") or Instance.new("Folder")
Remotes.Name = "ZooRemotes"
Remotes.Parent = ReplicatedStorage

local function getOrCreateRemote(className, name)
	local r = Remotes:FindFirstChild(name) or Instance.new(className)
	r.Name = name
	r.Parent = Remotes
	return r
end

local SyncProfileEvent = getOrCreateRemote("RemoteEvent", "SyncProfile")
local UnlockSpeciesEvent = getOrCreateRemote("RemoteEvent", "UnlockSpecies")
local CompleteTaskEvent = getOrCreateRemote("RemoteEvent", "CompleteTask")
local SwapBadgeEvent = getOrCreateRemote("RemoteEvent", "SwapBadge")
local RedeemGiftEvent = getOrCreateRemote("RemoteEvent", "RedeemGift")
local SeasonChangedEvent = getOrCreateRemote("RemoteEvent", "SeasonChanged")
local TrainingModeEvent = getOrCreateRemote("RemoteEvent", "TrainingMode")
local AskWoodyFunction = getOrCreateRemote("RemoteFunction", "AskWoodyFunction")

-- Global World State
local CurrentSeasonIndex = 1
local CurrentGameYear = 1
local PlayerProfiles = {}
local WoodyCooldowns = {}

local function defaultProfile()
	return {
		UnlockedYear = 1,
		ActiveYearRole = 1,
		CompletedTasksCount = 0,
		Encyclopedia = {}, -- [SpeciesKey] = true
		StampedGifts = {}, -- [YearNumber] = true
	}
end

local function loadProfile(player)
	local key = "Player_" .. player.UserId
	local success, data = pcall(function()
		return PlayerStore:GetAsync(key)
	end)
	if success and type(data) == "table" then
		return data
	end
	return defaultProfile()
end

local function saveProfile(player)
	local profile = PlayerProfiles[player.UserId]
	if not profile then return end
	local key = "Player_" .. player.UserId
	pcall(function()
		PlayerStore:SetAsync(key, profile)
	end)
end

-- Expose helper for other server scripts (Tasks, Field Trips, Training)
_G.EPZ_AwardProgress = function(player, speciesKey, taskName)
	local profile = PlayerProfiles[player.UserId]
	if not profile then return end

	if speciesKey and GameConfig.Encyclopedia[speciesKey] and not profile.Encyclopedia[speciesKey] then
		profile.Encyclopedia[speciesKey] = true
		UnlockSpeciesEvent:FireClient(player, speciesKey, GameConfig.Encyclopedia[speciesKey])
	end

	if taskName then
		profile.CompletedTasksCount += 1
		-- Advance career year calmly every 3 completed activities (up to Year 6)
		local targetYear = math.min(6, 1 + math.floor(profile.CompletedTasksCount / 3))
		if targetYear > profile.UnlockedYear then
			profile.UnlockedYear = targetYear
			profile.ActiveYearRole = targetYear
		end
	end

	SyncProfileEvent:FireClient(player, profile, GameConfig.Seasons[CurrentSeasonIndex], CurrentGameYear)
end

-- Client Requests
SwapBadgeEvent.OnServerEvent:Connect(function(player, requestedYear)
	local profile = PlayerProfiles[player.UserId]
	if profile and type(requestedYear) == "number" and requestedYear >= 1 and requestedYear <= profile.UnlockedYear then
		profile.ActiveYearRole = requestedYear
		SyncProfileEvent:FireClient(player, profile, GameConfig.Seasons[CurrentSeasonIndex], CurrentGameYear)
	end
end)

RedeemGiftEvent.OnServerEvent:Connect(function(player, yearNum)
	local profile = PlayerProfiles[player.UserId]
	if profile and type(yearNum) == "number" and yearNum <= profile.UnlockedYear then
		profile.StampedGifts[yearNum] = true
		SyncProfileEvent:FireClient(player, profile, GameConfig.Seasons[CurrentSeasonIndex], CurrentGameYear)
	end
end)

-- Ask Woody the Owl (Filtered & Rate-Limited)
AskWoodyFunction.OnServerInvoke = function(player, rawQuestion)
	if type(rawQuestion) ~= "string" or #rawQuestion == 0 then
		return "Hoo! Ask me anything about the animals or trails at Elmwood Park Zoo."
	end

	local now = os.clock()
	if WoodyCooldowns[player.UserId] and (now - WoodyCooldowns[player.UserId]) < 12 then
		return "Give my feathers a quick moment to rest! Ask me another question in a few seconds."
	end
	WoodyCooldowns[player.UserId] = now

	-- Filter incoming text via Roblox TextService
	local filteredText = rawQuestion:sub(1, 180)
	local ok, result = pcall(function()
		local filterObj = TextService:FilterStringAsync(filteredText, player.UserId)
		return filterObj:GetNonChatStringForBroadcastAsync()
	end)
	if ok and result then
		filteredText = result
	end

	-- Built-in fallback knowledge base (works immediately without external API keys; swap in HttpService endpoint if desired)
	local q = string.lower(filteredText)
	if string.find(q, "sloth") or string.find(q, "liana") or string.find(q, "harmony") then
		return "Liana our Linnaeus's Two-Toed Sloth lives in Harmony Hideaway! She moves slowly to save energy and loves cooked sweet potatoes and squash."
	elseif string.find(q, "ferret") or string.find(q, "commissary") then
		return "Our Black-Footed Ferrets live in the Welcome Center! Every living ferret today descends from a tiny wild group rescued in Wyoming."
	elseif string.find(q, "tortoise") or string.find(q, "sulcata") then
		return "Our African Spurred Tortoise loves basking under the warm heat box in Harmony Hideaway to help digest leafy greens!"
	elseif string.find(q, "giraffe") then
		return "Gerald and Dhourba use their 18-inch blue-black tongues to gently pluck romaine lettuce leaves right from visitors' hands!"
	else
		return "Hoo-ray! Take your time strolling the loop—visit Harmony Hideaway, check the Commissary diets, or press C anytime to relax!"
	end
end

-- Player Lifecycle
Players.PlayerAdded:Connect(function(player)
	local profile = loadProfile(player)
	PlayerProfiles[player.UserId] = profile
	player:SetAttribute("PreferredPace", ZooLocations.WorldSettings.DefaultWalkSpeed)

	task.delay(1.5, function()
		if player.Parent then
			SyncProfileEvent:FireClient(player, profile, GameConfig.Seasons[CurrentSeasonIndex], CurrentGameYear)
		end
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	saveProfile(player)
	PlayerProfiles[player.UserId] = nil
	WoodyCooldowns[player.UserId] = nil
end)

-- 15-Minute Season Loop (1 Hour = 1 Full Year)
task.spawn(function()
	while true do
		task.wait(GameConfig.SeasonDurationSeconds)
		CurrentSeasonIndex += 1
		if CurrentSeasonIndex > #GameConfig.Seasons then
			CurrentSeasonIndex = 1
			CurrentGameYear += 1
		end
		SeasonChangedEvent:FireAllClients(GameConfig.Seasons[CurrentSeasonIndex], CurrentGameYear)
	end
end)
