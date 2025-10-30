# iOS Meme App

Access your saved memes from any iOS app via a custom keyboard extension.

## Project Structure

```
ios-app/
├── MemeApp/              # Main iOS app
├── MemeKeyboard/         # Keyboard extension
└── Shared/               # Code shared between app and keyboard
```

## Setup Instructions

### Prerequisites

1. **macOS** with **Xcode 14+** installed
2. **iOS device** (keyboard extensions don't work well in simulator)
3. **Apple Developer Account** (free account works for testing)

### Step 1: Create Xcode Project

1. Open **Xcode**
2. Select **File → New → Project**
3. Choose **iOS → App**
4. Configure:
   - **Product Name:** MemeApp
   - **Team:** Select your Apple ID
   - **Organization Identifier:** com.yourname (e.g., com.john)
   - **Interface:** SwiftUI
   - **Language:** Swift
   - **Storage:** None
5. Save to the `ios-app` folder in your memeapp repository

### Step 2: Add Keyboard Extension Target

1. In Xcode, select **File → New → Target**
2. Choose **iOS → Keyboard Extension**
3. Configure:
   - **Product Name:** MemeKeyboard
   - **Organization Identifier:** Same as main app
   - **Language:** Swift
4. Click **Activate** when prompted to activate the scheme

### Step 3: Enable App Groups

App Groups allow the main app and keyboard extension to share data.

**For Main App:**
1. Select the **MemeApp** target
2. Go to **Signing & Capabilities**
3. Click **+ Capability** → **App Groups**
4. Click **+** and add: `group.com.yourname.MemeApp`
5. Check the checkbox next to it

**For Keyboard Extension:**
1. Select the **MemeKeyboard** target
2. Go to **Signing & Capabilities**
3. Click **+ Capability** → **App Groups**
4. Click **+** and add the **same** group: `group.com.yourname.MemeApp`
5. Check the checkbox next to it

### Step 4: Install Firebase SDK

1. In Xcode, select **File → Add Packages**
2. Enter URL: `https://github.com/firebase/firebase-ios-sdk`
3. Click **Add Package**
4. Select these products for **MemeApp** target:
   - FirebaseAuth
   - FirebaseFirestore
5. Click **Add Package**

### Step 5: Add Firebase Config File

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Click the **iOS** icon to add an iOS app
4. Enter Bundle ID: `com.yourname.MemeApp` (use your actual bundle ID)
5. Download **GoogleService-Info.plist**
6. Drag the file into your Xcode project (make sure "Copy items if needed" is checked)

### Step 6: Replace Generated Files

The generated Xcode project creates some default files. Replace them with the code files in this directory:

- Copy `Shared/` files → Add to both targets
- Copy `MemeApp/` files → Replace in MemeApp target
- Copy `MemeKeyboard/` files → Replace in MemeKeyboard target

### Step 7: Build and Run

1. Connect your iPhone
2. Select **MemeApp** scheme
3. Select your device
4. Click **Run** (▶️)
5. On first run, you may need to trust the developer certificate:
   - Settings → General → VPN & Device Management → Trust

### Step 8: Enable Keyboard

1. On your iPhone, go to **Settings → General → Keyboard → Keyboards**
2. Tap **Add New Keyboard**
3. Find **MemeKeyboard** and add it
4. Tap it again and enable **Allow Full Access** (required for images)

## Using the Keyboard

1. Open any app (Messages, Twitter, etc.)
2. Tap in a text field to bring up the keyboard
3. Tap the 🌐 globe icon to switch keyboards
4. Select **MemeKeyboard**
5. Browse and tap memes to insert them!

## Troubleshooting

**"Keyboard not showing in Settings"**
- Rebuild the app in Xcode
- Make sure you're building on a real device

**"Cannot access memes in keyboard"**
- Make sure App Groups are configured correctly
- Check that both targets use the same App Group ID

**"Images not loading"**
- Make sure you enabled "Allow Full Access" for the keyboard
- Check that Firestore rules are deployed

## Development Notes

- The keyboard extension has limited memory (~30MB)
- Images are cached locally for fast access
- The keyboard syncs memes when the main app is opened
