--[[
    Grow Garden Script (v5 - Custom GUI)
    - Built from scratch without any external libraries to ensure compatibility.
    - Click and drag the top bar to move the GUI.
]]

-- ===================================================================
--  CORE VARIABLES & STATE
-- ===================================================================
local isAutoHatching = false
local isAutoCollecting = false
local selectedEggName = "Common Egg"

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

-- ===================================================================
--  CORE FUNCTIONS (HATCHING & COLLECTING)
-- ===================================================================

-- Find a GUI element by name (to update labels, etc.)
local GUI
local function FindGUI(name)
    if GUI and GUI:FindFirstChild(name, true) then
        return GUI:FindFirstChild(name, true)
    end
    return nil
end

-- Auto-Hatch Loop
local function StartHatchLoop()
    task.spawn(function()
        local hatchRemote = ReplicatedStorage:FindFirstChild("Hatch", true)
        if not hatchRemote then
            if FindGUI("HatchStatusLabel") then FindGUI("HatchStatusLabel").Text = "Error: Hatch Remote not found!" end
            return
        end
        
        while isAutoHatching do
            if FindGUI("HatchStatusLabel") then FindGUI("HatchStatusLabel").Text = "Hatching: " .. selectedEggName end
            pcall(function() hatchRemote:FireServer(selectedEggName, 1) end)
            task.wait(0.5)
        end
        if FindGUI("HatchStatusLabel") then FindGUI("HatchStatusLabel").Text = "Stopped." end
    end)
end

-- Auto-Collect Loop
local function StartCollectLoop()
    task.spawn(function()
        while isAutoCollecting do
            if FindGUI("CollectStatusLabel") then FindGUI("CollectStatusLabel").Text = "Status: Searching for seeds..." end
            local humanoidRootPart = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local foundSeed = false
                for _, v in pairs(Workspace:GetChildren()) do
                    if not isAutoCollecting then break end
                    if v.Name == "Seed" and v:IsA("BasePart") then
                        foundSeed = true
                        humanoidRootPart.CFrame = v.CFrame * CFrame.new(0, 3, 0)
                        task.wait(0.2)
                    end
                end
                if not foundSeed and FindGUI("CollectStatusLabel") then FindGUI("CollectStatusLabel").Text = "Status: No seeds found. Waiting..." end
            end
            task.wait(1)
        end
        if FindGUI("CollectStatusLabel") then FindGUI("CollectStatusLabel").Text = "Status: Stopped." end
    end)
end

-- Listen for new pets to stop hatching
local petInventory = Player:WaitForChild("Pets")
petInventory.ChildAdded:Connect(function(newPet)
    if isAutoHatching then
        local petRarity = newPet:WaitForChild("Rarity", 5)
        if petRarity then
            if FindGUI("HatchStatusLabel") then FindGUI("HatchStatusLabel").Text = "Hatched: "..tostring(petRarity.Value) end
            if petRarity.Value == "Divine" then
                isAutoHatching = false
                local hatchButton = FindGUI("HatchToggleButton")
                if hatchButton then
                    hatchButton.Text = "Auto Hatch Divine"
                    hatchButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
                end
                if FindGUI("HatchStatusLabel") then FindGUI("HatchStatusLabel").Text = "SUCCESS! Found Divine!" end
            end
        end
    end
end)


-- ===================================================================
--  CUSTOM GUI CREATION (NO LIBRARIES)
-- ===================================================================

GUI = Instance.new("ScreenGui")
GUI.Name = "CustomGrowGardenGUI"
GUI.Parent = game:GetService("CoreGui")
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = GUI
MainFrame.Size = UDim2.new(0, 300, 0, 200)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
MainFrame.BorderSizePixel = 2
MainFrame.Active = true
MainFrame.Draggable = true -- Allows dragging

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = MainFrame
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = TitleBar
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Text = "Grow Garden Script"
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 16

-- == HATCHING SECTION ==
local HatchLabel = Instance.new("TextLabel")
HatchLabel.Name = "HatchLabel"
HatchLabel.Parent = MainFrame
HatchLabel.Size = UDim2.new(1, -20, 0, 20)
HatchLabel.Position = UDim2.new(0, 10, 0, 40)
HatchLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
HatchLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
HatchLabel.Text = "Selected Egg: " .. selectedEggName
HatchLabel.TextXAlignment = Enum.TextXAlignment.Left
HatchLabel.Font = Enum.Font.SourceSans

-- Manual Dropdown (it's just a button that cycles through the list)
local EggCycleButton = Instance.new("TextButton")
EggCycleButton.Name = "EggCycleButton"
EggCycleButton.Parent = MainFrame
EggCycleButton.Size = UDim2.new(1, -20, 0, 25)
EggCycleButton.Position = UDim2.new(0, 10, 0, 65)
EggCycleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
EggCycleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
EggCycleButton.Text = "Change Egg"
EggCycleButton.Font = Enum.Font.SourceSansSemibold

local eggList = {"Common Egg", "Rare Egg", "Legendaries Egg", "Mythic Egg", "Bug Egg", "Anti Bee Egg", "Bee Egg"}
local currentEggIndex = 1
EggCycleButton.MouseButton1Click:Connect(function()
    currentEggIndex = currentEggIndex + 1
    if currentEggIndex > #eggList then currentEggIndex = 1 end
    selectedEggName = eggList[currentEggIndex]
    HatchLabel.Text = "Selected Egg: " .. selectedEggName
end)

local HatchToggleButton = Instance.new("TextButton")
HatchToggleButton.Name = "HatchToggleButton"
HatchToggleButton.Parent = MainFrame
HatchToggleButton.Size = UDim2.new(0.5, -15, 0, 30)
HatchToggleButton.Position = UDim2.new(0, 10, 0, 100)
HatchToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0) -- Green
HatchToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
HatchToggleButton.Text = "Auto Hatch Divine"
HatchToggleButton.Font = Enum.Font.SourceSansBold

local HatchStatusLabel = Instance.new("TextLabel")
HatchStatusLabel.Name = "HatchStatusLabel"
HatchStatusLabel.Parent = MainFrame
HatchStatusLabel.Size = UDim2.new(0.5, -15, 0, 30)
HatchStatusLabel.Position = UDim2.new(0.5, 5, 0, 100)
HatchStatusLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
HatchStatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
HatchStatusLabel.Text = "Stopped."
HatchStatusLabel.Font = Enum.Font.SourceSans

HatchToggleButton.MouseButton1Click:Connect(function()
    isAutoHatching = not isAutoHatching
    if isAutoHatching then
        HatchToggleButton.Text = "STOP HATCHING"
        HatchToggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0) -- Red
        StartHatchLoop()
    else
        HatchToggleButton.Text = "Auto Hatch Divine"
        HatchToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0) -- Green
    end
end)


-- == SEED COLLECTION SECTION ==
local Divider = Instance.new("Frame")
Divider.Parent = MainFrame
Divider.Size = UDim2.new(1, -20, 0, 2)
Divider.Position = UDim2.new(0, 10, 0, 140)
Divider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

local CollectToggleButton = Instance.new("TextButton")
CollectToggleButton.Name = "CollectToggleButton"
CollectToggleButton.Parent = MainFrame
CollectToggleButton.Size = UDim2.new(0.5, -15, 0, 30)
CollectToggleButton.Position = UDim2.new(0, 10, 0, 150)
CollectToggleButton.BackgroundColor3 = Color3.fromRGB(0, 85, 170) -- Blue
CollectToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CollectToggleButton.Text = "Auto Get Seeds"
CollectToggleButton.Font = Enum.Font.SourceSansBold

local CollectStatusLabel = Instance.new("TextLabel")
CollectStatusLabel.Name = "CollectStatusLabel"
CollectStatusLabel.Parent = MainFrame
CollectStatusLabel.Size = UDim2.new(0.5, -15, 0, 30)
CollectStatusLabel.Position = UDim2.new(0.5, 5, 0, 150)
CollectStatusLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
CollectStatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
CollectStatusLabel.Text = "Status: Stopped."
CollectStatusLabel.Font = Enum.Font.SourceSans

CollectToggleButton.MouseButton1Click:Connect(function()
    isAutoCollecting = not isAutoCollecting
    if isAutoCollecting then
        CollectToggleButton.Text = "STOP COLLECTING"
        CollectToggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0) -- Red
        StartCollectLoop()
    else
        CollectToggleButton.Text = "Auto Get Seeds"
        CollectToggleButton.BackgroundColor3 = Color3.fromRGB(0, 85, 170) -- Blue
    end
end)
