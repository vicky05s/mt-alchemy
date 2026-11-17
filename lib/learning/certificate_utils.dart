import 'package:flutter/foundation.dart';

/// The address a certificate QR code points to. On the web this is the
/// site's own URL with ?verify=<certificate id>, which opens the public
/// verification page. Elsewhere we fall back to a plain text code.
String verifyUrlFor(String certificateId) {
  if (kIsWeb) {
    final base = Uri.base;
    return '${base.origin}${base.path}?verify=$certificateId';
  }
  return 'MT-ALCHEMY-VERIFY:$certificateId';
}

/// Certificate ID in the page address (?verify=...), if any.
String? verifyIdFromUrl() {
  if (!kIsWeb) return null;
  final id = Uri.base.queryParameters['verify'];
  if (id == null || id.trim().isEmpty) return null;
  return id.trim();
}
