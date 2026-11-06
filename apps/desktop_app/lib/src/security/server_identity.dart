import 'dart:convert';
import 'dart:typed_data';

import 'package:basic_utils/basic_utils.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/export.dart';
import 'package:uuid/uuid.dart';

import 'totp.dart';

final class ServerIdentity {
  const ServerIdentity({
    required this.serverId,
    required this.certificatePem,
    required this.privateKeyPem,
    required this.certificateFingerprint,
    required this.totpSecret,
    required this.pairedDevices,
  });

  final String serverId;
  final String certificatePem;
  final String privateKeyPem;
  final String certificateFingerprint;
  final Uint8List totpSecret;
  final Map<String, PairedDevice> pairedDevices;
}

final class PairedDevice {
  const PairedDevice({
    required this.id,
    required this.name,
    required this.tokenHash,
  });

  final String id;
  final String name;
  final String tokenHash;

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'tokenHash': tokenHash,
  };

  factory PairedDevice.fromJson(Map<String, Object?> json) => PairedDevice(
    id: json['id']! as String,
    name: json['name']! as String,
    tokenHash: json['tokenHash']! as String,
  );
}

final class ServerIdentityStore {
  ServerIdentityStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const _storageKey = 'net_keyboard.server_identity.v1';
  final FlutterSecureStorage _storage;

  Future<ServerIdentity> loadOrCreate() async {
    final stored = await _storage.read(key: _storageKey);
    if (stored != null) return _decode(stored);
    final identity = _create();
    await save(identity);
    return identity;
  }

  Future<void> save(ServerIdentity identity) => _storage.write(
    key: _storageKey,
    value: jsonEncode({
      'serverId': identity.serverId,
      'certificatePem': identity.certificatePem,
      'privateKeyPem': identity.privateKeyPem,
      'totpSecret': encodeSecret(identity.totpSecret),
      'pairedDevices': [
        for (final device in identity.pairedDevices.values) device.toJson(),
      ],
    }),
  );

  ServerIdentity _create() {
    final pair = CryptoUtils.generateRSAKeyPair(keySize: 2048);
    final privateKey = pair.privateKey as RSAPrivateKey;
    final publicKey = pair.publicKey as RSAPublicKey;
    final attributes = <String, String>{
      'CN': 'Net Keyboard Receiver',
      'O': 'Net Keyboard',
      'C': 'CN',
    };
    final csr = X509Utils.generateRsaCsrPem(
      attributes,
      privateKey,
      publicKey,
      san: const ['localhost'],
    );
    final certificate = X509Utils.generateSelfSignedCertificate(
      privateKey,
      csr,
      3650,
      sans: const ['localhost'],
    );
    return ServerIdentity(
      serverId: const Uuid().v4(),
      certificatePem: certificate,
      privateKeyPem: CryptoUtils.encodeRSAPrivateKeyToPem(privateKey),
      certificateFingerprint: _fingerprint(certificate),
      totpSecret: secureRandomBytes(20),
      pairedDevices: {},
    );
  }

  ServerIdentity _decode(String source) {
    final json = jsonDecode(source) as Map<String, Object?>;
    final certificate = json['certificatePem']! as String;
    final devices = <String, PairedDevice>{};
    for (final raw in (json['pairedDevices'] as List? ?? const [])) {
      final device = PairedDevice.fromJson(
        (raw as Map).cast<String, Object?>(),
      );
      devices[device.id] = device;
    }
    return ServerIdentity(
      serverId: json['serverId']! as String,
      certificatePem: certificate,
      privateKeyPem: json['privateKeyPem']! as String,
      certificateFingerprint: _fingerprint(certificate),
      totpSecret: decodeSecret(json['totpSecret']! as String),
      pairedDevices: devices,
    );
  }

  static String tokenHash(List<int> token) => sha256.convert(token).toString();

  static String _fingerprint(String certificatePem) {
    final der = CryptoUtils.getBytesFromPEMString(certificatePem);
    return sha256
        .convert(der)
        .toString()
        .toUpperCase()
        .replaceAllMapped(RegExp(r'.{2}'), (match) => '${match.group(0)}:')
        .replaceFirst(RegExp(r':$'), '');
  }
}
