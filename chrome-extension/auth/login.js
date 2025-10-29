// Initialize Firebase
firebase.initializeApp(firebaseConfig);
const auth = firebase.auth();

// Tab switching
const tabs = document.querySelectorAll('.tab');
const loginForm = document.getElementById('loginForm');
const signupForm = document.getElementById('signupForm');

tabs.forEach(tab => {
  tab.addEventListener('click', () => {
    const tabName = tab.dataset.tab;

    // Update active tab
    tabs.forEach(t => t.classList.remove('active'));
    tab.classList.add('active');

    // Show/hide forms
    if (tabName === 'login') {
      loginForm.classList.remove('hidden');
      signupForm.classList.add('hidden');
    } else {
      loginForm.classList.add('hidden');
      signupForm.classList.remove('hidden');
    }

    // Clear all messages
    clearMessages();
  });
});

// Login form handler
loginForm.addEventListener('submit', async (e) => {
  e.preventDefault();

  const email = document.getElementById('loginEmail').value;
  const password = document.getElementById('loginPassword').value;
  const button = loginForm.querySelector('button[type="submit"]');
  const buttonText = button.querySelector('.button-text');

  clearMessages();
  button.disabled = true;
  buttonText.innerHTML = '<span class="loading"></span>Logging in...';

  try {
    await auth.signInWithEmailAndPassword(email, password);
    showMessage('loginSuccess', 'Login successful! Redirecting...');

    // Close this tab and open popup
    setTimeout(() => {
      window.close();
    }, 1500);
  } catch (error) {
    showMessage('loginError', getErrorMessage(error));
    button.disabled = false;
    buttonText.textContent = 'Login';
  }
});

// Signup form handler
signupForm.addEventListener('submit', async (e) => {
  e.preventDefault();

  const email = document.getElementById('signupEmail').value;
  const password = document.getElementById('signupPassword').value;
  const passwordConfirm = document.getElementById('signupPasswordConfirm').value;
  const button = signupForm.querySelector('button[type="submit"]');
  const buttonText = button.querySelector('.button-text');

  clearMessages();

  // Validate passwords match
  if (password !== passwordConfirm) {
    showMessage('signupError', 'Passwords do not match');
    return;
  }

  // Validate password length
  if (password.length < 6) {
    showMessage('signupError', 'Password must be at least 6 characters');
    return;
  }

  button.disabled = true;
  buttonText.innerHTML = '<span class="loading"></span>Creating account...';

  try {
    await auth.createUserWithEmailAndPassword(email, password);
    showMessage('signupSuccess', 'Account created successfully! Redirecting...');

    // Close this tab and open popup
    setTimeout(() => {
      window.close();
    }, 1500);
  } catch (error) {
    showMessage('signupError', getErrorMessage(error));
    button.disabled = false;
    buttonText.textContent = 'Create Account';
  }
});

// Helper functions
function showMessage(elementId, message) {
  const element = document.getElementById(elementId);
  element.textContent = message;
  element.classList.remove('hidden');
}

function clearMessages() {
  document.querySelectorAll('.error, .success').forEach(el => {
    el.classList.add('hidden');
    el.textContent = '';
  });
}

function getErrorMessage(error) {
  const errorMessages = {
    'auth/email-already-in-use': 'This email is already registered',
    'auth/invalid-email': 'Invalid email address',
    'auth/weak-password': 'Password is too weak',
    'auth/user-not-found': 'No account found with this email',
    'auth/wrong-password': 'Incorrect password',
    'auth/too-many-requests': 'Too many failed attempts. Please try again later'
  };

  return errorMessages[error.code] || error.message;
}

// Check if already logged in
auth.onAuthStateChanged((user) => {
  if (user) {
    showMessage('loginSuccess', 'Already logged in! Redirecting...');
    setTimeout(() => {
      window.close();
    }, 1000);
  }
});
