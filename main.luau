-- === AUTO KILL + COUNTDOWN ===
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local interval = 3600

local enabled = true
local timeLeft = interval
local lastTime = tick()

local countdownConnection = nil
local autoKillLoop = nil

-- ================== GUI ==================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoKillGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 210, 0, 65)
frame.Position = UDim2.new(1, -220, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = frame

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.TextScaled = true
label.Font = Enum.Font.GothamBold
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.Parent = frame

-- ================== KILL FUNCTION ==================
local function forceKill(char)
	if not char then return end
	local hum = char:FindFirstChildWhichIsA("Humanoid")
	if hum then
		hum.Health = 0
	else
		char:BreakJoints()
	end
end

-- ================== UPDATE LABEL ==================
local function updateLabel()
	if not enabled then
		label.Text = "AutoKill: OFF"
		label.TextColor3 = Color3.fromRGB(255, 60, 60)
		return
	end
	
	local min = math.floor(timeLeft / 60)
	local sec = timeLeft % 60
	label.Text = string.format("AutoKill: ON\n%d:%02d", min, sec)
	label.TextColor3 = Color3.fromRGB(0, 255, 100)
end

-- ================== COUNTDOWN (FIXED) ==================
local function startCountdown()
	if countdownConnection then return end
	
	countdownConnection = RunService.Heartbeat:Connect(function()
		if enabled then
			local now = tick()
			local delta = now - lastTime
			lastTime = now
			
			timeLeft = timeLeft - delta
			
			if timeLeft <= 0 then
				if player.Character then
					forceKill(player.Character)
				end
				timeLeft = interval
			end
			
			updateLabel()
		end
	end)
end

-- ================== TOGGLE ==================
frame.InputBegan:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
		enabled = not enabled
		lastTime = tick()
		
		if enabled then
			timeLeft = interval
			startCountdown()
		else
			if countdownConnection then
				countdownConnection:Disconnect()
				countdownConnection = nil
			end
		end
		
		updateLabel()
	end
end)

-- ================== START ==================
updateLabel()
startCountdown()

print("✅ AutoKill.")
