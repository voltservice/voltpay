import { initializeApp } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-app.js";
import {
  getAuth,
  isSignInWithEmailLink,
  signInWithEmailLink,
} from "https://www.gstatic.com/firebasejs/10.12.2/firebase-auth.js";
import { firebaseConfig } from "./firebaseConfig.js";

(async function main() {
  const app = initializeApp(firebaseConfig);
  const auth = getAuth(app);

  const status = (t) => {
    const el = document.getElementById("status");
    if (el) el.textContent = t;
  };
  const link = window.location.href;

  if (!isSignInWithEmailLink(auth, link)) {
    status("Invalid sign-in link.");
    return;
  }

  let email =
    localStorage.getItem("emailForSignIn") ||
    window.prompt("Confirm your email:");
  if (!email) {
    status("Email required to finish sign-in.");
    return;
  }

  try {
    await signInWithEmailLink(auth, email.trim(), link);
    localStorage.removeItem("emailForSignIn");
    localStorage.setItem("justSignedInViaLink", "1"); // optional hint for Flutter
    // Hand off to your Flutter app
    window.location.replace("/"); // or "/service" or your preferred route
  } catch (err) {
    status("Sign-in failed: " + (err?.message || err));
  }
})();
