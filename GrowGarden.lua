--[[
    Grow Garden Ultimate Script (v3)
    
    Features:
    1. Auto Hatch: Select an egg and hatch until you get a Divine pet.
    2. Auto Collect Seeds: Collects seeds that spawn on the map.
    3. Auto Buy Seeds: Attempt to buy any seed from the shop, including "Candy Blossom".
       (NOTE: Requires enough in-game currency and the item must be obtainable on the server!)

    Executor: Delta Executor (Mobile Friendly)
]]

--================================================================================================================--
--  [ GUI Library - Orion ]
--================================================================================================================--
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "Grow Garden Ultimate", HidePremium = false, SaveConfig = true, ConfigFolder = "Orion_GrowGarden"})

--================================================================================================================--
--  [ Script Configuration & Variables ]
--================================================================================================================--
local Config = {
    HatchRemoteName = "Hatch",
    PetInventoryName = "Pets",
    PetRarityName = "Rarity",
    TargetRarity = "Divine",
    
    SeedNameOnGround = "Seed",
    CollectionWaitTime = 0.2,

    BuySeedRemoteName = "BuySeed",
    
    IsAutoHatching = false,
    IsAutoCollecting = false
}

local selectedEggName = "Common Egg"

--================================================================================================================--
--  [ Core Script Logic ]
--================================================================================================================--
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

local function notify(text)
    OrionLib:MakeNotification({ Name = "Script Notification", Content = text, Image = "rbxassetid://4483345998", Time = 5 })
end

--================================================================================================================--
--  [ Auto Hatch Tab ]
--================================================================================================================--
local HatchTab = Window:MakeTab({ Name = "Auto Hatch", Icon = "rbxassetid://6031049255" })

HatchTab:AddDropdown({
    Name = "Select Egg",
    Default = "Common Egg",
    Options = {"Common Egg", "Rare Egg", "Legendaries Egg", "Mythic Egg", "Bug Egg", "Anti Bee Egg", "Bee Egg"},
    Callback = function(Value) selectedEggName = Value end
})

local HatchStatusLabel = HatchTab:AddLabel("Status: Idle")

local HatchToggle = HatchTab:AddToggle({
    Name = "Auto Hatch for Divine",
    Default = false,
    Callback = function(Value)
        Config.IsAutoHatching = Value
        if not Value then HatchStatusLabel:Set("Status: Idle"); return end
        
        task.spawn(function()
            local hatchRemote = ReplicatedStorage:FindFirstChild(Config.HatchRemoteName, true)
            if not hatchRemote then notify("Error: Hatch Remote not found!"); Config.IsAutoHatching = false; if HatchToggle then HatchToggle:Set(false) end; return end
            HatchStatusLabel:Set("Status: Hatching " .. selectedEggName)
            while Config.IsAutoHatching do
                pcall(function() hatchRemote:FireServer(selectedEggName, 1) end)
                task.wait(0.5)
            end
        end)
    end
})

local petInventory = Player:WaitForChild(Config.PetInventoryName)
petInventory.ChildAdded:Connect(function(newPet)
    if Config.IsAutoHatching then
        local petRarity = newPet:WaitForChild(Config.PetRarityName, 5)
        if petRarity and petRarity.Value == Config.TargetRarity then
            Config.IsAutoHatching = false
            if HatchToggle then HatchToggle:Set(false) end
            HatchStatusLabel:Set("Status: Found a " .. Config.TargetRarity .. "!")
            notify("SUCCESS! You hatched a " .. Config.TargetRarity .. " pet!")
        elseif petRarity then
             HatchStatusLabel:Set("Status: Pet is a "..tostring(petRarity.Value))
        end
    end
end)

--================================================================================================================--
--  [ Auto Farm Tab ]
--================================================================================================================--
local FarmTab = Window:MakeTab({ Name = "Auto Farm", Icon = "rbxassetid://5793393959" })

FarmTab:AddLabel("Auto Buy From Shop"):SetColor(Color3.fromRGB(0, 255, 255))
local selectedSeedToBuy = "Carrot"
local seedBuyQuantity = 1

FarmTab:AddDropdown({
    Name = "Select Seed to Buy",
    Default = "Carrot",
    Options = {
        -- Common & Rare
        "Carrot", "Strawberry", "Blueberry", "Orange Tulip", "Tomato", "Daffodil", "Corn",
        -- Legendary & Mythical
        "Watermelon", "Pumpkin", "Apple", "Bamboo", "Coconut", "Cactus", "Dragon Fruit",
        "Mango",
        -- Divine & Prismatic
        "Mushroom", "Grape", "Pepper Seed", "Cacao", "Beanstalk", "Ember Lily",
        -- Special Seeds
        "Lavender Seed", "Nectarshade Seed",
        "Candy Blossom"
    },
    Callback = function(Value) selectedSeedToBuy = Value end
})

FarmTab:AddTextbox({
    Name = "Quantity to Buy",
    Default = "1",
    TextDisappear = false,
    Callback = function(value) seedBuyQuantity = tonumber(value) or 1 end
})

FarmTab:AddButton({
    Name = "Buy Selected Seed",
    Callback = function()
        local buyRemote = ReplicatedStorage:FindFirstChild(Config.BuySeedRemoteName, true)
        if not buyRemote then
            notify("Error: Could not find the Buy Seed Remote ('" .. Config.BuySeedRemoteName .. "').")
            return
        end
        
        notify("Attempting to buy " .. seedBuyQuantity .. "x " .. selectedSeedToBuy .. "...")
        pcall(function()
            buyRemote:FireServer(selectedSeedToBuy, seedBuyQuantity)
        end)
        notify("Purchase request sent to server.")
    end
})

FarmTab:AddDivider()

FarmTab:AddLabel("Auto Collect Spawned Seeds"):SetColor(Color3.fromRGB(0, 255, 255))

FarmTab:AddToggle({
    Name = "Auto Get Seeds on Ground",
    Default = false,
    Callback = function(Value)
        Config.IsAutoCollecting = Value
        task.spawn(function()
            if not Config.IsAutoCollecting then return end
            notify("Auto-collecting seeds from ground!")
            while Config.IsAutoCollecting do
                local humanoidRootPart = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    for i, v in pairs(Workspace:GetChildren()) do
                        if not Config.IsAutoCollecting then break end
                        if v.Name == Config.SeedNameOnGround and v:IsA("BasePart") then
                            humanoidRootPart.CFrame = v.CFrame * CFrame.new(0, 3, 0)
                            task.wait(Config.CollectionWaitTime)
                        end
                    end
                end
                task.wait(1)
            end
            notify("Stopped auto-collecting.")
        end)
    end
})

OrionLib:Init()
notify("Grow Garden Ultimate Script Loaded!")
