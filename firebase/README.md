# Firebase Configuration

## Setup Instructions

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add project"
3. Enter project name (e.g., "meme-app")
4. Follow the setup wizard

### 2. Enable Authentication

1. In Firebase Console, go to "Authentication"
2. Click "Get started"
3. Enable "Email/Password" sign-in method

### 3. Create Firestore Database

1. Go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in production mode"
4. Select a location close to your users
5. Click "Enable"

**Note:** We store images directly in Firestore as base64 data URLs, so Firebase Storage is not needed!

### 4. Deploy Firestore Security Rules

Manually copy the Firestore security rules:

1. In Firebase Console, go to "Firestore Database"
2. Click the "Rules" tab
3. Copy the contents of `firestore.rules` from this folder
4. Paste into the rules editor
5. Click "Publish"

### 5. Get Web App Configuration

1. Go to Project Settings (gear icon)
2. Scroll down to "Your apps"
3. Click "Web" (</>) icon
4. Register your app with a nickname
5. Copy the Firebase configuration object
6. Paste into `chrome-extension/config/firebase-config.js`

The config should look like:
```javascript
const firebaseConfig = {
  apiKey: "AIza...",
  authDomain: "your-app.firebaseapp.com",
  projectId: "your-app",
  storageBucket: "your-app.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abc123"
};
```

### 6. Set up Firestore Indexes (Optional)

If you get index errors when querying, Firebase will provide a link to create the required index automatically.

## Security Rules Explanation

### Firestore Rules
- Users can only access memes in their own collection (`/users/{userId}/memes/*`)
- Must be authenticated to read/write
- All other paths are denied
- Images are stored as base64 data URLs within Firestore documents

## Data Structure

### Firestore Collections
```
users (collection)
  └── {userId} (document)
      └── memes (collection)
          └── {memeId} (document)
              ├── imageUrl: string (base64 data URL)
              ├── thumbnailUrl: string (base64 data URL, 200x200 max)
              ├── sourceUrl: string
              ├── tags: array
              ├── favorite: boolean
              ├── createdAt: timestamp
              └── updatedAt: timestamp
```

**Note:** Images are stored directly as base64-encoded data URLs within Firestore documents. This eliminates the need for Firebase Storage and keeps everything in one place.

## Testing

Test your security rules:
1. Go to Firestore > Rules
2. Click "Rules Playground"
3. Test different scenarios

## Costs

Firebase has a generous free tier (Spark Plan):
- Authentication: Free (unlimited)
- Firestore: 50K reads/day, 20K writes/day, 1GB storage, 10GB/month bandwidth

**For a personal meme app, you'll easily stay within free limits!**

Note: Since we store images as data URLs in Firestore, you don't need Firebase Storage (which sometimes requires billing depending on your region).
