# Quick Start Guide - Friend Request System

## ✅ What's Been Created

All scripts have been created and are ready to use! You just need to set up the GUI structure in Roblox Studio.

## 📁 Files Created

1. **`StarterPlayer/StarterPlayerScripts/SendConnectionRequest.lua`**
   - Handles sending friend requests
   - Provides `_G.SendConnectionRequest(targetPlayer)` function

2. **`StarterPlayer/StarterPlayerScripts/DisplayConnectionRequest.lua`**
   - Displays incoming friend request popups
   - Handles Accept/Decline buttons

3. **`StarterPlayer/StarterPlayerScripts/AvatarProfileAllInOne.lua`**
   - Updated to integrate with friend request system
   - Sets `_G.CurrentProfilePlayer` when opening profiles
   - "Add Friend" button now uses the new system

4. **`ServerScriptService/ConnectionRequestHandler.lua`**
   - Server-side validation and request handling
   - Prevents spam with 30-second cooldown
   - Checks if players are already friends

## 🎨 What You Need to Create in Roblox Studio

### Step 1: RemoteEvents (2 minutes)

1. In **ReplicatedStorage**, create a Folder named `RemoteEvents` (if it doesn't exist)
2. Create two RemoteEvents inside:
   - `FriendRequest`
   - `FriendRequestResponse`

### Step 2: ConnectionRequestGui (5 minutes)

1. In **StarterGui**, create a ScreenGui named `ConnectionRequestGui`
   - Set `ResetOnSpawn` to `false`
   - Set `ZIndexBehavior` to `Sibling`

2. Inside, create a Frame named `RequestFrame`:
   - AnchorPoint: (0.5, 0.5)
   - Position: (0.5, 0, 0.5, 0)
   - Size: (0, 400, 0, 200)
   - BackgroundColor3: RGB(30, 30, 40)
   - BorderSizePixel: 0
   - **Visible: false** (important!)

3. Inside RequestFrame, create:
   - **PlayerNameLabel** (TextLabel) - Top text
   - **MessageLabel** (TextLabel) - Middle text
   - **AcceptButton** (TextButton) - Green button
   - **DeclineButton** (TextButton) - Red button

See `SETUP_INSTRUCTIONS.md` for detailed property values.

## 🚀 How to Test

1. Open Roblox Studio
2. Click **Play** → Select **"2 Players"** or more
3. **Player 1:** Click on Player 2's character to open profile
4. **Player 1:** Click "Add Friend" button
5. **Player 2:** Should see request popup appear
6. **Player 2:** Click Accept or Decline
7. Check **Output** window for confirmation messages

## 🔧 Integration Details

The system is already integrated with your existing profile system:

- When a profile opens, `_G.CurrentProfilePlayer` is set
- The "Add Friend" button automatically uses the new system
- Button shows "Request Sent!" feedback
- Button shows "Friends ✓" if already friends

## ⚠️ Troubleshooting

**Request not showing?**
- Check that `ConnectionRequestGui` exists in StarterGui
- Verify `RequestFrame.Visible` starts as `false`
- Check Output window for errors

**Button not working?**
- Verify RemoteEvents exist: `ReplicatedStorage/RemoteEvents/FriendRequest`
- Check that `_G.CurrentProfilePlayer` is being set (check Output)

**Multiple requests?**
- System queues requests (shows one at a time)
- 30-second cooldown prevents spam



**Ready to go!** Just create the GUI structure in Studio and you're done! 🎉

## 📝 Notes

- **Dual System**: This system provides BOTH:
  - **In-game connection requests** (custom GUI popup system)
  - **Real Roblox friend requests** (sent to actual Roblox accounts)
  
- When clicking "Add Friend":
  - Sends in-game connection request (custom popup)
  - Also attempts to send real Roblox friend request via `RequestFriendship()`
  
- When accepting an in-game request:
  - Server automatically sends real Roblox friend request to both players
  
- All requests are validated server-side for security
- Real Roblox friend requests require both players to be in the same game

---# Friend/Connection Request System Setup Instructions

This guide will help you set up the complete friend request system in your Roblox game.

## Required Structure

### 1. RemoteEvents Setup

Create the following structure in Roblox Studio:

```
ReplicatedStorage
└── RemoteEvents (Folder)
    ├── FriendRequest (RemoteEvent)
    └── FriendRequestResponse (RemoteEvent)
```

**Steps:**
1. In ReplicatedStorage, create a Folder named `RemoteEvents` (if it doesn't exist)
2. Right-click `RemoteEvents` → Insert Object → RemoteEvent
3. Name it `FriendRequest`
4. Right-click `RemoteEvents` → Insert Object → RemoteEvent
5. Name it `FriendRequestResponse`

### 2. ConnectionRequestGui Setup

Create the following GUI structure in `StarterGui`:

```
StarterGui
└── ConnectionRequestGui (ScreenGui)
    └── RequestFrame (Frame)
        ├── PlayerNameLabel (TextLabel)
        ├── MessageLabel (TextLabel)
        ├── AcceptButton (TextButton)
        └── DeclineButton (TextButton)
```

**Detailed Properties:**

#### ConnectionRequestGui (ScreenGui)
- **ResetOnSpawn**: false
- **ZIndexBehavior**: Sibling

#### RequestFrame (Frame)
- **AnchorPoint**: (0.5, 0.5)
- **Position**: UDim2.new(0.5, 0, 0.5, 0)
- **Size**: UDim2.new(0, 400, 0, 200)
- **BackgroundColor3**: RGB(30, 30, 40)
- **BorderSizePixel**: 0
- **Visible**: false (starts hidden)

#### PlayerNameLabel (TextLabel)
- **Position**: UDim2.new(0, 20, 0, 20)
- **Size**: UDim2.new(1, -40, 0, 30)
- **Text**: "Player Name wants to connect!"
- **TextColor3**: RGB(255, 255, 255)
- **TextSize**: 20
- **Font**: GothamBold
- **BackgroundTransparency**: 1

#### MessageLabel (TextLabel)
- **Position**: UDim2.new(0, 20, 0, 60)
- **Size**: UDim2.new(1, -40, 0, 40)
- **Text**: "Do you want to accept this friend request?"
- **TextColor3**: RGB(200, 200, 200)
- **TextSize**: 16
- **BackgroundTransparency**: 1

#### AcceptButton (TextButton)
- **Position**: UDim2.new(0, 20, 1, -60)
- **Size**: UDim2.new(0.45, -30, 0, 40)
- **BackgroundColor3**: RGB(0, 170, 0)
- **Text**: "Accept"
- **TextColor3**: RGB(255, 255, 255)
- **TextSize**: 18
- **BorderSizePixel**: 0

#### DeclineButton (TextButton)
- **Position**: UDim2.new(0.55, 10, 1, -60)
- **Size**: UDim2.new(0.45, -30, 0, 40)
- **BackgroundColor3**: RGB(170, 0, 0)
- **Text**: "Decline"
- **TextColor3**: RGB(255, 255, 255)
- **TextSize**: 18
- **BorderSizePixel**: 0

### 3. Script Placement

The following scripts have been created and should be placed in these locations:

#### Client Scripts (LocalScripts)
- `StarterPlayer/StarterPlayerScripts/SendConnectionRequest.lua` - Handles sending requests
- `StarterPlayer/StarterPlayerScripts/DisplayConnectionRequest.lua` - Handles displaying incoming requests
- `StarterPlayer/StarterPlayerScripts/AvatarProfileAllInOne.lua` - Updated profile script (already integrated)

#### Server Script
- `ServerScriptService/ConnectionRequestHandler.lua` - Handles request logic on server

## How It Works

1. **Sending a Request:**
   - Player clicks "Add Friend" button in profile GUI
   - `SendConnectionRequest.lua` sends request to server via RemoteEvent
   - Server validates and forwards to target player

2. **Receiving a Request:**
   - Target player receives request via `DisplayConnectionRequest.lua`
   - GUI animates in from bottom of screen
   - Player can Accept or Decline

3. **Response Handling:**
   - Server processes accept/decline
   - Both players receive feedback
   - Request cooldown prevents spam (30 seconds)

## Testing

1. **In Studio:**
   - Click Play → Select "2 Players" or more
   - Player 1: Click on Player 2 to open profile
   - Player 1: Click "Add Friend"
   - Player 2: Should see request popup
   - Player 2: Click Accept or Decline
   - Check Output window for confirmation messages

2. **Common Issues:**
   - **Request not showing:** Check that ConnectionRequestGui exists in StarterGui
   - **Button not working:** Verify RemoteEvents exist in ReplicatedStorage/RemoteEvents/
   - **No feedback:** Check Output window for errors

## Features

- ✅ **Dual System**: Both in-game connections AND real Roblox friend requests
- ✅ Request cooldown (30 seconds) to prevent spam
- ✅ Already-friends detection
- ✅ Smooth animations for request popup
- ✅ Button feedback ("Request Sent!")
- ✅ Integration with existing profile system
- ✅ Server-side validation
- ✅ Real Roblox friend requests sent automatically when accepting

## How It Works - Dual System

### When Clicking "Add Friend":
1. Sends **in-game connection request** (custom popup GUI)
2. Also attempts to send **real Roblox friend request** via `RequestFriendship()`
3. Falls back to `SetCore("PromptSendFriendRequest")` if needed

### When Accepting In-Game Request:
1. Server processes the acceptance
2. Server automatically sends **real Roblox friend request** from sender to responder
3. Both players become friends in-game AND on Roblox

### Benefits:
- **In-game system**: Works immediately, custom GUI, no Roblox API limits
- **Real Roblox requests**: Players become actual Roblox friends, visible in friends list
- **Best of both worlds**: Custom experience + real friendship connections

## Next Steps (Optional Enhancements)

1. Add notification system for accepted/declined requests
2. Create friends list GUI
3. Store connections in DataStore for persistence
4. Add unfriend option
5. Show online status of friends

