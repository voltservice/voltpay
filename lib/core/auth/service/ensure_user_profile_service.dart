import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:http/http.dart' as http;

/// Calls your Go backend `/users/ensure` to create/update the Firestore user doc
/// after a successful sign-in (including email-link).
///
/// Returns true on 200 OK, false otherwise. You can handle 412 specifically
/// if you want to surface "email not verified" (shouldn't happen for email-link).
Future<bool> ensureProfile(String baseUrl, {http.Client? client}) async {
  final http.Client c = client ?? http.Client();
  try {
    final fb.User? u = fb.FirebaseAuth.instance.currentUser;
    if (u == null) {
      return false;
    }

    final String? idToken = await u.getIdToken(true);
    final Uri uri = Uri.parse(
      baseUrl.endsWith('/users/ensure')
          ? baseUrl
          : '${baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl}/users/ensure',
    );

    final http.Response resp = await c.post(
      uri,
      headers: <String, String>{'Authorization': 'Bearer $idToken'},
    );

    if (resp.statusCode == 200) {
      return true;
    }
    // Optional: handle 412 (email not verified) distinctly
    if (resp.statusCode == 412) {
      // You can throw or return false depending on UX.
      return false;
    }
    return false;
  } finally {
    if (client == null) {
      c.close();
    }
  }
}
