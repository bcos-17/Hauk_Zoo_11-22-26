local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("ZooRemotes")
local TrainingModeEvent = Remotes:WaitForChild("TrainingMode")

local function attachPrompt(part, actionText, objectText, holdDuration, callback)
	if not part then return end
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = actionText
	prompt.ObjectText = objectText
	prompt.HoldDuration = holdDuration or 1.2
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = part

	prompt.Triggered:Connect(function(player)
		callback(player, prompt)
	end)
	return prompt
end

-- Wait for WorldUpdater to finish building ElmwoodParkZoo_World
local world = Workspace:WaitForChild("ElmwoodParkZoo_World", 15)
if not world then return end
local arch = world:WaitForChild("Architecture")

-- =========================================================================
-- 1. ENCYCLOPEDIA OBSERVATION PROMPTS (Calm Exploration)
-- =========================================================================
attachPrompt(arch:FindFirstChild("Ferret_Vivarium"), "Observe Ferrets", "Black-Footed Ferret Habitat", 0.5, function(player)
	if _G.EPZ_AwardProgress then
		_G.EPZ_AwardProgress(player, "BlackFootedFerret", nil)
	end
end)

attachPrompt(arch:FindFirstChild("HH_Tortoise_HeatBox"), "Observe Tortoise", "African Spurred Tortoise", 0.5, function(player)
	if _G.EPZ_AwardProgress then
		_G.EPZ_AwardProgress(player, "AfricanSpurredTortoise", nil)
	end
end)

-- =========================================================================
-- 2. YEAR 2 VERTICAL SLICE: POOL FILTER MAINTENANCE (3-Step Rhythmic Loop)
-- =========================================================================
local filterStep = 1
local filterSteps = {
	{ Action = "Pull Filter Sponge", NextAction = "Rinse Sponge in Clean Basin" },
	{ Action = "Rinse Sponge in Clean Basin", NextAction = "Seat Clean Filter Sponge" },
	{ Action = "Seat Clean Filter Sponge", NextAction = "Pull Filter Sponge" },
}

attachPrompt(arch:FindFirstChild("HH_WadingPool"), filterSteps[1].Action, "Harmony Hideaway Pool Filter", 1.5, function(player, prompt)
	local current = filterSteps[filterStep]
	prompt.ActionText = current.NextAction

	if filterStep == 3 then
		filterStep = 1
		if _G.EPZ_AwardProgress then
			_G.EPZ_AwardProgress(player, "ScarletIbis", "PoolFilterMaintenance")
		end
	else
		filterStep += 1
	end
end)

-- =========================================================================
-- 3. YEAR 3: COMMISSARY DIET BOWL PREP
-- =========================================================================
attachPrompt(arch:FindFirstChild("Commissary_PrepTable_1"), "Weigh & Prep Squash Bowls", "Animal Nutrition Commissary", 1.5, function(player)
	if _G.EPZ_AwardProgress then
		_G.EPZ_AwardProgress(player, "TwoToedSloth", "CommissaryBowlPrep")
	end
end)

-- =========================================================================
-- 4. YEAR 5 / STAGE 3: DUAL-ROLE SLOTH TRAINING (Keeper vs. Animal Empathy)
-- =========================================================================
local canopyRope = arch:FindFirstChild("HH_CanopyRope_Main")
if canopyRope then
	-- Create a simple stylized Sloth Rig on the overhead canopy rope
	local slothModel = Instance.new("Model")
	slothModel.Name = "Liana_TwoToedSloth"

	local slothRoot = Instance.new("Part")
	slothRoot.Name = "HumanoidRootPart"
	slothRoot.Size = Vector3.new(2.2, 1.6, 2.8)
	slothRoot.CFrame = canopyRope.CFrame * CFrame.new(-8, -1.2, 0)
	slothRoot.Color = Color3.fromRGB(135, 118, 98)
	slothRoot.Material = Enum.Material.SmoothPlastic
	slothRoot.Anchored = true
	slothRoot.Parent = slothModel

	local targetMarker = Instance.new("Part")
	targetMarker.Name = "TargetPoleCue"
	targetMarker.Shape = Enum.PartType.Ball
	targetMarker.Size = Vector3.new(1.5, 1.5, 1.5)
	targetMarker.CFrame = canopyRope.CFrame * CFrame.new(8, -1.2, 0)
	targetMarker.Color = Color3.fromRGB(145, 215, 175)
	targetMarker.Material = Enum.Material.Neon
	targetMarker.Anchored = true
	targetMarker.CanCollide = false
	targetMarker.Parent = slothModel

	slothModel.PrimaryPart = slothRoot
	slothModel.Parent = world

	-- Keeper Mode Prompt (From Floor Below)
	local trainStation = Instance.new("Part")
	trainStation.Name = "HH_TrainingStation"
	trainStation.Size = Vector3.new(4, 1, 4)
	trainStation.Position = Vector3.new(canopyRope.Position.X, 1, canopyRope.Position.Z + 6)
	trainStation.Color = Color3.fromRGB(175, 205, 185)
	trainStation.Material = Enum.Material.SmoothPlastic
	trainStation.Anchored = true
	trainStation.Parent = arch

	attachPrompt(trainStation, "Train as Keeper (Target Cue)", "Liana Positive Reinforcement", 1.0, function(player)
		-- Smoothly glide Liana toward the target marker and reward
		local startCF = slothRoot.CFrame
		local goalCF = targetMarker.CFrame
		for alpha = 0, 1, 0.05 do
			slothRoot.CFrame = startCF:Lerp(goalCF, alpha)
			task.wait(0.05)
		end
		task.wait(1)
		slothRoot.CFrame = startCF
		if _G.EPZ_AwardProgress then
			_G.EPZ_AwardProgress(player, "TwoToedSloth", "KeeperTargetTraining")
		end
	end)

	-- Animal Empathy Mode Prompt (Switch perspective to Liana on the ropes)
	local empathyStation = Instance.new("Part")
	empathyStation.Name = "HH_EmpathyStation"
	empathyStation.Size = Vector3.new(4, 1, 4)
	empathyStation.Position = Vector3.new(canopyRope.Position.X + 6, 1, canopyRope.Position.Z + 6)
	empathyStation.Color = Color3.fromRGB(195, 215, 225)
	empathyStation.Material = Enum.Material.SmoothPlastic
	empathyStation.Anchored = true
	empathyStation.Parent = arch

	attachPrompt(empathyStation, "Experience as Sloth (Empathy Mode)", "Canopy Perspective", 1.0, function(player)
		TrainingModeEvent:FireClient(player, "StartSlothEmpathy", slothRoot, targetMarker)
	end)
end

TrainingModeEvent.OnServerEvent:Connect(function(player, action)
	if action == "CompletedSlothEmpathy" and _G.EPZ_AwardProgress then
		_G.EPZ_AwardProgress(player, "TwoToedSloth", "AnimalEmpathyTraining")
	end
end)

-- =========================================================================
-- 5. YEAR 1 / STAGE 2: GENTLE FIELD TRIP STUDENT REGROUPING
-- =========================================================================
local studentSpots = {
	{ Name = "Student_Maya", Pos = Vector3.new(-30, 16, 26), Fact = "Look at the ferrets sleeping in their tunnels!" },
	{ Name = "Student_Leo", Pos = Vector3.new(-18, 2, -182), Fact = "The tortoise is warming up right under its heat lamp!" },
	{ Name = "Student_Sam", Pos = Vector3.new(33, 2, -105), Fact = "I love listening to the birds in the cedar aviary!" },
}

for _, info in ipairs(studentSpots) do
	local student = Instance.new("Part")
	student.Name = info.Name
	student.Size = Vector3.new(1.8, 4.2, 1.4)
	student.Position = info.Pos
	student.Color = Color3.fromRGB(235, 200, 130)
	student.Material = Enum.Material.SmoothPlastic
	student.Anchored = true
	student.Parent = world

	attachPrompt(student, "Gently Invite Back to Group", "Field Trip Student", 0.5, function(player)
		if _G.EPZ_AwardProgress then
			_G.EPZ_AwardProgress(player, nil, "FieldTripRegroup")
		end
	end)
end
