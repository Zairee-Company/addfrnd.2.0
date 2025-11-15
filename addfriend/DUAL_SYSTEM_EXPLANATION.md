# Dual System: In-Game Connections + Real Roblox Friend Requests

## Overview

The friend request system now supports **BOTH** in-game connections and real Roblox friend requests simultaneously!

## How It Works

### 🎮 Scenario 1: Player Clicks "Add Friend"

When a player clicks the "Add Friend" button:

1. **In-Game Connection Request** (Custom System)
   - Sends request via RemoteEvent to server
   - Target player sees custom popup GUI
   - Works immediately, no API limits

2. **Real Roblox Friend Request** (Roblox API)
   - Attempts `player:RequestFriendship(userId)`
   - Falls back to `SetCore("PromptSendFriendRequest")` if needed
   - Creates actual Roblox friend request

**Result**: Both systems work together!

### ✅ Scenario 2: Player Accepts In-Game Request

When a player accepts the in-game connection request:

1. **In-Game System**
   - Server processes acceptance
   - Both players notified via RemoteEvents
   - Custom logic can be added (DataStore, badges, etc.)

2. **Real Roblox Friend Request** (Automatic)
   - Server automatically calls `sender:RequestFriendship(responder.UserId)`
   - Creates real Roblox friendship
   - Players become friends on Roblox platform

**Result**: Players are connected in-game AND on Roblox!

## Benefits

### In-Game Connection System
- ✅ Custom GUI with animations
- ✅ Works immediately
- ✅ No API rate limits
- ✅ Full control over UI/UX
- ✅ Can add custom features (badges, perks, etc.)

### Real Roblox Friend Requests
- ✅ Players become actual Roblox friends
- ✅ Visible in Roblox friends list
- ✅ Can see when friends are online
- ✅ Works across all Roblox games
- ✅ Official Roblox friendship status

## Code Locations

### Client-Side (Sending Requests)
**File**: `StarterPlayer/StarterPlayerScripts/AvatarProfileAllInOne.lua`
- Lines 268-282: Sends both in-game request AND real Roblox request

### Server-Side (Accepting Requests)
**File**: `ServerScriptService/ConnectionRequestHandler.lua`
- Lines 65-81: Automatically sends real Roblox friend request when in-game request is accepted

## Important Notes

1. **Real Roblox requests require both players to be in the same game**
   - `RequestFriendship()` only works when both players are present
   - If a player leaves, the real request won't be sent

2. **In-game system always works**
   - Even if real Roblox request fails, in-game connection still works
   - Provides fallback and better user experience

3. **Rate Limits**
   - Roblox has rate limits on friend requests
   - In-game system has 30-second cooldown to prevent spam
   - Both systems respect their respective limits

4. **Privacy Settings**
   - Some players may have friend requests disabled
   - Real Roblox requests will fail for these players
   - In-game system still works regardless

## Testing

To test both systems:

1. **Test In-Game System:**
   - Player 1 clicks "Add Friend" on Player 2
   - Player 2 should see custom popup
   - Accept/Decline should work

2. **Test Real Roblox Requests:**
   - After accepting in-game request
   - Check Roblox friends list (may take a moment)
   - Both players should appear as friends

3. **Check Output:**
   - Look for messages like:
     - "Real Roblox friend request also sent to [Player]"
     - "Real Roblox friend request sent from [Player] to [Player]"

## Disabling Real Roblox Requests

If you want to use ONLY the in-game system:

1. In `AvatarProfileAllInOne.lua`, comment out lines 268-282
2. In `ConnectionRequestHandler.lua`, comment out lines 65-81

The in-game system will work independently!

---

**You now have the best of both worlds!** 🎉

