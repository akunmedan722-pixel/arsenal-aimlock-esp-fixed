--[[
    ARSENAL AIM LOCK + ESP SCRIPT (SKYZEN UNIVERSAL VERSION)
    ==========================================================
    Professional SkyZen UI Implementation
    Features:
    - Aim Lock dengan target selection (Head, Body, Hand)
    - ESP toggle (ON/OFF) 
    - Professional SkyZen UI
    - Lightweight & Fast
    - Keyboard shortcuts (E, R, F)
]]

local SkyZen = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/SkyZen/main/source'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

-- Configuration
local Config = {
    AimLockEnabled = false,
    ESPEnabled = true,
    TargetPart = "Head",
    MaxDistance = 500,
    Smoothness = 0.1,
}

-- ESP Storage
local ESPObjects = {}
local LastESPUpdate = 0
local ESPUpdateInterval = 0.5

-- Colors
local Colors = {
    Primary = Color3.fromRGB(0, 170, 255),
    Success = Color3.fromRGB(0, 255, 136),
    Error = Color3.fromRGB(255, 85, 105),
    Background = Color3.fromRGB(10, 15, 30),
    Card = Color3.fromRGB(15, 20, 40),
    Text = Color3.fromRGB(245, 248, 255),
    Muted = Color3.fromRGB(120, 140, 180),
}

-- ============================================
-- SKYZEN UI SETUP
-- ============================================

local MainWindow = SkyZen:CreateWindow({
    Name = "Arsenal Aimlock Universal",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by Falxe | SkyZen Edition",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "ArsenalSkyZen"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false,
    KeySettings = {
        Title = "Arsenal Hub",
        Subtitle = "Key System",
        Note = "No key required",
        FileName = "ArsenalKey",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = "arsenal123"
    }
})

local MainTab = MainWindow:CreateTab("Main", 4483362458)

-- ============================================
-- ESP FUNCTIONS
-- ============================================

local function createESP(player)
    if player == LocalPlayer or ESPObjects[player] then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local espBox = Instance.new("BoxHandleAdornment")
    espBox.Size = Vector3.new(3, 5, 3)
    espBox.Color3 = Colors.Primary
    espBox.Transparency = 0.3
    espBox.AlwaysOnTop = true
    espBox.Parent = humanoidRootPart
    
    local espLabel = Instance.new("BillboardGui")
    espLabel.Size = UDim2.new(4, 0, 2, 0)
    espLabel.MaxDistance = Config.MaxDistance
    espLabel.Parent = humanoidRootPart
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.fromScale(1, 1)
    textLabel.BackgroundTransparency = 0.2
    textLabel.BackgroundColor3 = Colors.Background
    textLabel.Text = player.Name
    textLabel.TextColor3 = Colors.Success
    textLabel.TextSize = 12
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Parent = espLabel
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = textLabel
    
    ESPObjects[player] = {
        Box = espBox,
        Label = espLabel,
    }
end

local function removeESP(player)
    if ESPObjects[player] then
        pcall(function()
            ESPObjects[player].Box:Destroy()
            ESPObjects[player].Label:Destroy()
        end)
        ESPObjects[player] = nil
    end
end

local function updateESP()
    if not Config.ESPEnabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                if not ESPObjects[player] then
                    createESP(player)
                end
            else
                removeESP(player)
            end
        end
    end
end

local function clearAllESP()
    for player, _ in pairs(ESPObjects) do
        removeESP(player)
    end
end

-- ============================================
-- AIM LOCK FUNCTIONS
-- ============================================

local function getClosestPlayer()
    local closestPlayer = nil
    local closestDistance = Config.MaxDistance
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local targetPart = player.Character:FindFirstChild(Config.TargetPart)
            
            if humanoid and humanoid.Health > 0 and targetPart and LocalPlayer.Character then
                local distance = (targetPart.Position - LocalPlayer.Character.PrimaryPart.Position).Magnitude
                
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    
    return closestPlayer
end

local function aimLock()
    if not Config.AimLockEnabled or not LocalPlayer.Character then return end
    
    local target = getClosestPlayer()
    if target and target.Character then
        local targetPart = target.Character:FindFirstChild(Config.TargetPart)
        if targetPart then
            local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Config.Smoothness)
        end
    end
end

-- ============================================
-- SKYZEN UI ELEMENTS
-- ============================================

-- AIM LOCK SECTION
local AimSection = MainTab:CreateSection("🎯 AIM LOCK SETTINGS")

local AimToggle = MainTab:CreateToggle({
    Name = "Aim Lock Enabled",
    CurrentValue = false,
    Flag = "AimLockToggle",
    Callback = function(Value)
        Config.AimLockEnabled = Value
    end,
})

local TargetDropdown = MainTab:CreateDropdown({
    Name = "Target Part",
    Options = {"Head", "Torso", "RightHand"},
    CurrentOption = {"Head"},
    MultipleOptions = false,
    Flag = "TargetPartDropdown",
    Callback = function(Options)
        Config.TargetPart = Options[1]
    end,
})

local SmoothSlider = MainTab:CreateSlider({
    Name = "Aim Smoothness",
    Range = {0.01, 1},
    Increment = 0.01,
    Suffix = "x",
    CurrentValue = 0.1,
    Flag = "SmoothSlider",
    Callback = function(Value)
        Config.Smoothness = Value
    end,
})

local DistanceSlider = MainTab:CreateSlider({
    Name = "Max Distance",
    Range = {100, 1000},
    Increment = 50,
    Suffix = " studs",
    CurrentValue = 500,
    Flag = "DistanceSlider",
    Callback = function(Value)
        Config.MaxDistance = Value
    end,
})

-- ESP SECTION
local ESPSection = MainTab:CreateSection("👁️ ESP SETTINGS")

local ESPToggle = MainTab:CreateToggle({
    Name = "ESP Enabled",
    CurrentValue = true,
    Flag = "ESPToggle",
    Callback = function(Value)
        Config.ESPEnabled = Value
        if not Value then
            clearAllESP()
        end
    end,
})

local ESPDistanceSlider = MainTab:CreateSlider({
    Name = "ESP Render Distance",
    Range = {100, 2000},
    Increment = 100,
    Suffix = " studs",
    CurrentValue = 500,
    Flag = "ESPDistanceSlider",
    Callback = function(Value)
        Config.MaxDistance = Value
    end,
})

-- CONTROLS SECTION
local ControlsSection = MainTab:CreateSection("⌨️ KEYBOARD CONTROLS")

MainTab:CreateParagraph({
    Title = "Quick Shortcuts",
    Content = "E = Toggle Aim Lock\nR = Toggle ESP\nF = Toggle UI"
})

-- INFO SECTION
local InfoSection = MainTab:CreateSection("ℹ️ INFORMATION")

MainTab:CreateParagraph({
    Title = "Script Info",
    Content = "Arsenal Aimlock Universal v1.0\nPowered by SkyZen UI\nOptimized for performance"
})

-- ============================================
-- MAIN INITIALIZATION
-- ============================================

if not LocalPlayer.Character then
    LocalPlayer.CharacterAdded:Wait()
end

-- Keyboard Shortcuts
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.E then
        Config.AimLockEnabled = not Config.AimLockEnabled
        AimToggle:Set(Config.AimLockEnabled)
    elseif input.KeyCode == Enum.KeyCode.R then
        Config.ESPEnabled = not Config.ESPEnabled
        ESPToggle:Set(Config.ESPEnabled)
        if not Config.ESPEnabled then clearAllESP() end
    end
end)

-- ESP Update Loop
RunService.RenderStepped:Connect(function()
    local currentTime = tick()
    if currentTime - LastESPUpdate >= ESPUpdateInterval then
        updateESP()
        LastESPUpdate = currentTime
    end
end)

-- Aim Lock Loop
RunService.RenderStepped:Connect(function()
    aimLock()
end)

-- Player Events
Players.PlayerAdded:Connect(function(player)
    task.wait(0.2)
    if Config.ESPEnabled then
        createESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

print("✅ Arsenal Aimlock Universal (SkyZen) Loaded!")
print("E = Aim Lock Toggle")
print("R = ESP Toggle")
print("Check UI for more options")
