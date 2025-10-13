// import 'dart:async';
//
// import 'package:firebase_auth/firebase_auth.dart' as fb;
// import 'package:uni_links/uni_links.dart';
//
// class EmailLinkHandler {
//   StreamSubscription<Uri?>? _sub;
//
//   Future<void> init() async {
//     try {
//       final Uri? initial = await getInitialUri();
//       if (initial != null) {
//         await _handle(initial.toString());
//       }
//     } catch (_) {
//       // ignore malformed initial URIs
//     }
//
//     _sub = uriLinkStream.listen((Uri? uri) {
//       if (uri != null) {
//         _handle(uri.toString());
//       }
//     }, onError: (_) {
//       // ignore malformed runtime URIs
//     });
//   }
//
//   Future<void> _handle(String link) async {
//     final fb.FirebaseAuth auth = fb.FirebaseAuth.instance;
//     if (auth.isSignInWithEmailLink(link)) {
//       final String email =
//           await _restoreSavedEmail(); // <- you saved this when sending the link
//       await auth.signInWithEmailLink(email: email, emailLink: link);
//       // navigate to home
//     }
//   }
//
//   Future<String> _restoreSavedEmail() async {
//     // e.g. from shared_prefs or secure storage
//     // throw if missing to prompt re-entry
//     return 'finaluser@gmail.com';
//   }
//
//   void dispose() => _sub?.cancel();
// }
