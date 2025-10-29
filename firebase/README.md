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

### 4. Deploy Security Rules

Deploy the security rules to protect your data:

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in this directory
firebase init

# Select:
# - Firestore (rules and indexes)
# - Storage (rules)

# Deploy rules
firebase deploy --only firestore:rules,storage:rules
```

Or manually copy the rules:
- Copy `firestore.rules` to Firebase Console > Firestore Database > Rules
- Copy `storage.rules` to Firebase Console > Storage > Rules

### 5. Enable Firebase Storage

1. Go to "Storage"
2. Click "Get started"
3. Accept default security rules (we'll override with storage.rules)

### 6. Get Web App Configuration

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

### 7. Set up Firestore Indexes (Optional)

If you get index errors when querying, Firebase will provide a link to create the required index automatically.

## Security Rules Explanation

### Firestore Rules
- Users can only access memes in their own collection (`/users/{userId}/memes/*`)
- Must be authenticated to read/write
- All other paths are denied

### Storage Rules
- Users can only access files in their own folder (`/users/{userId}/*`)
- Must be authenticated
- Files must be images (MIME type check)
- Max file size: 10MB

## Data Structure

### Firestore Collections
```
users (collection)
  └── {userId} (document)
      └── memes (collection)
          └── {memeId} (document)
              ├── imageUrl: string
              ├── thumbnailUrl: string
              ├── sourceUrl: string
              ├── tags: array
              ├── favorite: boolean
              ├── createdAt: timestamp
              └── updatedAt: timestamp
```

### Storage Structure
```
users/
  └── {userId}/
      ├── memes/
      │   ├── {memeId}.jpg
      │   ├── {memeId}.png
      │   └── ...
      └── thumbnails/
          ├── {memeId}.jpg
          └── ...
```

## Testing

Test your security rules:
1. Go to Firestore > Rules
2. Click "Rules Playground"
3. Test different scenarios

## Costs

Firebase has a generous free tier:
- Authentication: Free
- Firestore: 50K reads/day, 20K writes/day, 1GB storage
- Storage: 5GB storage, 1GB/day download
- Bandwidth: 10GB/month

For a personal meme app, you'll likely stay within free limits.
