-- AvatarProfileAllInOne.lua (LocalScript) -> put in StarterPlayerScripts
-- Requirements:
--  - StarterGui contains ScreenGui named exactly "AvatarProfileGui" with:
--      ProfileFrame
--         Header (Close)
--         Content (AvatarImage, RightCol -> TargetName, Bio)
--         Buttons (TextButtons named: Sync, Unsync, Add Friend, View)
--  - Optional RemoteEvents in ReplicatedStorage: "Sync", "Unsync", "FriendRequest"
-- Notes:
--  - Test friend prompt and thumbnails in Play mode or Roblox client; Studio Edit mode often behaves differently.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Debug start
print("[AvatarProfileAll] script started for", player.Name)
print("[AvatarProfileAll] PlayerGui contains AvatarProfileGui:", tostring(playerGui:FindFirstChild("AvatarProfileGui") ~= nil))

-- Helper: wait for GUI root
local function waitForGui(name, timeout)
	timeout = timeout or 5
	local start = tick()
	repeat
		local g = playerGui:FindFirstChild(name)
		if g then return g end
		task.wait(0.08)
	until tick() - start >= timeout
	return nil
end

local guiRoot = waitForGui("AvatarProfileGui", 5)
if not guiRoot then
	warn("[AvatarProfileAll] AvatarProfileGui not found under PlayerGui. Ensure a ScreenGui named 'AvatarProfileGui' exists in StarterGui.")
	return
end

local frame = guiRoot:FindFirstChild("ProfileFrame")
if not frame then
	warn("[AvatarProfileAll] ProfileFrame missing under AvatarProfileGui.")
	return
end

local function findSafe(parent, name, klass)
	if not parent then return nil end
	local obj = parent:FindFirstChild(name)
	if not obj then
		warn(("[AvatarProfileAll] Missing %s '%s' under %s"):format(klass or "Object", name, parent.Name))
	end
	return obj
end

-- UI refs
local header = findSafe(frame, "Header")
local closeBtn = findSafe(header, "Close", "GuiButton")
local content = findSafe(frame, "Content")
local avatarImg = findSafe(content, "AvatarImage", "ImageLabel")
local rightCol = findSafe(content, "RightCol", "Frame")
local targetNameLbl = rightCol and findSafe(rightCol, "TargetName", "TextLabel")
local bioLbl = rightCol and findSafe(rightCol, "Bio", "TextLabel")
local buttons = findSafe(frame, "Buttons", "Frame")

local syncBtn = buttons and findSafe(buttons, "Sync", "GuiButton")
local unsyncBtn = buttons and findSafe(buttons, "Unsync", "GuiButton")
local addFriendBtn = buttons and findSafe(buttons, "Add Friend", "GuiButton")
local viewBtn = buttons and findSafe(buttons, "View", "GuiButton")

-- Ensure ProfileBindable exists
local profileBindable = script:FindFirstChild("ProfileBindable")
if not profileBindable then
	profileBindable = Instance.new("BindableEvent")
	profileBindable.Name = "ProfileBindable"
	profileBindable.Parent = script
	print("[AvatarProfileAll] Created script.ProfileBindable")
else
	print("[AvatarProfileAll] Found existing script.ProfileBindable")
end

-- State
local currentTarget = nil
local DEFAULT_AVATAR = "" -- optional placeholder asset id string

-- Outline-only pulsing highlight using Highlight
local function outlinePulseHighlight(targetPlayer, duration)
	if not targetPlayer or not targetPlayer.Character then return end
	local char = targetPlayer.Character
	local h = Instance.new("Highlight")
	h.Name = "ProfileOutlineHighlight"
	h.Adornee = char
	h.FillColor = Color3.fromRGB(60, 200, 255)
	h.OutlineColor = Color3.fromRGB(60, 200, 255)
	h.FillTransparency = 1
	h.OutlineTransparency = 0.9
	h.Parent = workspace

	duration = duration or 1.6
	local half = math.max(0.12, duration * 0.45)
	local t1 = TweenService:Create(h, TweenInfo.new(half, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {OutlineTransparency = 0.12})
	local t2 = TweenService:Create(h, TweenInfo.new(half, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {OutlineTransparency = 0.9})

	t1:Play()
	t1.Completed:Connect(function() t2:Play() end)

	task.delay(duration + 0.08, function()
		if h and h.Parent then h:Destroy() end
	end)
end

-- Robust thumbnail setter (correct enums + rbxthumb fallback)
local function setAvatarThumbnailAsync(targetPlayer)
	if not avatarImg or not targetPlayer then
		warn("[AvatarProfileAll] setAvatarThumbnailAsync: missing avatarImg or target")
		return
	end

	spawn(function()
		local url = nil
		local tried = {}
		local sizes = {
			Enum.ThumbnailSize.Size420x420,
			Enum.ThumbnailSize.Size180x180,
			Enum.ThumbnailSize.Size100x100
		}

		for _, size in ipairs(sizes) do
			local ok, result = pcall(function()
				return Players:GetUserThumbnailAsync(targetPlayer.UserId, Enum.ThumbnailType.HeadShot, size)
			end)
			table.insert(tried, {size = tostring(size), ok = ok, result = result})
			if ok and type(result) == "string" and result ~= "" then
				url = result
				break
			end
		end

		if not url then
			local id = tonumber(targetPlayer.UserId) or 0
			if id > 0 then
				url = ("rbxthumb://type=AvatarHeadShot&id=%d&w=420&h=420"):format(id)
			end
		end

		if url and url ~= "" then
			local success, err = pcall(function() avatarImg.Image = url end)
			if success then
				print("[AvatarProfileAll] Avatar thumbnail set for", targetPlayer.Name)
			else
				warn("[AvatarProfileAll] Failed to set avatar ImageLabel.Image:", err)
				avatarImg.Image = DEFAULT_AVATAR
			end
		else
			avatarImg.Image = DEFAULT_AVATAR
			warn("[AvatarProfileAll] Failed to obtain thumbnail for", targetPlayer.Name)
			for i,v in ipairs(tried) do
				warn((" - tried %s ok=%s resultLen=%s"):format(v.size, tostring(v.ok), tostring(v.result and #tostring(v.result) > 0)))
			end
		end
	end)
end

-- Open profile UI
local function openProfileFor(targetPlayer)
	if not targetPlayer or not targetPlayer:IsA("Player") then return end
	currentTarget = targetPlayer
	
	-- Store the target player globally so SendConnectionRequest can access it
	_G.CurrentProfilePlayer = targetPlayer
	
	frame.Visible = true
	if targetNameLbl then targetNameLbl.Text = "Target: " .. targetPlayer.Name end
	if bioLbl then bioLbl.Text = "Status: Player since " .. tostring(targetPlayer.AccountAge) .. " days" end
	setAvatarThumbnailAsync(targetPlayer)
	outlinePulseHighlight(targetPlayer, 1.4)
	
	-- Update the Add Friend button
	if addFriendBtn then
		-- Check if already friends
		local areFriends = false
		pcall(function()
			areFriends = Players.LocalPlayer:IsFriendsWith(targetPlayer.UserId)
		end)
		
		if areFriends then
			addFriendBtn.Text = "Friends ✓"
			addFriendBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
		else
			addFriendBtn.Text = "Add Friend"
			addFriendBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 212)
		end
	end
end

-- Bindable connection
profileBindable.Event:Connect(function(t)
	if t and t:IsA("Player") then openProfileFor(t) end
end)

-- Global helper
_G.OpenAvatarProfile = function(t) profileBindable:Fire(t) end

-- Close button
if closeBtn and closeBtn:IsA("GuiButton") then
	closeBtn.MouseButton1Click:Connect(function()
		frame.Visible = false
		currentTarget = nil
		_G.CurrentProfilePlayer = nil
	end)
end

-- Remote wrappers
local function callSyncRemote(target)
	if not target then return end
	local r = ReplicatedStorage:FindFirstChild("Sync")
	if r and r:IsA("RemoteEvent") then
		r:FireServer(target)
	else
		warn("[AvatarProfileAll] ReplicatedStorage.Sync remote not found")
	end
end
local function callUnsyncRemote(target)
	if not target then return end
	local r = ReplicatedStorage:FindFirstChild("Unsync")
	if r and r:IsA("RemoteEvent") then
		r:FireServer(target)
	else
		warn("[AvatarProfileAll] ReplicatedStorage.Unsync remote not found")
	end
end

-- Add Friend with validation, close UI immediately, SetCore then fallback
local function tryPromptFriendRequest(targetPlayer)
	if not targetPlayer or not targetPlayer:IsA("Player") then
		warn("[AvatarProfileAll] Add Friend: invalid target")
		return
	end

	local userId = tonumber(targetPlayer.UserId) or 0
	print("[AvatarProfileAll] Add Friend requested for", tostring(targetPlayer.Name), "userId=", userId, "type=", typeof(userId))

	if userId <= 0 then
		warn("[AvatarProfileAll] Add Friend: invalid UserId for", tostring(targetPlayer.Name))
		return
	end
	if userId == player.UserId then
		warn("[AvatarProfileAll] Add Friend: cannot friend yourself")
		return
	end

	-- Close UI immediately
	if frame and frame:IsA("GuiObject") then frame.Visible = false end

	-- Try using the new connection request system first
	local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
	if remoteEvents then
		local friendRequestEvent = remoteEvents:FindFirstChild("FriendRequest")
		if friendRequestEvent and friendRequestEvent:IsA("RemoteEvent") then
			-- Use the new in-game connection system
			friendRequestEvent:FireServer(targetPlayer)
			print("[AvatarProfileAll] Fired FriendRequest remote for", targetPlayer.Name)
			
			-- Also attempt to send real Roblox friend request (optional - can be disabled)
			-- This sends both in-game connection AND real Roblox friend request
			local robloxRequestSuccess, robloxRequestErr = pcall(function()
				player:RequestFriendship(userId)
			end)
			
			if robloxRequestSuccess then
				print("[AvatarProfileAll] Real Roblox friend request also sent to", targetPlayer.Name)
			else
				-- Fallback to SetCore if RequestFriendship fails
				local setCoreOk, setCoreErr = pcall(function()
					StarterGui:SetCore("PromptSendFriendRequest", userId)
				end)
				if setCoreOk then
					print("[AvatarProfileAll] SetCore friend prompt requested for", userId, targetPlayer.Name)
				end
			end
			
			-- Update button feedback
			if addFriendBtn then
				addFriendBtn.Text = "Request Sent!"
				task.wait(2)
				addFriendBtn.Text = "Add Friend"
			end
			return
		end
	end

	-- Attempt client prompt (SetCore) as fallback if new system not available
	local ok, err = pcall(function()
		StarterGui:SetCore("PromptSendFriendRequest", userId)
	end)
	if ok then
		print("[AvatarProfileAll] SetCore friend prompt requested for", userId, targetPlayer.Name)
		return
	else
		warn("[AvatarProfileAll] SetCore returned error:", tostring(err))
	end

	-- Fallback: server RemoteEvent "FriendRequest" (old location)
	local fallback = ReplicatedStorage:FindFirstChild("FriendRequest")
	if fallback and fallback:IsA("RemoteEvent") then
		pcall(function() fallback:FireServer(userId) end)
		print("[AvatarProfileAll] Fired FriendRequest remote for", userId, targetPlayer.Name)
		return
	end

	warn("[AvatarProfileAll] Add Friend: no available prompt method. SetCore err:", tostring(err))
end

-- Button handlers
if syncBtn and syncBtn:IsA("GuiButton") then
	syncBtn.MouseButton1Click:Connect(function()
		if not currentTarget then return end
		frame.Visible = false
		callSyncRemote(currentTarget)
		outlinePulseHighlight(currentTarget, 1.8)
		currentTarget = nil
		_G.CurrentProfilePlayer = nil
	end)
else
	warn("[AvatarProfileAll] Sync button missing or misnamed.")
end

if unsyncBtn and unsyncBtn:IsA("GuiButton") then
	unsyncBtn.MouseButton1Click:Connect(function()
		if not currentTarget then return end
		frame.Visible = false
		callUnsyncRemote(currentTarget)
		outlinePulseHighlight(currentTarget, 1.8)
		currentTarget = nil
		_G.CurrentProfilePlayer = nil
	end)
else
	warn("[AvatarProfileAll] Unsync button missing or misnamed.")
end

if addFriendBtn and addFriendBtn:IsA("GuiButton") then
	addFriendBtn.MouseButton1Click:Connect(function()
		if not currentTarget then warn("[AvatarProfileAll] Add Friend: no target") return end
		tryPromptFriendRequest(currentTarget)
	end)
else
	warn("[AvatarProfileAll] Add Friend button missing or misnamed.")
end

if viewBtn and viewBtn:IsA("GuiButton") then
	viewBtn.MouseButton1Click:Connect(function()
		if not currentTarget then warn("[AvatarProfileAll] View: no target") return end
		print("[AvatarProfileAll] View pressed for", currentTarget.Name)
	end)
else
	warn("[AvatarProfileAll] View button missing or misnamed.")
end

-- Click / tap to open behavior
local mouse = player:GetMouse()
local Camera = workspace.CurrentCamera

local function playerFromPart(part)
	if not part then return nil end
	local node = part
	while node and node.Parent do
		if node.Parent:FindFirstChild("Humanoid") then
			local model = node.Parent
			for _, pl in pairs(Players:GetPlayers()) do
				if pl.Character == model then return pl end
			end
			return nil
		end
		node = node.Parent
	end
	return nil
end

local lastOpened = {}
local COOLDOWN = 0.6

local function tryOpenPlayer(pl)
	if not pl or pl == player then return end
	local now = tick()
	local last = lastOpened[pl.UserId] or 0
	if now - last < COOLDOWN then return end
	lastOpened[pl.UserId] = now
	profileBindable:Fire(pl)
end

mouse.Button1Down:Connect(function()
	if UserInputService:GetFocusedTextBox() then return end
	local t = mouse.Target
	if not t then return end
	local pl = playerFromPart(t)
	if pl then tryOpenPlayer(pl) end
end)

UserInputService.TouchStarted:Connect(function(touch, processed)
	if processed then return end
	local pos = touch.Position
	local ray = Camera:ScreenPointToRay(pos.X, pos.Y)
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {player.Character}
	params.FilterType = Enum.RaycastFilterType.Blacklist
	local res = workspace:Raycast(ray.Origin, ray.Direction * 2000, params)
	if res and res.Instance then
		local pl = playerFromPart(res.Instance)
		if pl then tryOpenPlayer(pl) end
	end
end)

-- Hide initially
frame.Visible = false

-- Quick auto-test: try open profile for first other player after 2s (one-time)
task.spawn(function()
	task.wait(2)
	local others = {}
	for _,p in ipairs(Players:GetPlayers()) do
		if p ~= player then table.insert(others, p) end
	end
	if #others > 0 then
		print("[AvatarProfileAll] Auto-test: opening profile for", others[1].Name)
		profileBindable:Fire(others[1])
	else
		print("[AvatarProfileAll] Auto-test: no other players present")
	end
end)

print("[AvatarProfileAll] ready for", player.Name)

