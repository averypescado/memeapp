// Background Service Worker for Meme App
// Handles context menu, image saving, and Firebase sync

importScripts('../libs/firebase-app-compat.js');
importScripts('../libs/firebase-auth-compat.js');
importScripts('../libs/firebase-firestore-compat.js');
importScripts('../config/firebase-config.js');

// Initialize Firebase
firebase.initializeApp(firebaseConfig);
const auth = firebase.auth();
const db = firebase.firestore();

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

// Save image to Firebase (using Firestore only - no Storage needed)
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

    // Convert blob to data URL
    const dataUrl = await blobToDataURL(blob);

    // Create a thumbnail (smaller version for faster loading)
    const thumbnailDataUrl = await createThumbnail(blob);

    // Generate unique ID for this meme
    const memeId = generateId();

    // Save directly to Firestore as data URLs
    await db.collection('users').doc(user.uid).collection('memes').doc(memeId).set({
      imageUrl: dataUrl,
      thumbnailUrl: thumbnailDataUrl,
      sourceUrl: sourceUrl || '',
      tags: [],
      favorite: false,
      createdAt: firebase.firestore.FieldValue.serverTimestamp(),
      updatedAt: firebase.firestore.FieldValue.serverTimestamp()
    });

    // Show success notification
    try {
      await chrome.notifications.create({
        type: 'basic',
        iconUrl: 'assets/icons/icon48.png',
        title: 'Meme Saved!',
        message: 'Your meme has been saved and synced.'
      });
    } catch (notifError) {
      console.log('Notification error (non-critical):', notifError);
    }

    console.log('Meme saved successfully:', memeId);
  } catch (error) {
    console.error('Error saving meme:', error);
    try {
      await chrome.notifications.create({
        type: 'basic',
        iconUrl: 'assets/icons/icon48.png',
        title: 'Error',
        message: 'Failed to save meme: ' + error.message
      });
    } catch (notifError) {
      console.log('Notification error:', notifError);
    }
  }
}

// Convert blob to data URL
function blobToDataURL(blob) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onloadend = () => resolve(reader.result);
    reader.onerror = reject;
    reader.readAsDataURL(blob);
  });
}

// Create thumbnail from blob using service worker-compatible APIs
async function createThumbnail(blob) {
  try {
    // Use createImageBitmap which works in service workers
    const imageBitmap = await createImageBitmap(blob);

    // Calculate dimensions to fit within 200x200 while maintaining aspect ratio
    let width = imageBitmap.width;
    let height = imageBitmap.height;
    const maxSize = 200;

    if (width > height) {
      if (width > maxSize) {
        height = (height * maxSize) / width;
        width = maxSize;
      }
    } else {
      if (height > maxSize) {
        width = (width * maxSize) / height;
        height = maxSize;
      }
    }

    // Create canvas and draw resized image
    const canvas = new OffscreenCanvas(width, height);
    const ctx = canvas.getContext('2d');
    ctx.drawImage(imageBitmap, 0, 0, width, height);

    // Convert to blob then to data URL
    const thumbnailBlob = await canvas.convertToBlob({
      type: 'image/jpeg',
      quality: 0.7
    });

    return await blobToDataURL(thumbnailBlob);
  } catch (error) {
    console.error('Error creating thumbnail:', error);
    // Fallback: return original blob as data URL
    return await blobToDataURL(blob);
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
