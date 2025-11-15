-- Script in ServerScriptService
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local friendRequestEvent = remoteEvents:WaitForChild("FriendRequest")
local friendResponseEvent = remoteEvents:WaitForChild("FriendRequestResponse")

-- Track active requests to prevent spam
local activeRequests = {}
local REQUEST_COOLDOWN = 30 -- seconds

-- Handle friend request from sender
friendRequestEvent.OnServerEvent:Connect(function(sender, targetPlayer)
    -- Validation
    if not sender or not targetPlayer then
        warn("Invalid players in friend request")
        return
    end
    
    if sender == targetPlayer then
        warn(sender.Name .. " tried to send request to themselves")
        return
    end
    
    -- Check cooldown
    local requestKey = sender.UserId .. "_" .. targetPlayer.UserId
    if activeRequests[requestKey] then
        local timePassed = tick() - activeRequests[requestKey]
        if timePassed < REQUEST_COOLDOWN then
            warn("Request on cooldown for " .. (REQUEST_COOLDOWN - timePassed) .. " seconds")
            return
        end
    end
    
    -- Mark request as active
    activeRequests[requestKey] = tick()
    
    -- Check if players are already friends
    local success, areFriends = pcall(function()
        return sender:IsFriendsWith(targetPlayer.UserId)
    end)
    
    if success and areFriends then
        warn(sender.Name .. " and " .. targetPlayer.Name .. " are already friends")
        return
    end
    
    print(sender.Name .. " sent connection request to " .. targetPlayer.Name)
    
    -- Send request to target player's client
    friendRequestEvent:FireClient(targetPlayer, sender)
end)

-- Handle response (accept/decline)
friendResponseEvent.OnServerEvent:Connect(function(responder, sender, accepted)
    if not responder or not sender then
        warn("Invalid players in response")
        return
    end
    
    if accepted then
        print(responder.Name .. " accepted request from " .. sender.Name)
        
        -- Send real Roblox friend request (if not already friends)
        local success, areFriends = pcall(function()
            return sender:IsFriendsWith(responder.UserId)
        end)
        
        if success and not areFriends then
            -- Attempt to send real Roblox friend request
            local requestSuccess, requestErr = pcall(function()
                sender:RequestFriendship(responder.UserId)
            end)
            
            if requestSuccess then
                print("Real Roblox friend request sent from " .. sender.Name .. " to " .. responder.Name)
            else
                warn("Failed to send real Roblox friend request: " .. tostring(requestErr))
            end
        end
        
        -- Notify both players
        friendResponseEvent:FireClient(sender, responder, true)
        friendResponseEvent:FireClient(responder, sender, true)
        
        -- Here you can add custom logic (add to friends list, grant access, etc.)
        -- Example: Store in DataStore, give badge, etc.
        
    else
        print(responder.Name .. " declined request from " .. sender.Name)
        
        -- Notify sender
        friendResponseEvent:FireClient(sender, responder, false)
    end
    
    -- Clear request from active list
    local requestKey = sender.UserId .. "_" .. responder.UserId
    activeRequests[requestKey] = nil
end)

