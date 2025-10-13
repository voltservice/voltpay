// /scripts/optin.js

function byId(id) { return /** @type {HTMLElement|null} */ (document.getElementById(id)); }
function isAndroid() { return /Android/i.test(navigator.userAgent || ""); }

function tryOpenPlayApp() {
  const pkg = "net.metalbrain.voltpay";
  const intentUrl = `intent://details?id=${pkg}#Intent;scheme=market;package=com.android.vending;end`;
  window.open(intentUrl, "_blank", "noopener,noreferrer");
}

async function copy(text) {
  try { await navigator.clipboard.writeText(text); return true; }
  catch {
    const ta = document.createElement("textarea");
    ta.value = text; ta.style.position = "fixed"; ta.style.opacity = "0";
    document.body.appendChild(ta); ta.select();
    const ok = document.execCommand("copy");
    document.body.removeChild(ta); return ok;
  }
}

function toast(btn, msg) {
  if (!btn) return;
  const original = btn.textContent;
  btn.textContent = msg; btn.setAttribute("aria-live","polite");
  btn.disabled = true; setTimeout(() => { btn.textContent = original; btn.disabled = false; }, 1600);
}

// Heuristic for showing the success banner:
// - If user clicked the Opt-in button (we set localStorage flag), and
// - They either come back with ?optin=1 OR the referrer is a Play Testing URL,
// then we show the banner and clear the flag.
function shouldShowSuccess() {
  const clicked = localStorage.getItem("vp_optin_clicked") === "1";
  const params = new URLSearchParams(location.search);
  const hasParam = params.has("optin");
  const fromPlay = (document.referrer || "").includes("play.google.com/apps/testing");
  return clicked && (hasParam || fromPlay);
}

function init() {
  const copyBtn = byId("copyOptIn");
  const optInBtn = /** @type {HTMLAnchorElement|null} */ (byId("optInBtn"));
  const openInPlayBtn = /** @type {HTMLButtonElement|null} */ (byId("openInPlay"));
  const listingBtn = /** @type {HTMLAnchorElement|null} */ (byId("listingBtn"));
  const success = byId("optinSuccess");

  // Copy opt-in URL
  copyBtn?.addEventListener("click", async () => {
    const url = copyBtn.getAttribute("data-copy") || "";
    const ok = await copy(url);
    toast(copyBtn, ok ? "Copied ✓" : "Copy failed");
  });

  // Mark that user attempted to opt-in; we use this to show success later.
  optInBtn?.addEventListener("click", () => {
    localStorage.setItem("vp_optin_clicked", "1");
    // Add a tracking param for explicit success when they navigate back
    try {
      const u = new URL(optInBtn.href);
      u.searchParams.set("ref", "voltpay");
      optInBtn.href = u.toString();
    } catch {}
  });

  // On Android, surface an “Open in Play app” button
  if (isAndroid() && openInPlayBtn && listingBtn) {
    openInPlayBtn.hidden = false;
    openInPlayBtn.addEventListener("click", tryOpenPlayApp);
    listingBtn.textContent = "Open Play listing (web)";
  }

  // Success banner logic
  if (shouldShowSuccess() && success) {
    success.style.display = "block";
    // Clear the flag so it doesn't stick forever
    localStorage.removeItem("vp_optin_clicked");
    // Also strip ?optin=1 from the URL for cleanliness (no reload)
    const url = new URL(window.location.href);
    url.searchParams.delete("optin");
    history.replaceState({}, "", url);
  }
}

document.addEventListener("DOMContentLoaded", init);
