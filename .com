-- LocalScript Code --

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
screenGui.Name = "AdminPanel"

-- Create Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Parent = screenGui
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false  -- Start with the panel closed

-- Create Open/Close Button
local toggleButton = Instance.new("TextButton")
toggleButton.Parent = screenGui
toggleButton.Size = UDim2.new(0, 100, 0, 50)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.Text = "Open Admin Panel"
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
toggleButton.BorderSizePixel = 0

-- Toggle the admin panel visibility
toggleButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
    toggleButton.Text = mainFrame.Visible and "Close Admin Panel" or "Open Admin Panel"
end)

-- Create Search Box
local searchBox = Instance.new("TextBox")
searchBox.Parent = mainFrame
searchBox.Size = UDim2.new(0, 200, 0, 30)
searchBox.Position = UDim2.new(0, 10, 0, 10)
searchBox.PlaceholderText = "Search Command"
searchBox.Text = ""
searchBox.TextColor3 = Color3.new(1, 1, 1)
searchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
searchBox.BorderSizePixel = 0

-- Create Search Button
local searchButton = Instance.new("TextButton")
searchButton.Parent = mainFrame
searchButton.Size = UDim2.new(0, 70, 0, 30)
searchButton.Position = UDim2.new(0, 220, 0, 10)
searchButton.Text = "Search"
searchButton.TextColor3 = Color3.new(1, 1, 1)
searchButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
searchButton.BorderSizePixel = 0

-- Create Scrolling Frame for Command List
local commandList = Instance.new("ScrollingFrame")
commandList.Parent = mainFrame
commandList.Size = UDim2.new(0, 280, 0, 320)
commandList.Position = UDim2.new(0, 10, 0, 50)
commandList.CanvasSize = UDim2.new(0, 0, 0, 10 * 35)
commandList.ScrollBarThickness = 10
commandList.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
commandList.BorderSizePixel = 0

-- Admin Commands List
local adminCommands = {
    "kick",
    "teleport",
    "freeze",
    "unfreeze",
    "speed",
    "jumpPower",
    "godMode",
    "invisible",
    "visible",
}

-- Display Commands in the Scrolling Frame
local function displayCommands()
    commandList:ClearAllChildren()
    for _, command in ipairs(adminCommands) do
        local commandButton = Instance.new("TextButton")
        commandButton.Size = UDim2.new(1, 0, 0, 30)
        commandButton.Text = command
        commandButton.TextColor3 = Color3.new(1, 1, 1)
        commandButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        commandButton.BorderSizePixel = 0
        commandButton.Parent = commandList
    end
end

-- Display all commands initially
displayCommands()

-- Dynamically Create the Command Script
local commandScript = Instance.new("Script")
commandScript.Parent = game.ServerScriptService
commandScript.Name = "AdminCommandHandler"

-- Insert Code into the Created Script
commandScript.Source = [[
local Players = game:GetService("Players")

-- Function to get target players based on input
local function getTargetPlayers(target)
    if target == "me" then
        return {Players.LocalPlayer}  -- Reference to local player
    elseif target == "all" then
        return Players:GetPlayers()    -- All players in the game
    else
        local targetPlayer = Players:FindFirstChild(target)  -- Specific player by name
        if targetPlayer then
            return {targetPlayer}
        end
    end
    return {}
end

-- When a player joins the game
Players.PlayerAdded:Connect(function(player)
    -- Listen for chat messages
    player.Chatted:Connect(function(message)
        if message:sub(1, 1) == ";" then  -- Command prefix
            local splitMessage = message:sub(2):split(" ")
            local command = splitMessage[1]:lower()
            local target = splitMessage[2]:lower()
            local args = {unpack(splitMessage, 3)}

            local targetPlayers = getTargetPlayers(target)
            for _, targetPlayer in ipairs(targetPlayers) do
                if command == "kick" then
                    targetPlayer:Kick("You have been kicked.")
                elseif command == "freeze" then
                    for _, part in pairs(targetPlayer.Character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.Anchored = true
                        end
                    end
                elseif command == "unfreeze" then
                    for _, part in pairs(targetPlayer.Character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.Anchored = false
                        end
                    end
                -- Add additional command implementations here
                end
            end
        end
    end)
end)
]]

-- Display all commands initially
displayCommands()
