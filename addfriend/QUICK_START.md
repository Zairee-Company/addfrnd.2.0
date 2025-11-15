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

---