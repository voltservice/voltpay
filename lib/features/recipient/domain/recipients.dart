bool isValidEmail(String v) =>
    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);

bool isValidPhone(String v) => RegExp(r'^\+?[0-9]{6,15}$').hasMatch(v);

bool isValidVoltTag(String v) =>
    RegExp(r'^@?[a-zA-Z0-9._-]{3,30}$').hasMatch(v);

bool isValidIban(String v) {
  final String s = v.replaceAll(' ', '').toUpperCase();
  if (s.length < 15 || s.length > 34) {
    return false;
  }
  final String rearranged = s.substring(4) + s.substring(0, 4);
  final String converted = rearranged.split('').map((String c) {
    final int code = c.codeUnitAt(0);
    if (code >= 65 && code <= 90) {
      return (code - 55).toString(); // A=10
    }
    return c;
  }).join();
  // mod-97 (chunked)
  int remainder = 0;
  for (final String ch in converted.split('')) {
    remainder = int.parse('$remainder$ch') % 97;
  }
  return remainder == 1;
}

bool isValidSwift(String v) {
  final String s = v.replaceAll(' ', '').toUpperCase();

  // SWIFT/BIC must be 8 or 11 characters
  if (s.length != 8 && s.length != 11) {
    return false;
  }

  // 4 letters: bank code
  final String bank = s.substring(0, 4);
  if (!RegExp(r'^[A-Z]{4}$').hasMatch(bank)) {
    return false;
  }

  // 2 letters: ISO country code
  final String country = s.substring(4, 6);
  if (!RegExp(r'^[A-Z]{2}$').hasMatch(country)) {
    return false;
  }

  // 2 alphanumeric: location code
  final String location = s.substring(6, 8);
  if (!RegExp(r'^[A-Z0-9]{2}$').hasMatch(location)) {
    return false;
  }

  // Optional 3 alphanumeric: branch code (for 11-char BIC)
  if (s.length == 11) {
    final String branch = s.substring(8, 11);
    if (!RegExp(r'^[A-Z0-9]{3}$').hasMatch(branch)) {
      return false;
    }
  }

  return true;
}
