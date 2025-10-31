# Adding iMessage Extension to Your Project

Follow these steps to add the iMessage extension to your Xcode project.

## Step 1: Add iMessage Extension Target

1. **In Xcode**, select **File → New → Target**

2. Select **iOS** tab → **iMessage Extension**

3. Click **Next**

4. Configure:
   - Product Name: `MemeMessages`
   - Organization Identifier: **Same as your main app** (e.g., `com.yourname`)
   - Language: **Swift**
   - Click **Finish**

5. When prompted "Activate MemeMessages scheme?", click **Activate**

## Step 2: Enable App Groups (Same as Before)

1. Select **MemeMessages** target

2. Go to **Signing & Capabilities** tab

3. Click **+ Capability** → **App Groups**

4. Click **+** and add the **EXACT SAME** App Group ID you used before:
   - `group.com.yourname.MemeApp`

5. Check the checkbox next to it

## Step 3: Add Shared Files to MemeMessages Target

The iMessage extension needs access to the same shared files:

1. In Xcode left sidebar, find these files in the **Shared** folder:
   - `Meme.swift`
   - `AppGroup.swift`
   - `ImageCache.swift`

2. Click on **each file** one by one

3. In **right sidebar → File Inspector**, look for "Target Membership"

4. **Check the box** next to **MemeMessages** (should already have MemeApp checked)

Now all three targets can share the same code!

## Step 4: Add iMessage Extension Code

1. **Delete** the default files Xcode created:
   - In MemeMessages folder, delete:
     - `MessagesViewController.swift` (the default one)
     - `MainInterface.storyboard`

2. **Add the new code:**
   - Right-click on **MemeMessages** folder
   - Select "Add Files to MemeApp..."
   - Navigate to `ios-app/MemeMessages/`
   - Select `MessagesViewController.swift`
   - ✅ Copy items if needed
   - ✅ Check **MemeMessages** target only
   - Click **Add**

3. **Replace Info.plist:**
   - In Xcode, click on `Info.plist` in MemeMessages folder
   - Delete it (Remove Reference)
   - Drag the new `Info.plist` from `ios-app/MemeMessages/` into the MemeMessages folder
   - ✅ Copy items if needed
   - ✅ Check MemeMessages target

## Step 5: Update Info.plist (Remove Storyboard Reference)

Since we deleted the storyboard, we need to update Info.plist:

1. Click on **MemeMessages** folder → `Info.plist`

2. Find the line with key: `NSExtensionMainStoryboard`

3. **Delete that entire line** (select it and press Delete)

Or just use the Info.plist I provided which already has this removed!

## Step 6: Build and Run!

1. **Select MemeApp scheme** (not MemeMessages)

2. **Select your iPhone**

3. **Click Play ▶️**

4. The app will rebuild and install

## Step 7: Test in Messages!

1. **Open Messages** app on your iPhone

2. Start a conversation (or open existing one)

3. **Tap the + button** (or App Store icon) next to the text field

4. **Swipe left** through the app icons at the bottom

5. Look for **"Meme App"** icon (might be in the "..." more menu)

6. **Tap it** - you should see your memes in a grid!

7. **Tap any meme** - it inserts directly into the conversation! 🎉

## Troubleshooting

**"Meme App" doesn't appear in Messages:**
- Make sure you selected MemeApp scheme (not MemeMessages) when building
- Try force-quitting Messages app and reopening
- Rebuild the app

**No memes showing:**
- Open the main MemeApp first to sync/cache images
- Make sure you're logged in with same account

**Extension crashes:**
- Check that App Groups ID is correct and same across all targets
- Check that Shared files have MemeMessages checked in Target Membership

---

Much easier than the keyboard, right? 😊
