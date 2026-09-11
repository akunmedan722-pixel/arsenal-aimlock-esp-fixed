-- Arsenal Aim Lock + ESP Loader
-- Usage: loadstring(game:HttpGet('https://raw.githubusercontent.com/akunmedan722-pixel/arsenal-aimlock-esp-fixed/main/arsenal-aimlock-esp-lite.lua'))()

--[[
    ARSENAL AIM LOCK + ESP SCRIPT (LIGHTWEIGHT VERSION)
    ====================================================
    Optimized untuk performa maksimal dengan resource minimal
    Features:
    - Aim Lock dengan target selection (Head, Body, Hand)
    - ESP toggle (ON/OFF)
    - Draggable UI
    - Lightweight & Fast
    - Keyboard shortcuts (E, R, F)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

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
local ESPUpdateInterval = 0.5 -- Update ESP setiap 0.5 detik

-- UI References
local MainGUI = nil
local UIDragging = false
local DragStart = nil

-- Colors (Minimalist)
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
-- UTILITY FUNCTIONS
-- ============================================

local function round(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = object
end

local function addStroke(object, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness
    stroke.Transparency = 0.3
    stroke.Parent = object
end

-- ============================================
-- ESP FUNCTIONS
-- ============================================

local function createESP(player)
    if player == LocalPlayer or ESPObjects[player] then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    -- Box Adornment
    local espBox = Instance.new("BoxHandleAdornment")
    espBox.Size = Vector3.new(3, 5, 3)
    espBox.Color3 = Colors.Primary
    espBox.Transparency = 0.3
    espBox.AlwaysOnTop = true
    espBox.Parent = humanoidRootPart
    
    -- Billboard Label
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
    round(textLabel, 6)
    addStroke(textLabel, Colors.Success, 1.5)
    
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
-- UI CREATION (MINIMAL)
-- ============================================

local function createUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "ArsenalLite"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = PlayerGui
    
    -- Main Container (Compact)
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.fromOffset(350, 280)
    container.Position = UDim2.fromOffset(20, 20)
    container.BackgroundColor3 = Colors.Background
    container.BorderSizePixel = 0
    container.Parent = gui
    round(container, 12)
    addStroke(container, Colors.Primary, 2)
    
    -- Header (Draggable)
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0.12, 0)
    header.BackgroundColor3 = Colors.Card
    header.BorderSizePixel = 0
    header.Parent = container
    round(header, 12)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 1, 0)
    title.Position = UDim2.fromOffset(10, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚡ ARSENAL LITE"
    title.TextColor3 = Colors.Primary
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    -- Content Area
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 0.88, 0)
    content.Position = UDim2.fromScale(0, 0.12)
    content.BackgroundTransparency = 1
    content.Parent = container
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.Parent = content
    
    -- Aim Lock Section
    local aimLabel = Instance.new("TextLabel")
    aimLabel.Size = UDim2.new(1, 0, 0.15, 0)
    aimLabel.BackgroundTransparency = 1
    aimLabel.Text = "🎯 AIM LOCK"
    aimLabel.TextColor3 = Colors.Text
    aimLabel.TextSize = 12
    aimLabel.Font = Enum.Font.GothamBold
    aimLabel.TextXAlignment = Enum.TextXAlignment.Left
    aimLabel.Parent = content
    
    local aimToggle = Instance.new("TextButton")
    aimToggle.Name = "AimToggle"
    aimToggle.Size = UDim2.new(0.48, 0, 0.2, 0)
    aimToggle.Position = UDim2.fromOffset(0, 22)
    aimToggle.BackgroundColor3 = Colors.Error
    aimToggle.BackgroundTransparency = 0.3
    aimToggle.BorderSizePixel = 0
    aimToggle.Text = "OFF"
    aimToggle.TextColor3 = Colors.Text
    aimToggle.TextSize = 11
    aimToggle.Font = Enum.Font.GothamBold
    aimToggle.Parent = content
    round(aimToggle, 5)
    addStroke(aimToggle, Colors.Error, 1.5)
    
    local targetLabel = Instance.new("TextLabel")
    targetLabel.Size = UDim2.new(0.48, 0, 0.2, 0)
    targetLabel.Position = UDim2.fromScale(0.52, 0.08)
    targetLabel.BackgroundColor3 = Colors.Card
    targetLabel.BackgroundTransparency = 0.3
    targetLabel.BorderSizePixel = 0
    targetLabel.Text = "Target: Head"
    targetLabel.TextColor3 = Colors.Muted
    targetLabel.TextSize = 10
    targetLabel.Font = Enum.Font.GothamBold
    targetLabel.Parent = content
    round(targetLabel, 5)
    
    -- Target Selection
    local targetContainer = Instance.new("Frame")
    targetContainer.Size = UDim2.new(1, 0, 0.22, 0)
    targetContainer.Position = UDim2.fromOffset(0, 48)
    targetContainer.BackgroundTransparency = 1
    targetContainer.Parent = content
    
    local targetLayout = Instance.new("UIListLayout")
    targetLayout.FillDirection = Enum.FillDirection.Horizontal
    targetLayout.Padding = UDim.new(0, 5)
    targetLayout.Parent = targetContainer
    
    local targets = {"Head", "Torso", "RightHand"}
    local targetKeys = {"Head", "Torso", "RightHand"}
    
    for i, target in ipairs(targets) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.31, 0, 1, 0)
        btn.BackgroundColor3 = (i == 1) and Colors.Primary or Colors.Card
        btn.BackgroundTransparency = (i == 1) and 0.2 or 0.5
        btn.BorderSizePixel = 0
        btn.Text = target:sub(1, 1)
        btn.TextColor3 = Colors.Text
        btn.TextSize = 10
        btn.Font = Enum.Font.GothamBold
        btn.Parent = targetContainer
        round(btn, 4)
        addStroke(btn, Colors.Primary, 1)
        
        btn.MouseButton1Click:Connect(function()
            Config.TargetPart = targetKeys[i]
            targetLabel.Text = "Target: " .. target
            for j, child in ipairs(targetContainer:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundColor3 = (child == btn) and Colors.Primary or Colors.Card
                    child.BackgroundTransparency = (child == btn) and 0.2 or 0.5
                end
            end
        end)
    end
    
    -- ESP Section
    local espLabel = Instance.new("TextLabel")
    espLabel.Size = UDim2.new(1, 0, 0.12, 0)
    espLabel.Position = UDim2.fromOffset(0, 75)
    espLabel.BackgroundTransparency = 1
    espLabel.Text = "👁️ ESP"
    espLabel.TextColor3 = Colors.Text
    espLabel.TextSize = 12
    espLabel.Font = Enum.Font.GothamBold
    espLabel.TextXAlignment = Enum.TextXAlignment.Left
    espLabel.Parent = content
    
    local espToggle = Instance.new("TextButton")
    espToggle.Name = "ESPToggle"
    espToggle.Size = UDim2.new(1, 0, 0.22, 0)
    espToggle.Position = UDim2.fromOffset(0, 92)
    espToggle.BackgroundColor3 = Colors.Success
    espToggle.BackgroundTransparency = 0.2
    espToggle.BorderSizePixel = 0
    espToggle.Text = "ON"
    espToggle.TextColor3 = Colors.Text
    espToggle.TextSize = 11
    espToggle.Font = Enum.Font.GothamBold
    espToggle.Parent = content
    round(espToggle, 5)
    addStroke(espToggle, Colors.Success, 1.5)
    
    -- Max Distance Slider
    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(0.7, 0, 0.12, 0)
    distLabel.Position = UDim2.fromOffset(0, 120)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "Max Range: 500"
    distLabel.TextColor3 = Colors.Muted
    distLabel.TextSize = 9
    distLabel.Font = Enum.Font.GothamMedium
    distLabel.TextXAlignment = Enum.TextXAlignment.Left
    distLabel.Parent = content
    
    -- Info Text
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, 0, 0.15, 0)
    info.Position = UDim2.fromOffset(0, 135)
    info.BackgroundTransparency = 1
    info.Text = "E: Aim | R: ESP | F: Toggle"
    info.TextColor3 = Colors.Muted
    info.TextSize = 8
    info.Font = Enum.Font.GothamMedium
    info.TextWrapped = true
    info.Parent = content
    
    -- Button Events
    aimToggle.MouseButton1Click:Connect(function()
        Config.AimLockEnabled = not Config.AimLockEnabled
        if Config.AimLockEnabled then
            aimToggle.Text = "ON"
            aimToggle.BackgroundColor3 = Colors.Success
            aimToggle.BackgroundTransparency = 0.2
            addStroke(aimToggle, Colors.Success, 1.5)
        else
            aimToggle.Text = "OFF"
            aimToggle.BackgroundColor3 = Colors.Error
            aimToggle.BackgroundTransparency = 0.3
            addStroke(aimToggle, Colors.Error, 1.5)
        end
    end)
    
    espToggle.MouseButton1Click:Connect(function()
        Config.ESPEnabled = not Config.ESPEnabled
        if Config.ESPEnabled then
            espToggle.Text = "ON"
            espToggle.BackgroundColor3 = Colors.Success
        else
            espToggle.Text = "OFF"
            espToggle.BackgroundColor3 = Colors.Error
            clearAllESP()
        end
    end)
    
    -- Drag Functionality
    header.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            UIDragging = true
            DragStart = UserInputService:GetMouseLocation()
            local startPos = container.Position
            
            local connection
            connection = RunService.RenderStepped:Connect(function()
                if UIDragging then
                    local currentMouse = UserInputService:GetMouseLocation()
                    local delta = currentMouse - DragStart
                    container.Position = UDim2.fromOffset(
                        startPos.X.Offset + delta.X,
                        startPos.Y.Offset + delta.Y
                    )
                else
                    connection:Disconnect()
                end
            end)
        end
    end)
    
    header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            UIDragging = false
        end
    end)
    
    return gui
end

-- ============================================
-- MAIN INITIALIZATION
-- ============================================

-- Wait for character
if not LocalPlayer.Character then
    LocalPlayer.CharacterAdded:Wait()
end

-- Create UI
MainGUI = createUI()

-- Keyboard Shortcuts
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.E then
        Config.AimLockEnabled = not Config.AimLockEnabled
    elseif input.KeyCode == Enum.KeyCode.R then
        Config.ESPEnabled = not Config.ESPEnabled
        if not Config.ESPEnabled then clearAllESP() end
    elseif input.KeyCode == Enum.KeyCode.F then
        if MainGUI then
            MainGUI:Destroy()
            MainGUI = nil
        else
            MainGUI = createUI()
        end
    end
end)

-- ESP Update Loop (Optimized - setiap 0.5 detik)
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

print("✅ Arsenal Lite Loaded!")
print("E = Aim Lock Toggle")
print("R = ESP Toggle")
print("F = Toggle UI")
