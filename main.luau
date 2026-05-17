-- === PRO TOOLS GUI + WATCHDOG PING ===
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local PlaceId = game.PlaceId
local JobId = game.JobId

-- ================== SETTINGS ==================
local killInterval = 3600
local tpInterval = 1

-- Forsaken 
-- local tpPosition = Vector3.new(-2678, 162, 1758) 

-- Mineshaft
local tpPosition = Vector3.new(-728, -869, -102) 

local killEnabled = true
local tpEnabled = true

local timeLeftKill = killInterval
local lastTimeKill = tick()
local lastTimeTP = tick()

-- ================== WATCHDOG ==================
local BACKEND_URL = "https://kyluxxserver.cloud/watchdog-roblox/game_ping.php"
local API_KEY     = "st0lPT9qSSLm4_Vx2Pc107ZaK1Rw8AJs77sFn8aSk"
local PING_INTERVAL = 600 -- 10 minutes

local lastPingStatus = "—"

local function sendGamePing()
	local payload = {
		key       = API_KEY,
		username  = player.Name,
		timestamp = os.time(),
	}

	local success, err = pcall(function()
		local request = http_request or request or (http and http.request)

		if not request then
			lastPingStatus = "no http fn"
			warn("[Watchdog] No HTTP request function available")
			return
		end

		local response = request({
			Url     = BACKEND_URL,
			Method  = "POST",
			Headers = { ["Content-Type"] = "application/json" },
			Body    = HttpService:JSONEncode(payload),
		})

		if response and response.Body then
			local ok, decoded = pcall(function()
				return HttpService:JSONDecode(response.Body)
			end)

			if ok and decoded then
				if decoded.ok then
					lastPingStatus = "OK " .. os.date("%H:%M")
					print(("[Watchdog] Ping OK — %s"):format(player.Name))
				else
					lastPingStatus = "ERR: " .. (decoded.message or "?")
					warn(("[Watchdog] Server error: %s"):format(decoded.message or "?"))
				end
			else
				lastPingStatus = "bad response"
			end
		else
			lastPingStatus = "sent (no body)"
		end
	end)

	if not success then
		lastPingStatus = "failed"
		warn(("[Watchdog] Request failed: %s"):format(err))
	end
end

-- Run ping loop in background (non-blocking)
task.spawn(function()
	print(("[Watchdog] Started for: %s — every %ds"):format(player.Name, PING_INTERVAL))
	while true do
		sendGamePing()
		task.wait(PING_INTERVAL)
	end
end)

-- ================== GUI ==================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ProToolsGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 310)
mainFrame.Position = UDim2.new(1, -270, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BackgroundTransparency = 0.25
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.Text = "🔧 Kyluxx Tools"
title.TextColor3 = Color3.fromRGB(0, 180, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -40)
contentFrame.Position = UDim2.new(0, 0, 0, 35)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 90, 0, 28)
minimizeBtn.Position = UDim2.new(0.5, -45, 1, -35)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
minimizeBtn.BackgroundTransparency = 0.2
minimizeBtn.Text = "Minimize"
minimizeBtn.TextColor3 = Color3.fromRGB(255,255,255)
minimizeBtn.TextScaled = true
minimizeBtn.Font = Enum.Font.GothamSemibold
minimizeBtn.Parent = mainFrame

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 8)
minCorner.Parent = minimizeBtn

-- ================== AUTOKILL ==================
local killTitle = Instance.new("TextLabel")
killTitle.Size = UDim2.new(1, -20, 0, 25)
killTitle.Position = UDim2.new(0, 10, 0, 10)
killTitle.BackgroundTransparency = 1
killTitle.Text = "AutoKill"
killTitle.TextColor3 = Color3.fromRGB(0, 255, 120)
killTitle.TextXAlignment = Enum.TextXAlignment.Left
killTitle.Font = Enum.Font.GothamSemibold
killTitle.Parent = contentFrame

local killTimerLabel = Instance.new("TextLabel")
killTimerLabel.Size = UDim2.new(1, -20, 0, 32)
killTimerLabel.Position = UDim2.new(0, 10, 0, 35)
killTimerLabel.BackgroundTransparency = 1
killTimerLabel.Text = "1:00"
killTimerLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
killTimerLabel.TextScaled = true
killTimerLabel.Font = Enum.Font.GothamBold
killTimerLabel.Parent = contentFrame

local killToggle = Instance.new("TextButton")
killToggle.Size = UDim2.new(0, 90, 0, 28)
killToggle.Position = UDim2.new(1, -100, 0, 10)
killToggle.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
killToggle.Text = "ON"
killToggle.TextColor3 = Color3.new(1,1,1)
killToggle.TextScaled = true
killToggle.Font = Enum.Font.GothamBold
killToggle.Parent = contentFrame

local killCorner = Instance.new("UICorner")
killCorner.CornerRadius = UDim.new(0, 8)
killCorner.Parent = killToggle

-- ================== TP LOOP ==================
local tpTitle = Instance.new("TextLabel")
tpTitle.Size = UDim2.new(1, -20, 0, 25)
tpTitle.Position = UDim2.new(0, 10, 0, 80)
tpTitle.BackgroundTransparency = 1
tpTitle.Text = "TP Loop"
tpTitle.TextColor3 = Color3.fromRGB(255, 170, 0)
tpTitle.TextXAlignment = Enum.TextXAlignment.Left
tpTitle.Font = Enum.Font.GothamSemibold
tpTitle.Parent = contentFrame

local tpToggle = Instance.new("TextButton")
tpToggle.Size = UDim2.new(0, 90, 0, 28)
tpToggle.Position = UDim2.new(1, -100, 0, 80)
tpToggle.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
tpToggle.Text = "ON"
tpToggle.TextColor3 = Color3.new(1,1,1)
tpToggle.TextScaled = true
tpToggle.Font = Enum.Font.GothamBold
tpToggle.Parent = contentFrame

local tpCorner = Instance.new("UICorner")
tpCorner.CornerRadius = UDim.new(0, 8)
tpCorner.Parent = tpToggle

-- Preset TP Buttons
local forsakenBtn = Instance.new("TextButton")
forsakenBtn.Size = UDim2.new(0.47, 0, 0, 38)
forsakenBtn.Position = UDim2.new(0, 10, 0, 125)
forsakenBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
forsakenBtn.Text = "Forsaken"
forsakenBtn.TextColor3 = Color3.new(1,1,1)
forsakenBtn.TextScaled = true
forsakenBtn.Font = Enum.Font.GothamSemibold
forsakenBtn.Parent = contentFrame

local forsakenCorner = Instance.new("UICorner")
forsakenCorner.CornerRadius = UDim.new(0, 8)
forsakenCorner.Parent = forsakenBtn

local mineshaftBtn = Instance.new("TextButton")
mineshaftBtn.Size = UDim2.new(0.47, 0, 0, 38)
mineshaftBtn.Position = UDim2.new(0.5, 5, 0, 125)
mineshaftBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mineshaftBtn.Text = "Mineshaft"
mineshaftBtn.TextColor3 = Color3.new(1,1,1)
mineshaftBtn.TextScaled = true
mineshaftBtn.Font = Enum.Font.GothamSemibold
mineshaftBtn.Parent = contentFrame

local mineshaftCorner = Instance.new("UICorner")
mineshaftCorner.CornerRadius = UDim.new(0, 8)
mineshaftCorner.Parent = mineshaftBtn

-- ================== WATCHDOG STATUS BAR ==================
local watchdogBar = Instance.new("Frame")
watchdogBar.Size = UDim2.new(1, -20, 0, 30)
watchdogBar.Position = UDim2.new(0, 10, 0, 175)
watchdogBar.BackgroundColor3 = Color3.fromRGB(10, 20, 35)
watchdogBar.BackgroundTransparency = 0.1
watchdogBar.BorderSizePixel = 0
watchdogBar.Parent = contentFrame

local wdBarCorner = Instance.new("UICorner")
wdBarCorner.CornerRadius = UDim.new(0, 8)
wdBarCorner.Parent = watchdogBar

local wdIcon = Instance.new("TextLabel")
wdIcon.Size = UDim2.new(0, 24, 1, 0)
wdIcon.Position = UDim2.new(0, 6, 0, 0)
wdIcon.BackgroundTransparency = 1
wdIcon.Text = "📡"
wdIcon.TextScaled = true
wdIcon.Parent = watchdogBar

local wdLabel = Instance.new("TextLabel")
wdLabel.Size = UDim2.new(1, -36, 1, 0)
wdLabel.Position = UDim2.new(0, 34, 0, 0)
wdLabel.BackgroundTransparency = 1
wdLabel.Text = "Watchdog: —"
wdLabel.TextColor3 = Color3.fromRGB(100, 180, 255)
wdLabel.TextXAlignment = Enum.TextXAlignment.Left
wdLabel.TextScaled = true
wdLabel.Font = Enum.Font.GothamSemibold
wdLabel.Parent = watchdogBar

-- Update watchdog label every second
task.spawn(function()
	while true do
		wdLabel.Text = "Watchdog: " .. lastPingStatus
		task.wait(1)
	end
end)

-- ================== FUNCTIONS ==================
local function getRoot(char)
	return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
end

local function forceKill(char)
	if not char then return end
	local hum = char:FindFirstChildWhichIsA("Humanoid")
	if hum then hum.Health = 0 else char:BreakJoints() end
end

local function teleport()
	local char = player.Character
	local root = char and getRoot(char)
	if root then root.CFrame = CFrame.new(tpPosition) end
end

local function applyAntiLag()
	local Terrain = workspace:FindFirstChildWhichIsA("Terrain")
	if Terrain then
		Terrain.WaterWaveSize = 0
		Terrain.WaterWaveSpeed = 0
		Terrain.WaterReflectance = 0
		Terrain.WaterTransparency = 1
		Terrain:Clear()
	end

	Lighting.GlobalShadows = false
	Lighting.FogEnd = 9e9
	Lighting.FogStart = 9e9
	settings().Rendering.QualityLevel = 1

	for _, v in pairs(game:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CastShadow = false
			v.Material = "Plastic"
			v.Reflectance = 0
			v.BackSurface = "SmoothNoOutlines"
			v.BottomSurface = "SmoothNoOutlines"
			v.FrontSurface = "SmoothNoOutlines"
			v.LeftSurface = "SmoothNoOutlines"
			v.RightSurface = "SmoothNoOutlines"
			v.TopSurface = "SmoothNoOutlines"
		elseif v:IsA("Decal") then
			v.Transparency = 1
			v.Texture = ""
		elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
			v.Lifetime = NumberRange.new(0)
		end
	end

	for _, v in pairs(Lighting:GetDescendants()) do
		if v:IsA("PostEffect") then v.Enabled = false end
	end

	workspace.DescendantAdded:Connect(function(child)
		task.spawn(function()
			if child:IsA("ForceField") or child:IsA("Sparkles") or child:IsA("Smoke") or child:IsA("Fire") or child:IsA("Beam") then
				RunService.Heartbeat:Wait()
				child:Destroy()
			elseif child:IsA("BasePart") then
				child.CastShadow = false
			end
		end)
	end)

	print("✅ AntiLag telah diaktifkan!")
end

local function updateHighlight()
	if tpPosition.Y == 162 then
		forsakenBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
		mineshaftBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	else
		mineshaftBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
		forsakenBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	end
end

-- ================== AUTO REJOIN ==================
GuiService.ErrorMessageChanged:Connect(function()
	if GuiService:GetErrorMessage() ~= "" then
		print("⚠️ Error terdeteksi, Auto Rejoin dijalankan...")
		task.wait(1)
		if #Players:GetPlayers() <= 1 then
			player:Kick("\nRejoining...")
			task.wait()
			TeleportService:Teleport(PlaceId, player)
		else
			TeleportService:TeleportToPlaceInstance(PlaceId, JobId, player)
		end
	end
end)

print("✅ Auto Rejoin telah diaktifkan!")

-- ================== LOOPS ==================
RunService.Heartbeat:Connect(function()
	if killEnabled then
		local delta = tick() - lastTimeKill
		lastTimeKill = tick()
		timeLeftKill -= delta

		if timeLeftKill <= 0 then
			if player.Character then forceKill(player.Character) end
			timeLeftKill = killInterval
		end

		local min = math.floor(timeLeftKill / 60)
		local sec = math.floor(timeLeftKill % 60)
		killTimerLabel.Text = string.format("%d:%02d", min, sec)
	end

	if tpEnabled then
		if tick() - lastTimeTP >= tpInterval then
			teleport()
			lastTimeTP = tick()
		end
	end
end)

-- ================== BUTTONS ==================
killToggle.MouseButton1Click:Connect(function()
	killEnabled = not killEnabled
	killToggle.Text = killEnabled and "ON" or "OFF"
	killToggle.BackgroundColor3 = killEnabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(80,80,80)
end)

tpToggle.MouseButton1Click:Connect(function()
	tpEnabled = not tpEnabled
	tpToggle.Text = tpEnabled and "ON" or "OFF"
	tpToggle.BackgroundColor3 = tpEnabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
	if tpEnabled then lastTimeTP = tick() end
end)

forsakenBtn.MouseButton1Click:Connect(function()
	tpPosition = Vector3.new(-2678, 162, 1758)
	updateHighlight()
end)

mineshaftBtn.MouseButton1Click:Connect(function()
	tpPosition = Vector3.new(-728, -869, -102)
	updateHighlight()
end)

-- Minimize
local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		contentFrame.Visible = false
		mainFrame.Size = UDim2.new(0, 250, 0, 75)
		minimizeBtn.Text = "Expand"
	else
		contentFrame.Visible = true
		mainFrame.Size = UDim2.new(0, 250, 0, 310)
		minimizeBtn.Text = "Minimize"
	end
end)

-- Drag
local dragging = false
local dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
	end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

-- ================== START ==================
updateHighlight()

task.delay(30, function()
	applyAntiLag()
end)

-- Load external script
task.spawn(function()
	loadstring(game:HttpGet("https://gist.githubusercontent.com/AntiKickKickClub/73bcd2f11e97714b042a45228e8e7c5b/raw/public.luau"))()
end)


print("✅ Pro Tools GUI + AntiLag + Auto Rejoin + Watchdog LOADED!")
