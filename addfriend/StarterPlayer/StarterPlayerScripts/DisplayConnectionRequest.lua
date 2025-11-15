-- LocalScript in StarterPlayer/StarterPlayerScripts/
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for GUI
local requestGui = playerGui:WaitForChild("ConnectionRequestGui")
local requestFrame = requestGui:WaitForChild("RequestFrame")
local playerNameLabel = requestFrame:WaitForChild("PlayerNameLabel")
local messageLabel = requestFrame:WaitForChild("MessageLabel")
local acceptButton = requestFrame:WaitForChild("AcceptButton")
local declineButton = requestFrame:WaitForChild("DeclineButton")

-- Get RemoteEvents
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local friendRequestEvent = remoteEvents:WaitForChild("FriendRequest")
local friendResponseEvent = remoteEvents:WaitForChild("FriendRequestResponse")

-- Store current request
local currentRequest = nil

-- Animation tweens
local function showRequest()
    requestFrame.Visible = true
    requestFrame.Position = UDim2.new(0.5, 0, 1.5, 0) -- Start below screen
    
    local tween = TweenService:Create(
        requestFrame,
        TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = UDim2.new(0.5, 0, 0.5, 0)}
    )
    tween:Play()
end

local function hideRequest()
    local tween = TweenService:Create(
        requestFrame,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {Position = UDim2.new(0.5, 0, 1.5, 0)}
    )
    tween:Play()
    tween.Completed:Wait()
    requestFrame.Visible = false
    currentRequest = nil
end

-- Listen for incoming requests
friendRequestEvent.OnClientEvent:Connect(function(sender)
    if not sender or not sender:IsA("Player") then
        warn("Invalid sender in request")
        return
    end
    
    -- If already showing a request, queue or ignore
    if currentRequest then
        warn("Already displaying a request. Ignoring new one from " .. sender.Name)
        return
    end
    
    -- Store sender
    currentRequest = sender
    
    -- Update GUI text
    playerNameLabel.Text = sender.Name .. " wants to connect!"
    messageLabel.Text = "Do you want to accept this friend request?"
    
    -- Show the request
    showRequest()
    
    print("Received connection request from " .. sender.Name)
end)

-- Accept button
acceptButton.MouseButton1Click:Connect(function()
    if currentRequest then
        print("Accepting request from " .. currentRequest.Name)
        friendResponseEvent:FireServer(currentRequest, true)
        hideRequest()
    end
end)

-- Decline button
declineButton.MouseButton1Click:Connect(function()
    if currentRequest then
        print("Declining request from " .. currentRequest.Name)
        friendResponseEvent:FireServer(currentRequest, false)
        hideRequest()
    end
end)

-- Listen for responses (feedback to sender)
friendResponseEvent.OnClientEvent:Connect(function(otherPlayer, accepted)
    if accepted then
        -- Show success notification
        print(otherPlayer.Name .. " accepted your request!")
        -- You can add a notification GUI here
    else
        -- Show declined notification
        print(otherPlayer.Name .. " declined your request")
        -- You can add a notification GUI here
    end
end)

