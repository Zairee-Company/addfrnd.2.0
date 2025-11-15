-- LocalScript in StarterPlayer/StarterPlayerScripts/
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local friendRequestEvent = remoteEvents:WaitForChild("FriendRequest")

-- Function to send connection request
local function sendConnectionRequest(targetPlayer)
    if not targetPlayer or not targetPlayer:IsA("Player") then
        warn("Invalid target player")
        return false
    end
    
    -- Don't send request to yourself
    if targetPlayer == Players.LocalPlayer then
        warn("Cannot send request to yourself")
        return false
    end
    
    -- Send request to server
    friendRequestEvent:FireServer(targetPlayer)
    
    -- Provide feedback
    print("Connection request sent to " .. targetPlayer.Name)
    return true
end

-- Make function globally accessible
_G.SendConnectionRequest = sendConnectionRequest

-- Example: Connect to your "Add Friend" button
-- Replace with your actual button path
local addFriendButton = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("AvatarProfileGui"):WaitForChild("ProfileFrame"):WaitForChild("Buttons"):WaitForChild("Add Friend", 5)

if addFriendButton then
    addFriendButton.MouseButton1Click:Connect(function()
        -- Get the target player (you'll need to track this in your profile system)
        local targetPlayer = _G.CurrentProfilePlayer or nil
        
        if targetPlayer then
            local success = sendConnectionRequest(targetPlayer)
            if success then
                addFriendButton.Text = "Request Sent!"
                task.wait(2)
                addFriendButton.Text = "Add Friend"
            end
        else
            warn("No target player selected")
        end
    end)
end

