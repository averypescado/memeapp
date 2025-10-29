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

    // Compress image to fit within Firestore's 1MB document limit
    // We store only one optimized version (no separate thumbnail)
    const compressedDataUrl = await compressImage(blob);

    // Validate size (Firestore has ~1MB document limit, leave room for metadata)
    const sizeInBytes = compressedDataUrl.length;
    const sizeInKB = Math.round(sizeInBytes / 1024);

    if (sizeInBytes > 900000) { // 900KB limit to be safe
      throw new Error(`Image too large (${sizeInKB}KB). Please try a smaller image.`);
    }

    console.log(`Compressed image size: ${sizeInKB}KB`);

    // Generate unique ID for this meme
    const memeId = generateId();

    // Save directly to Firestore as data URL
    await db.collection('users').doc(user.uid).collection('memes').doc(memeId).set({
      imageUrl: compressedDataUrl,
      thumbnailUrl: compressedDataUrl, // Use same image for thumbnail
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
        message: `Your meme has been saved (${sizeInKB}KB)`
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
        title: 'Error Saving Meme',
        message: error.message || 'Failed to save meme'
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

// Compress image to fit within Firestore's 1MB document size limit
async function compressImage(blob, maxSizeKB = 800) {
  try {
    // Use createImageBitmap which works in service workers
    const imageBitmap = await createImageBitmap(blob);

    // Calculate dimensions to fit within 800x800 while maintaining aspect ratio
    // This is large enough for viewing memes but small enough to compress well
    let width = imageBitmap.width;
    let height = imageBitmap.height;
    const maxDimension = 800;

    if (width > height) {
      if (width > maxDimension) {
        height = (height * maxDimension) / width;
        width = maxDimension;
      }
    } else {
      if (height > maxDimension) {
        width = (width * maxDimension) / height;
        height = maxDimension;
      }
    }

    // Create canvas and draw resized image
    const canvas = new OffscreenCanvas(width, height);
    const ctx = canvas.getContext('2d');
    ctx.drawImage(imageBitmap, 0, 0, width, height);

    // Try different quality levels until we get under the size limit
    let quality = 0.8;
    let compressedDataUrl = null;
    let attempts = 0;
    const maxAttempts = 5;

    while (attempts < maxAttempts) {
      // Convert to blob with current quality
      const compressedBlob = await canvas.convertToBlob({
        type: 'image/jpeg',
        quality: quality
      });

      compressedDataUrl = await blobToDataURL(compressedBlob);
      const sizeKB = compressedDataUrl.length / 1024;

      console.log(`Compression attempt ${attempts + 1}: ${Math.round(sizeKB)}KB at quality ${quality}`);

      if (sizeKB <= maxSizeKB) {
        // Success! Image is small enough
        return compressedDataUrl;
      }

      // Reduce quality for next attempt
      quality -= 0.15;
      attempts++;

      if (quality < 0.3) {
        // Don't go below 0.3 quality, instead reduce dimensions further
        quality = 0.5;
        width = Math.floor(width * 0.8);
        height = Math.floor(height * 0.8);
        canvas.width = width;
        canvas.height = height;
        ctx.drawImage(imageBitmap, 0, 0, width, height);
      }
    }

    // If we still haven't succeeded, return what we have
    return compressedDataUrl;
  } catch (error) {
    console.error('Error compressing image:', error);
    throw new Error('Failed to compress image');
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
