-- === PRO TOOLS GUI - FINAL (with AntiLag 10s Delay) ===
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer

-- ================== SETTINGS ==================
local killInterval = 3600
local tpInterval = 1

local tpPosition = Vector3.new(-2678, 162, 1758)
local killEnabled = true
local tpEnabled = true
local antilagEnabled = true   -- Auto nyala

local timeLeftKill = killInterval
local lastTimeKill = tick()
local lastTimeTP = tick()

-- ================== GUI ==================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Some Tools Idk"
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
title.Text = "🔧 Kyluxx Tools Idk"
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

-- ================== ANTILAG SECTION ==================
local lagTitle = Instance.new("TextLabel")
lagTitle.Size = UDim2.new(1, -20, 0, 25)
lagTitle.Position = UDim2.new(0, 10, 0, 125)
lagTitle.BackgroundTransparency = 1
lagTitle.Text = "AntiLag"
lagTitle.TextColor3 = Color3.fromRGB(255, 100, 100)
lagTitle.TextXAlignment = Enum.TextXAlignment.Left
lagTitle.Font = Enum.Font.GothamSemibold
lagTitle.Parent = contentFrame

local lagToggle = Instance.new("TextButton")
lagToggle.Size = UDim2.new(0, 90, 0, 28)
lagToggle.Position = UDim2.new(1, -100, 0, 125)
lagToggle.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
lagToggle.Text = "ON"
lagToggle.TextColor3 = Color3.new(1,1,1)
lagToggle.TextScaled = true
lagToggle.Font = Enum.Font.GothamBold
lagToggle.Parent = contentFrame

-- Preset TP Buttons
local forsakenBtn = Instance.new("TextButton")
forsakenBtn.Size = UDim2.new(0.47, 0, 0, 38)
forsakenBtn.Position = UDim2.new(0, 10, 0, 170)
forsakenBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
forsakenBtn.Text = "Forsaken"
forsakenBtn.TextColor3 = Color3.new(1,1,1)
forsakenBtn.TextScaled = true
forsakenBtn.Font = Enum.Font.GothamSemibold
forsakenBtn.Parent = contentFrame

local mineshaftBtn = Instance.new("TextButton")
mineshaftBtn.Size = UDim2.new(0.47, 0, 0, 38)
mineshaftBtn.Position = UDim2.new(0.5, 5, 0, 170)
mineshaftBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mineshaftBtn.Text = "Mineshaft"
mineshaftBtn.TextColor3 = Color3.new(1,1,1)
mineshaftBtn.TextScaled = true
mineshaftBtn.Font = Enum.Font.GothamSemibold
mineshaftBtn.Parent = contentFrame

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
		if v:IsA("PostEffect") then
			v.Enabled = false
		end
	end
	
	-- AntiLag Descendant
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

lagToggle.MouseButton1Click:Connect(function()
	antilagEnabled = not antilagEnabled
	lagToggle.Text = antilagEnabled and "ON" or "OFF"
	lagToggle.BackgroundColor3 = antilagEnabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
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

-- ================== START ==================
updateHighlight()

-- AntiLag dengan delay 10 detik
task.delay(10, function()
	if antilagEnabled then
		applyAntiLag()
		workspace:FindFirstChildOfClass('Terrain'):Clear()
	end
end)

print("✅ Pro Tools GUI + AntiLag (10s delay) Loaded!")
