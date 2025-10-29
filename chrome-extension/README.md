# Meme App - Chrome Extension

Save memes from any website and sync them across your devices.

## Features

- Right-click any image to save to your collection
- Beautiful popup interface to browse saved memes
- Search and filter by tags/favorites
- Firebase sync across all devices
- Offline support (coming soon)

## Installation

### For Development

1. **Set up Firebase** (see `/firebase/README.md`)

2. **Configure Firebase in the extension:**
   - Copy your Firebase config
   - Paste into `config/firebase-config.js`

3. **Add placeholder icons:**
   - Place icon files in `assets/icons/`
   - Required sizes: 16x16, 48x48, 128x128
   - Or use the provided placeholder icons

4. **Load extension in Chrome:**
   - Open Chrome and go to `chrome://extensions`
   - Enable "Developer mode" (top right)
   - Click "Load unpacked"
   - Select the `chrome-extension` folder

### For Production

1. Package the extension:
   ```bash
   zip -r meme-app.zip chrome-extension/
   ```

2. Submit to Chrome Web Store:
   - Go to [Chrome Web Store Developer Dashboard](https://chrome.google.com/webstore/devconsole)
   - Upload the zip file
   - Fill in store listing details
   - Submit for review

## Usage

### Saving Memes

1. Right-click any image on a webpage
2. Select "Save to Meme App" from context menu
3. Image is uploaded to Firebase and synced

### Viewing Memes

1. Click the extension icon in toolbar
2. Browse your saved memes in the popup
3. Use search to filter
4. Toggle favorites filter
5. Click a meme to open full size in new tab

### Managing Memes

- **Favorite:** Click the star icon on any meme
- **Delete:** Click the X icon on any meme
- **Refresh:** Click the refresh button in header
- **Logout:** Click the logout button in header

## File Structure

```
chrome-extension/
├── manifest.json           # Extension configuration
├── background/
│   └── service-worker.js  # Background script for context menu & sync
├── popup/
│   ├── popup.html         # Main popup interface
│   ├── popup.js           # Popup logic
│   └── popup.css          # Popup styles
├── auth/
│   ├── login.html         # Login/signup page
│   └── login.js           # Auth logic
├── config/
│   └── firebase-config.js # Firebase configuration
└── assets/
    └── icons/             # Extension icons
```

## Permissions

- `contextMenus`: Add right-click menu option
- `storage`: Store auth state and cached data
- `activeTab`: Access current tab URL when saving
- `<all_urls>`: Download images from any website

## Known Issues

- Thumbnail generation not yet implemented (uses full image)
- No offline queue for failed uploads
- No bulk operations (delete multiple, export, etc.)

## Future Enhancements

- Thumbnail generation
- Bulk operations
- Export/import memes
- Tags management UI
- Keyboard shortcuts
- Image editing tools
- Collections/folders
- Share memes with friends

## Troubleshooting

### "Failed to save meme"
- Check Firebase configuration
- Verify internet connection
- Check browser console for errors

### "Not logged in" when trying to save
- Click extension icon
- Log in with your account
- Try saving again

### Images not loading in popup
- Check Firebase Storage rules
- Verify auth token is valid
- Check network tab in DevTools

## Support

For issues or questions, please open an issue on GitHub.
