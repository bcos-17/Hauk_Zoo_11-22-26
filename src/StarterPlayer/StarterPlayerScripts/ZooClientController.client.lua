local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local Remotes = ReplicatedStorage:WaitForChild("ZooRemotes")

local SyncProfileEvent = Remotes:WaitForChild("SyncProfile")
local UnlockSpeciesEvent = Remotes:WaitForChild("UnlockSpecies")
local SwapBadgeEvent = Remotes:WaitForChild("SwapBadge")
local RedeemGiftEvent = Remotes:WaitForChild("RedeemGift")
local SeasonChangedEvent = Remotes:WaitForChild("SeasonChanged")
local TrainingModeEvent = Remotes:WaitForChild("TrainingMode")
local AskWoodyFunction = Remotes:WaitForChild("AskWoodyFunction")

local CurrentProfile = { UnlockedYear = 1, ActiveYearRole = 1, CompletedTasksCount = 0, Encyclopedia = {}, StampedGifts = {} }
local CurrentSeason = "Spring"
local CurrentYear = 1
local PaceIndex = 1
local ChillModeActive = false
local EmpathyActive = false

-- =========================================================================
-- UI BUILDER HELPERS (Soft Pastel Palette)
-- =========================================================================
local COLORS = {
	Bg = Color3.fromRGB(245, 248, 246),
	Header = Color3.fromRGB(228, 238, 232),
	Accent = Color3.fromRGB(92, 138, 112),
	TextDark = Color3.fromRGB(52, 68, 58),
	TextMuted = Color3.fromRGB(102, 118, 108),
	Border = Color3.fromRGB(202, 218, 208),
}

local gui = Instance.new("ScreenGui")
gui.Name = "EPZ_PastelHUD"
gui.ResetOnSpawn = false
gui.Parent = pGui

local function styleCard(frame, radius)
	frame.BackgroundColor3 = COLORS.Bg
	frame.BorderSizePixel = 0
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 12)
	c.Parent = frame
	local s = Instance.new("UIStroke")
	s.Color = COLORS.Border
	s.Thickness = 1.5
	s.Parent = frame
end

-- Top Status Bar (Season, Year, Active Duty Badge)
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(0, 520, 0, 44)
topBar.Position = UDim2.new(0.5, -260, 0, 14)
styleCard(topBar, 14)
topBar.Parent = gui

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 1, 0)
statusLabel.Position = UDim2.new(0, 10, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.TextSize = 14
statusLabel.TextColor3 = COLORS.TextDark
statusLabel.Text = "Spring • Year 1 • Guest Engagement & Tour Volunteer"
statusLabel.Parent = topBar

-- Bottom Control Dock (Pace Toggle, Encyclopedia, Passbook, Chill Mode)
local dock = Instance.new("Frame")
dock.Size = UDim2.new(0, 560, 0, 48)
dock.Position = UDim2.new(0.5, -280, 1, -64)
styleCard(dock, 14)
dock.Parent = gui

local dockLayout = Instance.new("UIListLayout")
dockLayout.FillDirection = Enum.FillDirection.Horizontal
dockLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
dockLayout.VerticalAlignment = Enum.VerticalAlignment.Center
dockLayout.Padding = UDim.new(0, 10)
dockLayout.Parent = dock

local function makeDockButton(text)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 128, 0, 34)
	btn.BackgroundColor3 = COLORS.Header
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 12
	btn.TextColor3 = COLORS.TextDark
	btn.Text = text
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = btn
	btn.Parent = dock
	return btn
end

local paceBtn = makeDockButton("Pace: Gentle (14)")
local encycBtn = makeDockButton("Encyclopedia")
local passbookBtn = makeDockButton("Keeper Passbook")
local chillBtn = makeDockButton("Chill Mode [C]")

-- =========================================================================
-- MODAL PANELS (Encyclopedia, Passbook, Woody Chat)
-- =========================================================================
local modalFrame = Instance.new("Frame")
modalFrame.Size = UDim2.new(0, 520, 0, 340)
modalFrame.Position = UDim2.new(0.5, -260, 0.5, -170)
modalFrame.Visible = false
styleCard(modalFrame, 16)
modalFrame.Parent = gui

local modalTitle = Instance.new("TextLabel")
modalTitle.Size = UDim2.new(1, -60, 0, 38)
modalTitle.Position = UDim2.new(0, 16, 0, 6)
modalTitle.BackgroundTransparency = 1
modalTitle.Font = Enum.Font.GothamBold
modalTitle.TextSize = 16
modalTitle.TextColor3 = COLORS.TextDark
modalTitle.TextXAlignment = Enum.TextXAlignment.Left
modalTitle.Parent = modalFrame

local closeModalBtn = Instance.new("TextButton")
closeModalBtn.Size = UDim2.new(0, 30, 0, 30)
closeModalBtn.Position = UDim2.new(1, -38, 0, 8)
closeModalBtn.BackgroundColor3 = COLORS.Header
closeModalBtn.Font = Enum.Font.GothamBold
closeModalBtn.Text = "X"
closeModalBtn.TextColor3 = COLORS.TextDark
local cc = Instance.new("UICorner")
cc.CornerRadius = UDim.new(0, 8)
cc.Parent = closeModalBtn
closeModalBtn.Parent = modalFrame

local scrollList = Instance.new("ScrollingFrame")
scrollList.Size = UDim2.new(1, -28, 1, -56)
scrollList.Position = UDim2.new(0, 14, 0, 46)
scrollList.BackgroundTransparency = 1
scrollList.BorderSizePixel = 0
scrollList.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollList.ScrollBarThickness = 4
scrollList.Parent = modalFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.Parent = scrollList

closeModalBtn.MouseButton1Click:Connect(function()
	modalFrame.Visible = false
end)

local function clearModal()
	for _, child in ipairs(scrollList:GetChildren()) do
		if not child:IsA("UIListLayout") then
			child:Destroy()
		end
	end
end

local function openEncyclopedia()
	clearModal()
	modalTitle.Text = "Elmwood Park Zoo — Animal Encyclopedia"
	for key, entry in pairs(GameConfig.Encyclopedia) do
		local unlocked = CurrentProfile.Encyclopedia[key] == true
		local card = Instance.new("Frame")
		card.Size = UDim2.new(1, -8, 0, 74)
		styleCard(card, 10)
		card.BackgroundColor3 = unlocked and COLORS.Header or COLORS.Bg
		card.Parent = scrollList

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -16, 1, -8)
		lbl.Position = UDim2.new(0, 8, 0, 4)
		lbl.BackgroundTransparency = 1
		lbl.Font = Enum.Font.Gotham
		lbl.TextSize = 12
		lbl.TextWrapped = true
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.TextColor3 = COLORS.TextDark
		if unlocked then
			lbl.Text = string.format("%s (%s) • %s\n%s", entry.CommonName, entry.ScientificName, entry.Zone, entry.Fact)
		else
			lbl.Text = string.format("Undiscovered Species (%s)\nExplore this habitat to add notes to your encyclopedia.", entry.Zone)
		end
		lbl.Parent = card
	end
	modalFrame.Visible = true
end

local function openPassbook()
	clearModal()
	modalTitle.Text = "Keeper Passbook & Duty Badge Toolbox"
	for yearNum = 1, 6 do
		local info = GameConfig.CareerYears[yearNum]
		local unlocked = yearNum <= CurrentProfile.UnlockedYear
		local stamped = CurrentProfile.StampedGifts[yearNum] == true

		local card = Instance.new("Frame")
		card.Size = UDim2.new(1, -8, 0, 68)
		styleCard(card, 10)
		card.Parent = scrollList

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0.68, 0, 1, -8)
		lbl.Position = UDim2.new(0, 10, 0, 4)
		lbl.BackgroundTransparency = 1
		lbl.Font = Enum.Font.Gotham
		lbl.TextSize = 12
		lbl.TextWrapped = true
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.TextColor3 = COLORS.TextDark
		lbl.Text = string.format("Year %d: %s\nPassbook Gift: %s %s", yearNum, info.RoleName, info.GiftName, stamped and "[STAMPED]" or "")
		lbl.Parent = card

		if unlocked then
			local actionBtn = Instance.new("TextButton")
			actionBtn.Size = UDim2.new(0.28, 0, 0, 32)
			actionBtn.Position = UDim2.new(0.7, 0, 0.5, -16)
			actionBtn.BackgroundColor3 = COLORS.Accent
			actionBtn.Font = Enum.Font.GothamBold
			actionBtn.TextSize = 11
			actionBtn.TextColor3 = Color3.new(1, 1, 1)
			actionBtn.Text = (CurrentProfile.ActiveYearRole == yearNum) and "Active Role" or "Equip Badge"
			local bc = Instance.new("UICorner")
			bc.CornerRadius = UDim.new(0, 8)
			bc.Parent = actionBtn
			actionBtn.Parent = card

			actionBtn.MouseButton1Click:Connect(function()
				SwapBadgeEvent:FireServer(yearNum)
				if not stamped then
					RedeemGiftEvent:FireServer(yearNum)
				end
				modalFrame.Visible = false
			end)
		end
	end
	modalFrame.Visible = true
end

encycBtn.MouseButton1Click:Connect(openEncyclopedia)
passbookBtn.MouseButton1Click:Connect(openPassbook)

-- =========================================================================
-- WOODY THE OWL CHILL MODE [C]
-- =========================================================================
local woodyBox = Instance.new("Frame")
woodyBox.Size = UDim2.new(0, 440, 0, 140)
woodyBox.Position = UDim2.new(0.5, -220, 1, -218)
woodyBox.Visible = false
styleCard(woodyBox, 14)
woodyBox.Parent = gui

local woodyReply = Instance.new("TextLabel")
woodyReply.Size = UDim2.new(1, -24, 0, 74)
woodyReply.Position = UDim2.new(0, 12, 0, 10)
woodyReply.BackgroundTransparency = 1
woodyReply.Font = Enum.Font.Gotham
woodyReply.TextSize = 13
woodyReply.TextWrapped = true
woodyReply.TextXAlignment = Enum.TextXAlignment.Left
woodyReply.TextColor3 = COLORS.TextDark
woodyReply.Text = "Woody the Owl: Take a deep breath and relax! Ask me anything about Elmwood Park Zoo."
woodyReply.Parent = woodyBox

local woodyInput = Instance.new("TextBox")
woodyInput.Size = UDim2.new(1, -24, 0, 34)
woodyInput.Position = UDim2.new(0, 12, 1, -44)
woodyInput.BackgroundColor3 = COLORS.Header
woodyInput.Font = Enum.Font.Gotham
woodyInput.TextSize = 13
woodyInput.PlaceholderText = "Ask Woody a question and press Enter..."
woodyInput.Text = ""
woodyInput.TextColor3 = COLORS.TextDark
local ic = Instance.new("UICorner")
ic.CornerRadius = UDim.new(0, 8)
ic.Parent = woodyInput
woodyInput.Parent = woodyBox

woodyInput.FocusLost:Connect(function(enterPressed)
	if enterPressed and #woodyInput.Text > 0 then
		local q = woodyInput.Text
		woodyInput.Text = ""
		woodyReply.Text = "Woody is thinking..."
		local answer = AskWoodyFunction:InvokeServer(q)
		woodyReply.Text = "Woody: " .. tostring(answer)
	end
end)

local function toggleChillMode()
	ChillModeActive = not ChillModeActive
	woodyBox.Visible = ChillModeActive
	chillBtn.Text = ChillModeActive and "Exit Chill [C]" or "Chill Mode [C]"
end

chillBtn.MouseButton1Click:Connect(toggleChillMode)
UserInputService.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == Enum.KeyCode.C then
		toggleChillMode()
	end
end)

-- =========================================================================
-- PACE CONTROLLER & REMOTE LISTENERS
-- =========================================================================
local function refreshHUD()
	local roleInfo = GameConfig.CareerYears[CurrentProfile.ActiveYearRole] or GameConfig.CareerYears[1]
	statusLabel.Text = string.format("%s • Year %d • %s", CurrentSeason, CurrentYear, roleInfo.RoleName)
end

paceBtn.MouseButton1Click:Connect(function()
	PaceIndex = (PaceIndex % #GameConfig.PaceModes) + 1
	local mode = GameConfig.PaceModes[PaceIndex]
	paceBtn.Text = string.format("Pace: %s (%d)", mode.Name, mode.Speed)
	player:SetAttribute("PreferredPace", mode.Speed)
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if hum and player:GetAttribute("CurrentZone") ~= "Harmony Hideaway" then
		hum.WalkSpeed = mode.Speed
	end
end)

SyncProfileEvent.OnClientEvent:Connect(function(profile, season, year)
	CurrentProfile = profile
	CurrentSeason = season or CurrentSeason
	CurrentYear = year or CurrentYear
	refreshHUD()
end)

SeasonChangedEvent.OnClientEvent:Connect(function(season, year)
	CurrentSeason = season
	CurrentYear = year
	refreshHUD()
end)

UnlockSpeciesEvent.OnClientEvent:Connect(function(_, entry)
	woodyBox.Visible = true
	woodyReply.Text = string.format("Encyclopedia Updated: %s — %s", entry.CommonName, entry.Fact)
	task.delay(6, function()
		if not ChillModeActive then
			woodyBox.Visible = false
		end
	end)
end)

-- =========================================================================
-- STAGE 3: ANIMAL EMPATHY MODE (Slow, Rhythmic Sloth Canopy Traversal)
-- =========================================================================
TrainingModeEvent.OnClientEvent:Connect(function(mode, slothRoot, targetMarker)
	if mode ~= "StartSlothEmpathy" or not slothRoot or not targetMarker or EmpathyActive then return end
	EmpathyActive = true

	local cam = workspace.CurrentCamera
	local startCF = slothRoot.CFrame
	cam.CameraType = Enum.CameraType.Scriptable

	woodyBox.Visible = true
	woodyReply.Text = "Animal Empathy Mode: Hold [W] or [Up] to slowly move along the canopy rope toward the green target cue."

	local conn
	conn = RunService.RenderStepped:Connect(function(dt)
		cam.CFrame = slothRoot.CFrame * CFrame.new(0, 2, 10) * CFrame.Angles(math.rad(-10), 0, 0)

		if UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.Up) then
			local dir = (targetMarker.Position - slothRoot.Position)
			if dir.Magnitude > 1.5 then
				slothRoot.CFrame = slothRoot.CFrame + (dir.Unit * (2.5 * dt)) -- Deliberate, rhythmic sloth pace
			else
				conn:Disconnect()
				slothRoot.CFrame = startCF
				cam.CameraType = Enum.CameraType.Custom
				EmpathyActive = false
				woodyReply.Text = "Positive reinforcement complete! You experienced Harmony Hideaway from Liana's perspective."
				TrainingModeEvent:FireServer("CompletedSlothEmpathy")
				task.delay(4, function()
					if not ChillModeActive then woodyBox.Visible = false end
				end)
			end
		end
	end)
end)
