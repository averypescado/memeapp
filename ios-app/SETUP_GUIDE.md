# iOS Meme App - Complete Setup Guide

This guide will walk you through setting up the iOS app from scratch. Since you're new to iOS development, I'll explain each step in detail.

## Prerequisites

✅ **macOS** (required for Xcode)
✅ **Xcode 14 or later** (free from Mac App Store)
✅ **iPhone** (keyboard extensions work best on real devices)
✅ **Apple ID** (free account works for testing)

## Step-by-Step Setup

### Part 1: Create the Xcode Project (15 minutes)

1. **Open Xcode** on your Mac

2. **Create New Project:**
   - File → New → Project
   - Select **iOS** tab → **App** template
   - Click **Next**

3. **Configure Project:**
   - Product Name: `MemeApp`
   - Team: Select your Apple ID (if not showing, add it in Xcode Preferences → Accounts)
   - Organization Identifier: `com.yourname` (e.g., `com.john`)
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Uncheck "Use Core Data" and "Include Tests"
   - Click **Next**

4. **Save Location:**
   - Navigate to `/home/user/Desktop/memeapp/ios-app` (or wherever you cloned the repo)
   - Click **Create**

### Part 2: Add Keyboard Extension Target (5 minutes)

1. **Add Extension:**
   - File → New → Target
   - Select **iOS** tab → **Keyboard Extension**
   - Click **Next**

2. **Configure Extension:**
   - Product Name: `MemeKeyboard`
   - Organization Identifier: **Same as main app** (e.g., `com.john`)
   - Language: **Swift**
   - Click **Finish**

3. **Activate Scheme:**
   - When prompted "Activate MemeKeyboard scheme?", click **Activate**

### Part 3: Enable App Groups (10 minutes)

App Groups let the main app and keyboard share data. Both need the SAME group ID.

**For Main App (MemeApp):**

1. In Xcode, select **MemeApp** project in left sidebar
2. Select **MemeApp** target (not MemeKeyboard)
3. Click **Signing & Capabilities** tab
4. Click **+ Capability** button at top
5. Search for and add **App Groups**
6. Click **+** button under App Groups
7. Enter: `group.com.yourname.MemeApp` (replace `yourname` with your organization identifier)
8. Click **OK**
9. **Check the checkbox** next to the group name

**For Keyboard Extension (MemeKeyboard):**

1. Select **MemeKeyboard** target (in same targets list)
2. Click **Signing & Capabilities** tab
3. Click **+ Capability** → **App Groups**
4. Click **+** button
5. Enter **THE EXACT SAME** group ID: `group.com.yourname.MemeApp`
6. Click **OK**
7. **Check the checkbox**

⚠️ **IMPORTANT:** Both targets MUST use the EXACT same App Group ID!

### Part 4: Install Firebase SDK (10 minutes)

1. **Add Firebase Package:**
   - File → Add Packages
   - In search bar, paste: `https://github.com/firebase/firebase-ios-sdk`
   - Dependency Rule: **Up to Next Major Version** (should show 10.0.0 or higher)
   - Click **Add Package**

2. **Select Products:**
   - When prompted "Choose Package Products", select these for **MemeApp** target ONLY:
     - ✅ FirebaseAuth
     - ✅ FirebaseFirestore
   - Leave everything else unchecked
   - Click **Add Package**

3. **Wait for Installation** (may take 2-3 minutes)

### Part 5: Add Firebase Configuration (5 minutes)

1. **Get Config File:**
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Select your project (same one used for Chrome extension)
   - Click ⚙️ (Settings) → Project Settings
   - Scroll to "Your apps" section
   - Click **iOS+** icon
   - Enter iOS bundle ID: `com.yourname.MemeApp` (use YOUR actual bundle ID from Xcode)
   - App nickname: `MemeApp iOS`
   - Click **Register app**
   - Click **Download GoogleService-Info.plist**

2. **Add to Xcode:**
   - Drag the downloaded `GoogleService-Info.plist` file into Xcode
   - Drop it in the **MemeApp** folder (same level as MemeAppApp.swift)
   - ✅ Check "Copy items if needed"
   - ✅ Check **MemeApp** target (NOT MemeKeyboard)
   - Click **Finish**

### Part 6: Update App Group ID in Code (2 minutes)

1. **Open AppGroup.swift** in Xcode (in Shared folder)

2. **Find this line:**
   ```swift
   static let identifier = "group.com.yourname.MemeApp"
   ```

3. **Replace with YOUR App Group ID** (the one you created in Part 3):
   ```swift
   static let identifier = "group.com.john.MemeApp"  // example
   ```

4. **Save** (Cmd+S)

### Part 7: Add Code Files (10 minutes)

The repository already has all the Swift code files. You need to add them to your Xcode project:

**Add Shared Files (for both targets):**

1. In Xcode left sidebar, right-click on **MemeApp** folder
2. Select **Add Files to "MemeApp"**
3. Navigate to `ios-app/Shared/`
4. Select all `.swift` files
5. ✅ Check "Copy items if needed"
6. ✅ Check **BOTH** targets: MemeApp AND MemeKeyboard
7. Click **Add**

**Add Main App Files:**

1. Right-click **MemeApp** folder
2. Add Files to "MemeApp"
3. Navigate to `ios-app/MemeApp/`
4. Select all `.swift` files
5. ✅ Check MemeApp target ONLY
6. Click **Add**

**Add Keyboard Files:**

1. Right-click **MemeKeyboard** folder
2. Add Files to "MemeApp"
3. Navigate to `ios-app/MemeKeyboard/`
4. Select all `.swift` files
5. ✅ Check MemeKeyboard target ONLY
6. Click **Add**

**Delete Default Files:**

Xcode creates some default files we don't need. Delete these:
- `ContentView.swift` (in MemeApp folder)
- `KeyboardViewController.swift` (the original one Xcode created - we replaced it)

### Part 8: Build and Run! (5 minutes)

1. **Connect your iPhone** to your Mac via USB

2. **Trust Computer:**
   - On iPhone, tap "Trust This Computer"
   - Enter passcode

3. **Select Device:**
   - In Xcode top bar, click the device dropdown (next to "MemeApp")
   - Select your iPhone

4. **Build & Run:**
   - Click ▶️ Play button (or Cmd+R)
   - First build may take 2-3 minutes

5. **Trust Developer:**
   - If you see "Untrusted Developer" on iPhone:
   - Settings → General → VPN & Device Management
   - Tap your Apple ID → Trust
   - Go back and launch app again

### Part 9: Enable the Keyboard (3 minutes)

1. **Open Settings** on iPhone

2. **Navigate:** General → Keyboard → Keyboards

3. **Add New Keyboard:**
   - Tap "Add New Keyboard..."
   - Scroll down to find **MemeKeyboard**
   - Tap it

4. **Enable Full Access:**
   - Tap "MemeKeyboard" in keyboards list
   - Toggle ON "Allow Full Access"
   - Tap "Allow" in confirmation dialog
   - ⚠️ **Required for copying images!**

### Part 10: Test End-to-End! 🎉

1. **Save a meme in Chrome:**
   - On your computer, right-click any image
   - Select "Save to Meme App"

2. **Open MemeApp on iPhone:**
   - Login with same email/password
   - Tap refresh button
   - You should see your memes!

3. **Test Keyboard:**
   - Open Messages (or any app)
   - Tap to start typing
   - Tap 🌐 globe icon to switch keyboards
   - Select **MemeKeyboard**
   - Tap a meme
   - It copies to clipboard - **paste it** (Cmd+V or long-press → Paste)

## Troubleshooting

### "No such module 'FirebaseAuth'"
- Make sure you added Firebase SDK to **MemeApp** target only (not keyboard)
- Clean build folder: Product → Clean Build Folder
- Restart Xcode

### "Keyboard doesn't show in Settings"
- Make sure you're testing on a REAL device (not simulator)
- Rebuild the app
- Check that MemeKeyboard target has correct bundle ID

### "Cannot access memes in keyboard"
- Verify App Group IDs match exactly in both targets
- Check that you updated `AppGroup.swift` with correct ID
- Make sure "Allow Full Access" is enabled

### "Memes not syncing from Chrome"
- Verify same Firebase account in both apps
- Check Firestore rules are deployed
- Make sure you're logged in with same email

### "Images not loading"
- Enable "Allow Full Access" for keyboard
- Check that images were cached (open main app first)
- Verify App Groups are configured correctly

## What's Next?

Your meme app is complete! You can now:

✅ Save memes from Chrome browser
✅ View them in iOS app
✅ Share them from your iPhone keyboard
✅ Everything syncs via Firebase (free!)

### Future Improvements

Want to enhance it? Consider:
- Add tags UI in iOS app
- Implement image search
- Add meme collections/folders
- Share memes with friends
- Export backup

Enjoy your meme app! 🎉
