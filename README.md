# Meme App

A cross-platform meme management app with Chrome Extension and iOS Keyboard Extension.

## Project Structure

- `chrome-extension/` - Chrome browser extension for saving memes
- `firebase/` - Firebase configuration and security rules
- `ios-app/` - iOS app with keyboard extension
- `shared/` - Shared types and utilities

## Features

- Save images from any website via Chrome extension
- Sync memes across devices via Firebase
- Access memes from iOS keyboard in any app
- Tag, search, and favorite memes

## Setup Instructions

### 1. Firebase Setup

1. Create a new Firebase project at https://console.firebase.google.com
2. Enable Authentication (Email/Password)
3. Create Firestore Database
4. Enable Firebase Storage
5. Copy your Firebase config to `chrome-extension/config/firebase-config.js`
6. Deploy security rules from `firebase/firestore.rules` and `firebase/storage.rules`

### 2. Chrome Extension

1. Navigate to `chrome-extension/`
2. Update Firebase config in `config/firebase-config.js`
3. Load unpacked extension in Chrome:
   - Go to `chrome://extensions`
   - Enable "Developer mode"
   - Click "Load unpacked"
   - Select the `chrome-extension` folder

### 3. iOS App

1. Navigate to `ios-app/`
2. Open `MemeApp.xcodeproj` in Xcode
3. Update Firebase config (GoogleService-Info.plist)
4. Build and run on device (keyboard extensions require real device)

## Tech Stack

- Chrome Extension: Manifest V3, JavaScript, Firebase JS SDK
- Backend: Firebase (Auth, Firestore, Storage)
- iOS: Swift, SwiftUI, Firebase iOS SDK

## Development Status

- [x] Project structure
- [ ] Chrome extension
- [ ] Firebase configuration
- [ ] iOS app
- [ ] iOS keyboard extension
