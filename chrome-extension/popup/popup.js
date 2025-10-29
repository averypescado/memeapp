// Initialize Firebase
firebase.initializeApp(firebaseConfig);
const auth = firebase.auth();
const db = firebase.firestore();
const storage = firebase.storage();

// State
let currentUser = null;
let allMemes = [];
let currentFilter = 'all';
let searchQuery = '';

// DOM elements
const loadingState = document.getElementById('loadingState');
const notLoggedInState = document.getElementById('notLoggedInState');
const loggedInState = document.getElementById('loggedInState');
const loginButton = document.getElementById('loginButton');
const logoutButton = document.getElementById('logoutButton');
const refreshButton = document.getElementById('refreshButton');
const searchInput = document.getElementById('searchInput');
const filterButtons = document.querySelectorAll('.filter-button');
const memesContainer = document.getElementById('memesContainer');
const emptyState = document.getElementById('emptyState');
const userEmail = document.getElementById('userEmail');
const memeCount = document.getElementById('memeCount');

// Initialize
init();

function init() {
  // Set up event listeners
  loginButton.addEventListener('click', openLoginPage);
  logoutButton.addEventListener('click', handleLogout);
  refreshButton.addEventListener('click', loadMemes);
  searchInput.addEventListener('input', handleSearch);

  filterButtons.forEach(button => {
    button.addEventListener('click', () => {
      currentFilter = button.dataset.filter;
      filterButtons.forEach(btn => btn.classList.remove('active'));
      button.classList.add('active');
      renderMemes();
    });
  });

  // Listen for auth state changes
  auth.onAuthStateChanged((user) => {
    currentUser = user;
    updateUI();
    if (user) {
      loadMemes();
    }
  });
}

function updateUI() {
  if (currentUser) {
    // Show logged in state
    loadingState.classList.add('hidden');
    notLoggedInState.classList.add('hidden');
    loggedInState.classList.remove('hidden');

    // Update user info
    userEmail.textContent = currentUser.email;
  } else {
    // Show not logged in state
    loadingState.classList.add('hidden');
    notLoggedInState.classList.remove('hidden');
    loggedInState.classList.add('hidden');
  }
}

function openLoginPage() {
  chrome.tabs.create({ url: chrome.runtime.getURL('auth/login.html') });
}

async function handleLogout() {
  try {
    await auth.signOut();
    allMemes = [];
    renderMemes();
  } catch (error) {
    console.error('Logout error:', error);
  }
}

async function loadMemes() {
  if (!currentUser) return;

  try {
    // Show loading state
    memesContainer.innerHTML = '<div class="loader"></div>';

    // Fetch memes from Firestore
    const snapshot = await db
      .collection('users')
      .doc(currentUser.uid)
      .collection('memes')
      .orderBy('createdAt', 'desc')
      .get();

    allMemes = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));

    renderMemes();
  } catch (error) {
    console.error('Error loading memes:', error);
    memesContainer.innerHTML = '<p style="text-align: center; color: #e74c3c;">Error loading memes</p>';
  }
}

function handleSearch(e) {
  searchQuery = e.target.value.toLowerCase();
  renderMemes();
}

function renderMemes() {
  // Filter memes
  let filteredMemes = allMemes;

  // Apply filter
  if (currentFilter === 'favorites') {
    filteredMemes = filteredMemes.filter(meme => meme.favorite);
  }

  // Apply search
  if (searchQuery) {
    filteredMemes = filteredMemes.filter(meme => {
      const tags = (meme.tags || []).join(' ').toLowerCase();
      const source = (meme.sourceUrl || '').toLowerCase();
      return tags.includes(searchQuery) || source.includes(searchQuery);
    });
  }

  // Update count
  memeCount.textContent = `${filteredMemes.length} meme${filteredMemes.length !== 1 ? 's' : ''}`;

  // Show empty state if no memes
  if (filteredMemes.length === 0) {
    memesContainer.classList.add('hidden');
    emptyState.classList.remove('hidden');
    return;
  }

  memesContainer.classList.remove('hidden');
  emptyState.classList.add('hidden');

  // Render meme cards
  memesContainer.innerHTML = filteredMemes.map(meme => `
    <div class="meme-card" data-id="${meme.id}">
      <img src="${meme.thumbnailUrl || meme.imageUrl}" alt="Meme" loading="lazy">
      <div class="meme-card-actions">
        <button class="action-button favorite ${meme.favorite ? 'active' : ''}"
                data-id="${meme.id}"
                title="Favorite">
          ${meme.favorite ? '★' : '☆'}
        </button>
        <button class="action-button delete"
                data-id="${meme.id}"
                title="Delete">
          ✕
        </button>
      </div>
    </div>
  `).join('');

  // Add event listeners to action buttons
  document.querySelectorAll('.action-button.favorite').forEach(button => {
    button.addEventListener('click', (e) => {
      e.stopPropagation();
      toggleFavorite(button.dataset.id);
    });
  });

  document.querySelectorAll('.action-button.delete').forEach(button => {
    button.addEventListener('click', (e) => {
      e.stopPropagation();
      deleteMeme(button.dataset.id);
    });
  });

  // Add click handler to meme cards (open in new tab)
  document.querySelectorAll('.meme-card').forEach(card => {
    card.addEventListener('click', () => {
      const meme = allMemes.find(m => m.id === card.dataset.id);
      if (meme) {
        chrome.tabs.create({ url: meme.imageUrl });
      }
    });
  });
}

async function toggleFavorite(memeId) {
  try {
    const meme = allMemes.find(m => m.id === memeId);
    if (!meme) return;

    const newFavoriteState = !meme.favorite;

    // Update Firestore
    await db
      .collection('users')
      .doc(currentUser.uid)
      .collection('memes')
      .doc(memeId)
      .update({
        favorite: newFavoriteState,
        updatedAt: firebase.firestore.FieldValue.serverTimestamp()
      });

    // Update local state
    meme.favorite = newFavoriteState;
    renderMemes();
  } catch (error) {
    console.error('Error toggling favorite:', error);
  }
}

async function deleteMeme(memeId) {
  if (!confirm('Are you sure you want to delete this meme?')) {
    return;
  }

  try {
    const meme = allMemes.find(m => m.id === memeId);
    if (!meme) return;

    // Delete from Storage
    try {
      const imageRef = storage.refFromURL(meme.imageUrl);
      await imageRef.delete();
    } catch (error) {
      console.error('Error deleting image from storage:', error);
    }

    // Delete from Firestore
    await db
      .collection('users')
      .doc(currentUser.uid)
      .collection('memes')
      .doc(memeId)
      .delete();

    // Update local state
    allMemes = allMemes.filter(m => m.id !== memeId);
    renderMemes();
  } catch (error) {
    console.error('Error deleting meme:', error);
    alert('Failed to delete meme');
  }
}
