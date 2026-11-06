import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

Uint8List secureRandomBytes(int length) {
  final random = Random.secure();
  return Uint8List.fromList(List.generate(length, (_) => random.nextInt(256)));
}

String totpCode(Uint8List secret, {DateTime? now}) {
  final timestamp = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
  final counter = timestamp ~/ 30000;
  final message = ByteData(8)..setUint64(0, counter);
  final digest = Hmac(sha1, secret).convert(message.buffer.asUint8List()).bytes;
  final offset = digest.last & 0x0f;
  final binary =
      ((digest[offset] & 0x7f) << 24) |
      ((digest[offset + 1] & 0xff) << 16) |
      ((digest[offset + 2] & 0xff) << 8) |
      (digest[offset + 3] & 0xff);
  return (binary % 1000000).toString().padLeft(6, '0');
}

bool verifyTotp(Uint8List secret, String code, {DateTime? now}) {
  if (!RegExp(r'^\d{6}$').hasMatch(code)) return false;
  final current = now ?? DateTime.now();
  for (final offset in const [-30, 0, 30]) {
    if (_constantTimeEquals(
      totpCode(secret, now: current.add(Duration(seconds: offset))),
      code,
    ))
      return true;
  }
  return false;
}

String encodeSecret(Uint8List bytes) => base64UrlEncode(bytes);
Uint8List decodeSecret(String value) => base64Url.decode(value);

bool _constantTimeEquals(String expected, String actual) {
  if (expected.length != actual.length) return false;
  var difference = 0;
  for (var index = 0; index < expected.length; index++) {
    difference |= expected.codeUnitAt(index) ^ actual.codeUnitAt(index);
  }
  return difference == 0;
}
