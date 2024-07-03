local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local Title = Instance.new("TextLabel")
local CloseButton = Instance.new("TextButton")
local ButtonsFrame = Instance.new("Frame")
local UIListLayout = Instance.new("UIListLayout")
local EspButton = Instance.new("TextButton")
local RefreshButton = Instance.new("TextButton")
local TeleportButton = Instance.new("TextButton")
local FollowPlayerButton = Instance.new("TextButton")
local PlayerListFrame = Instance.new("Frame")
local PlayerList = Instance.new("ScrollingFrame")
local UIListLayout_PlayerList = Instance.new("UIListLayout")

-- Function to create a button
local function CreateButton(name, parent)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Parent = parent
    button.BackgroundColor3 = Color3.fromRGB(114, 137, 218)
    button.Size = UDim2.new(1, -10, 0, 40)
    button.Font = Enum.Font.GothamSemibold
    button.Text = name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.AutoButtonColor = false

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = button

    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(103, 123, 196)}):Play()
    end)

    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(114, 137, 218)}):Play()
    end)

    return button
end

-- Setup ScreenGui
ScreenGui.Name = "ScriptUI"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

-- Main Frame
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(54, 57, 63)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -150)
MainFrame.Size = UDim2.new(0, 250, 0, 300)
MainFrame.ClipsDescendants = true

UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Title
Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 10, 0, 5)
Title.Size = UDim2.new(1, -50, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "Script UI"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Close Button
CloseButton.Name = "CloseButton"
CloseButton.Parent = MainFrame
CloseButton.BackgroundColor3 = Color3.fromRGB(240, 71, 71)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 15)
closeCorner.Parent = CloseButton

-- Buttons Frame
ButtonsFrame.Name = "ButtonsFrame"
ButtonsFrame.Parent = MainFrame
ButtonsFrame.BackgroundTransparency = 1
ButtonsFrame.Position = UDim2.new(0, 5, 0, 40)
ButtonsFrame.Size = UDim2.new(1, -10, 0, 200)

UIListLayout.Parent = ButtonsFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

-- Create Buttons
EspButton = CreateButton("Toggle ESP", ButtonsFrame)
RefreshButton = CreateButton("Refresh", ButtonsFrame)
TeleportButton = CreateButton("Teleport", ButtonsFrame)
FollowPlayerButton = CreateButton("Follow Player", ButtonsFrame)

-- Player List Frame
PlayerListFrame.Name = "PlayerListFrame"
PlayerListFrame.Parent = MainFrame
PlayerListFrame.BackgroundColor3 = Color3.fromRGB(47, 49, 54)
PlayerListFrame.Position = UDim2.new(0, 5, 1, -55)
PlayerListFrame.Size = UDim2.new(1, -10, 0, 50)

local playerListCorner = Instance.new("UICorner")
playerListCorner.CornerRadius = UDim.new(0, 8)
playerListCorner.Parent = PlayerListFrame

PlayerList.Name = "PlayerList"
PlayerList.Parent = PlayerListFrame
PlayerList.BackgroundTransparency = 1
PlayerList.Size = UDim2.new(1, 0, 1, 0)
PlayerList.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerList.ScrollBarThickness = 4

UIListLayout_PlayerList.Parent = PlayerList
UIListLayout_PlayerList.SortOrder = Enum.SortOrder.Name
UIListLayout_PlayerList.Padding = UDim.new(0, 2)

local espEnabled = false
local espObjects = {}
local followedPlayer = nil
local followConnection = nil
local isTeleporting = false
local originalPosition = nil

local function createESP(player)
    if not player.Character then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = player.Name .. "_ESP"
    highlight.Parent = game.CoreGui
    highlight.Adornee = player.Character
    highlight.FillColor = Color3.fromRGB(0, 255, 0)
    highlight.OutlineTransparency = 1
    table.insert(espObjects, highlight)

    local nameTag = Instance.new("BillboardGui")
    nameTag.Name = player.Name .. "_NameTag"
    nameTag.Parent = game.CoreGui
    nameTag.Adornee = player.Character:WaitForChild("Head")
    nameTag.Size = UDim2.new(0, 200, 0, 50)
    nameTag.StudsOffset = Vector3.new(0, 2, 0)
    nameTag.AlwaysOnTop = true

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Parent = nameTag
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextScaled = true

    local toolLabel = Instance.new("TextLabel")
    toolLabel.Parent = nameTag
    toolLabel.Size = UDim2.new(1, 0, 0.5, 0)
    toolLabel.Position = UDim2.new(0, 0, 0.5, 0)
    toolLabel.BackgroundTransparency = 1
    toolLabel.Text = ""
    toolLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    toolLabel.TextScaled = true
end

local function removeESP(player)
    local espObject = game.CoreGui:FindFirstChild(player.Name .. "_ESP")
    if espObject then
        espObject:Destroy()
    end
    local nameTag = game.CoreGui:FindFirstChild(player.Name .. "_NameTag")
    if nameTag then
        nameTag:Destroy()
    end
end

local function updatePlayerList()
    for _, child in pairs(PlayerList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            local playerButton = Instance.new("TextButton")
            playerButton.Parent = PlayerList
            playerButton.BackgroundColor3 = Color3.fromRGB(114, 137, 218)
            playerButton.Size = UDim2.new(1, -10, 0, 30)
            playerButton.Font = Enum.Font.Gotham
            playerButton.Text = player.Name
            playerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            playerButton.TextSize = 14
            playerButton.MouseButton1Click:Connect(function()
                TeleportTextBox.Text = player.Name
            end)
        end
    end
end

local function teleportToPlayer(targetName)
    local targetPlayer = Players:FindFirstChild(targetName)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetRootPart = targetPlayer.Character.HumanoidRootPart
        
        if Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local localRootPart = Players.LocalPlayer.Character.HumanoidRootPart
            
            if not isTeleporting then
                local originalPosition = localRootPart.CFrame
                local originalVelocity = localRootPart.Velocity
                local originalAngularVelocity = localRootPart.AngularVelocity
                
                localRootPart.CFrame = targetRootPart.CFrame
                localRootPart.Velocity = targetRootPart.Velocity
                localRootPart.AngularVelocity = targetRootPart.AngularVelocity
                
                isTeleporting = true
                TeleportButton.Text = "Undo Teleport"
                
                task.spawn(function()
                    wait(0.1)
                    localRootPart.Velocity = originalVelocity
                    localRootPart.AngularVelocity = originalAngularVelocity
                end)
            else
                localRootPart.CFrame = originalPosition
                isTeleporting = false
                TeleportButton.Text = "Teleport"
            end
        end
    end
end

local function followPlayer(targetName)
    if followConnection then
        followConnection:Disconnect()
        followConnection = nil
        followedPlayer = nil
        FollowPlayerButton.Text = "Follow Player"
        return
    end

    followedPlayer = Players:FindFirstChild(targetName)
    if followedPlayer and followedPlayer ~= Players.LocalPlayer then
        FollowPlayerButton.Text = "Stop Following"
        followConnection = RunService.Heartbeat:Connect(function()
            if followedPlayer and followedPlayer.Character and followedPlayer.Character:FindFirstChild("HumanoidRootPart") and
               Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                Players.LocalPlayer.Character.HumanoidRootPart.CFrame = followedPlayer.Character.HumanoidRootPart.CFrame
            end
        end)
    end
end

local function toggleESP()
    espEnabled = not espEnabled
    if espEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer then
                createESP(player)
            end
        end
    else
        for _, espObject in pairs(espObjects) do
            if espObject then
                espObject:Destroy()
            end
        end
        espObjects = {}
    end
end

local function refreshScript()
    toggleESP()
    toggleESP()
    updatePlayerList()
end

local function updateToolDisplay(player)
    local nameTag = game.CoreGui:FindFirstChild(player.Name .. "_NameTag")
    if nameTag then
        local toolLabel = nameTag:FindFirstChild("TextLabel", true)
        if toolLabel and player.Character then
            local tool = player.Character:FindFirstChildOfClass("Tool")
            if tool then
                toolLabel.Text = tool.Name
            else
                toolLabel.Text = ""
            end
        end
    end
end

EspButton.MouseButton1Click:Connect(toggleESP)
RefreshButton.MouseButton1Click:Connect(refreshScript)
TeleportButton.MouseButton1Click:Connect(function()
    teleportToPlayer(TeleportTextBox.Text)
end)
FollowPlayerButton.MouseButton1Click:Connect(function()
    followPlayer(TeleportTextBox.Text)
end)
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

Players.PlayerAdded:Connect(function(player)
    if espEnabled then
        createESP(player)
    end
    updatePlayerList()
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
    updatePlayerList()
    if player == followedPlayer then
        followConnection:Disconnect()
        followConnection = nil
        followedPlayer = nil
        FollowPlayerButton.Text = "Follow Player"
    end
end)

RunService.RenderStepped:Connect(function()
    if espEnabled then
        for _, highlight in pairs(espObjects) do
            if highlight.Adornee then
                local player = Players:GetPlayerFromCharacter(highlight.Adornee)
                if player then
                    local distance = (Players.LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).magnitude
                    highlight.FillTransparency = math.clamp(1 - distance / 500, 0, 1)
                    highlight.FillColor = Color3.fromHSV(distance / 500, 1, 1) -- Changes color based on distance
                    local nameTag = game.CoreGui:FindFirstChild(player.Name .. "_NameTag")
                    if nameTag then
                        nameTag.Size = UDim2.new(0, math.clamp(200 / (distance / 10), 50, 200), 0, math.clamp(50 / (distance / 10), 25, 50))
                    end
                    updateToolDisplay(player)
                end
            end
        end
    end
end)

-- Make the GUI draggable for both mouse and touch input
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Initialize the script
updatePlayerList()

-- Add touch support for scrolling on mobile devices
local function onTouchScroll(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.Touch and input.UserInputState == Enum.UserInputState.Change then
        local delta = -input.Position.Y + input.StartPosition.Y
        PlayerList.CanvasPosition = Vector2.new(0, PlayerList.CanvasPosition.Y + delta)
    end
end

PlayerList.TouchPan:Connect(onTouchScroll)

-- Add button effects for better mobile experience
local function addButtonEffect(button)
    button.MouseButton1Down:Connect(function()
        button.BackgroundColor3 = button.BackgroundColor3:Lerp(Color3.new(1, 1, 1), 0.2)
    end)
    button.MouseButton1Up:Connect(function()
        button.BackgroundColor3 = button.BackgroundColor3:Lerp(Color3.new(0, 0, 0), 0.2)
    end)
end

addButtonEffect(EspButton)
addButtonEffect(RefreshButton)
addButtonEffect(TeleportButton)
addButtonEffect(FollowPlayerButton)
addButtonEffect(CloseButton)

-- Adjust GUI for different screen sizes
local function onResize()
    local screenSize = workspace.CurrentCamera.ViewportSize
    if screenSize.X < 600 then  -- For smaller screens (e.g., mobile devices)
        MainFrame.Size = UDim2.new(0.9, 0, 0.7, 0)
        MainFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
    else  -- For larger screens
        MainFrame.Size = UDim2.new(0, 300, 0, 400)
        MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    end
end

workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(onResize)
onResize()  -- Call once to set initial size

-- Function to create a notification
local function createNotification(message, duration)
    local notification = Instance.new("TextLabel")
    notification.Parent = ScreenGui
    notification.BackgroundColor3 = Color3.fromRGB(44, 47, 51)
    notification.TextColor3 = Color3.fromRGB(255, 255, 255)
    notification.Size = UDim2.new(0, 200, 0, 50)
    notification.Position = UDim2.new(0.5, -100, 0.9, 0)
    notification.Text = message
    notification.TextWrapped = true
    notification.TextSize = 14
    notification.Font = Enum.Font.Gotham

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = notification

    -- Animate the notification
    notification.Position = UDim2.new(0.5, -100, 1, 0)
    local tween = TweenService:Create(notification, TweenInfo.new(0.5), {Position = UDim2.new(0.5, -100, 0.9, 0)})
    tween:Play()

    -- Remove the notification after the duration
    task.delay(duration, function()
        local fadeTween = TweenService:Create(notification, TweenInfo.new(0.5), {TextTransparency = 1, BackgroundTransparency = 1})
        fadeTween:Play()
        fadeTween.Completed:Connect(function()
            notification:Destroy()
        end)
    end)
end

-- Add notifications for actions
EspButton.MouseButton1Click:Connect(function()
    createNotification(espEnabled and "ESP Enabled" or "ESP Disabled", 2)
end)

TeleportButton.MouseButton1Click:Connect(function()
    createNotification(isTeleporting and "Teleported to " .. TeleportTextBox.Text or "Returned to original position", 2)
end)

FollowPlayerButton.MouseButton1Click:Connect(function()
    createNotification(followedPlayer and "Following " .. followedPlayer.Name or "Stopped following", 2)
end)

-- Make textbox more mobile-friendly
TeleportTextBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        teleportToPlayer(TeleportTextBox.Text)
    end
end)

-- Add a feature to hide/show the GUI
local hidden = false
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 50, 0, 50)
toggleButton.Position = UDim2.new(1, -60, 0, 10)
toggleButton.AnchorPoint = Vector2.new(1, 0)
toggleButton.Parent = ScreenGui
toggleButton.Text = "≡"
toggleButton.TextSize = 30
toggleButton.Font = Enum.Font.GothamBold
toggleButton.BackgroundColor3 = Color3.fromRGB(54, 57, 63)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)

local cornerToggle = Instance.new("UICorner")
cornerToggle.CornerRadius = UDim.new(0, 10)
cornerToggle.Parent = toggleButton

toggleButton.MouseButton1Click:Connect(function()
    hidden = not hidden
    MainFrame.Visible = not hidden
    toggleButton.Text = hidden and "+" or "≡"
end)

addButtonEffect(toggleButton)
