-- [[ GUGUHUB: PS99 RAID MASTER EDITION ]]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- [[ CONFIGURATION ]]
getgenv().Config = {
    AutoRaid = false,
    FastBreak = false,
    AutoTP = false,
    MaxTier = 25000,
    HeroicSwitches = {
        Lever1 = false,
        Lever2 = false,
        Lever3 = false
    },
    Chests = {
        Small = true,
        Big = true,
        Boss = true,
        Leprechaun = false
    }
}

-- [[ UI SETUP ]]
local Window = Rayfield:CreateWindow({
    Name = "GuguHub | Lucky Raid",
    LoadingTitle = "Loading Raid Modules...",
    ConfigurationSaving = { Enabled = true, Folder = "GuguPS99" }
})

-- [[ DRAGGABLE TOGGLE BUTTON ]]
local ScreenGui = Instance.new("ScreenGui")
local ToggleButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

ScreenGui.Name = "GuguToggle"
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

ToggleButton.Name = "MainButton"
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.Position = UDim2.new(0.85, 0, 0.85, 0) -- Right Corner
ToggleButton.Size = UDim2.new(0, 100, 0, 40)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "GuguHub"
ToggleButton.TextColor3 = Color3.fromRGB(0, 255, 127)
ToggleButton.TextSize = 14
ToggleButton.Active = true
ToggleButton.Draggable = true -- Make it moveable

UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    Rayfield:ToggleVisibility()
end)

-- [[ TABS ]]
local MainTab = Window:CreateTab("Main", 4483362458)
local ChestTab = Window:CreateTab("Chests", 4483362458)

-- [[ MAIN FUNCTIONS ]]
MainTab:CreateSection("Raid Automation")

MainTab:CreateToggle({
    Name = "Auto Start Raid (Max Tier)",
    CurrentValue = false,
    Callback = function(Value) 
        getgenv().Config.AutoRaid = Value 
        if Value then
            game:GetService("ReplicatedStorage").Network.Raid_Start:InvokeServer(getgenv().Config.MaxTier)
        end
    end,
})

MainTab:CreateToggle({
    Name = "Auto TP to Center",
    CurrentValue = false,
    Callback = function(Value) getgenv().Config.AutoTP = Value end,
})

MainTab:CreateToggle({
    Name = "Instant Fast Break",
    CurrentValue = false,
    Callback = function(Value) getgenv().Config.FastBreak = Value end,
})

MainTab:CreateSection("Heroic Levers")

MainTab:CreateToggle({
    Name = "Lever 1 (Zone 4)",
    CurrentValue = false,
    Callback = function(Value) getgenv().Config.HeroicSwitches.Lever1 = Value end,
})

MainTab:CreateToggle({
    Name = "Lever 2 (Zone 2)",
    CurrentValue = false,
    Callback = function(Value) getgenv().Config.HeroicSwitches.Lever2 = Value end,
})

-- [[ CHEST SELECTION ]]
ChestTab:CreateSection("Select Chests to Open")

for chestName, _ in pairs(getgenv().Config.Chests) do
    ChestTab:CreateToggle({
        Name = "Open " .. chestName .. " Chest",
        CurrentValue = getgenv().Config.Chests[chestName],
        Callback = function(Value) getgenv().Config.Chests[chestName] = Value end,
    })
end

-- [[ LOGIC LOOPS ]]

-- Fast Break Loop
task.spawn(function()
    while task.wait(0.1) do
        if getgenv().Config.FastBreak then
            local breakables = game.Workspace:FindFirstChild("Breakables")
            if breakables then
                for _, obj in pairs(breakables:GetChildren()) do
                    game:GetService("ReplicatedStorage").Network.Breakables_PlayerClick:FireServer(obj.Name)
                end
            end
        end
    end
end)

-- Auto Teleport Loop
task.spawn(function()
    while task.wait(1) do
        if getgenv().Config.AutoTP then
            local raidMap = game.Workspace:FindFirstChild("RaidMap")
            if raidMap then
                local center = raidMap:FindFirstChild("CenterPart") -- Adjust based on exact map name
                if center then
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = center.CFrame
                end
            end
        end
    end
end)

-- Anti-AFK
local VU = game:GetService("VirtualUser")
game.Players.LocalPlayer.Idled:Connect(function()
    VU:CaptureController()
    VU:ClickButton2(Vector2.new(0,0))
end)

Rayfield:LoadConfiguration()