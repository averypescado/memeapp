// Background Service Worker for Meme App
// Handles context menu, image saving, and Firebase sync

importScripts('../libs/firebase-app-compat.js');
importScripts('../libs/firebase-auth-compat.js');
importScripts('../libs/firebase-firestore-compat.js');
importScripts('../libs/firebase-storage-compat.js');
importScripts('../config/firebase-config.js');

// Initialize Firebase
firebase.initializeApp(firebaseConfig);
const auth = firebase.auth();
const db = firebase.firestore();
const storage = firebase.storage();

// Create context menu on installation
chrome.runtime.onInstalled.addListener(() => {
  chrome.contextMenus.create({
    id: 'saveMeme',
    title: 'Save to Meme App',
    contexts: ['image']
  });
});

// Handle context menu clicks
chrome.contextMenus.onClicked.addListener((info, tab) => {
  if (info.menuItemId === 'saveMeme') {
    handleSaveImage(info.srcUrl, info.pageUrl);
  }
});

// Save image to Firebase
async function handleSaveImage(imageUrl, sourceUrl) {
  try {
    // Check if user is authenticated
    const user = auth.currentUser;
    if (!user) {
      // Open auth page if not logged in
      chrome.tabs.create({ url: chrome.runtime.getURL('auth/login.html') });
      return;
    }

    console.log('Saving image:', imageUrl);

    // Fetch the image
    const response = await fetch(imageUrl);
    const blob = await response.blob();

    // Generate unique ID for this meme
    const memeId = generateId();
    const fileName = `${memeId}.${getFileExtension(blob.type)}`;

    // Upload to Firebase Storage
    const storageRef = storage.ref(`users/${user.uid}/memes/${fileName}`);
    const uploadTask = await storageRef.put(blob);
    const downloadUrl = await uploadTask.ref.getDownloadURL();

    // Create thumbnail (simplified - just use same image for now)
    // TODO: Implement proper thumbnail generation
    const thumbnailUrl = downloadUrl;

    // Save metadata to Firestore
    await db.collection('users').doc(user.uid).collection('memes').doc(memeId).set({
      imageUrl: downloadUrl,
      thumbnailUrl: thumbnailUrl,
      sourceUrl: sourceUrl || '',
      tags: [],
      favorite: false,
      createdAt: firebase.firestore.FieldValue.serverTimestamp(),
      updatedAt: firebase.firestore.FieldValue.serverTimestamp()
    });

    // Show success notification
    chrome.notifications.create({
      type: 'basic',
      iconUrl: '../assets/icons/icon48.png',
      title: 'Meme Saved!',
      message: 'Your meme has been saved and synced.'
    });

    console.log('Meme saved successfully:', memeId);
  } catch (error) {
    console.error('Error saving meme:', error);
    chrome.notifications.create({
      type: 'basic',
      iconUrl: '../assets/icons/icon48.png',
      title: 'Error',
      message: 'Failed to save meme: ' + error.message
    });
  }
}

// Generate unique ID
function generateId() {
  return Date.now().toString(36) + Math.random().toString(36).substr(2);
}

// Get file extension from MIME type
function getFileExtension(mimeType) {
  const extensions = {
    'image/jpeg': 'jpg',
    'image/jpg': 'jpg',
    'image/png': 'png',
    'image/gif': 'gif',
    'image/webp': 'webp'
  };
  return extensions[mimeType] || 'jpg';
}

// Listen for auth state changes
auth.onAuthStateChanged((user) => {
  if (user) {
    console.log('User signed in:', user.email);
  } else {
    console.log('User signed out');
  }
});

// Handle messages from popup
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.action === 'getAuthState') {
    const user = auth.currentUser;
    sendResponse({ user: user ? { uid: user.uid, email: user.email } : null });
  }
  return true;
});
