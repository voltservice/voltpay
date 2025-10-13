import 'package:firebase_auth/firebase_auth.dart' as fb;

/// Centralized ActionCodeSettings for all email-link sends.
/// Adjust the values for your prod/non-prod envs.
fb.ActionCodeSettings buildEmailLinkActionCodeSettings() {
  // This URL must be on your project's Authorized Domains
  // and (if using Firebase Dynamic Links) use your `page.link` domain.
  return fb.ActionCodeSettings(
    url: 'https://voltpay.metalbrain.net/finishSignIn',
    handleCodeInApp: true,
    androidPackageName: 'net.metalbrain.voltpay',
    androidInstallApp: true,
    androidMinimumVersion: '1',
  );
}
