// This is a generated file - do not edit.
//
// Generated from remote_input.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'remote_input.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'remote_input.pbenum.dart';

class ProtocolVersion extends $pb.GeneratedMessage {
  factory ProtocolVersion({
    $core.int? major,
    $core.int? minor,
  }) {
    final result = ProtocolVersion._();
    if (major != null) result.major = major;
    if (minor != null) result.minor = minor;
    return result;
  }

  ProtocolVersion._();

  factory ProtocolVersion.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProtocolVersion()..mergeFromBuffer(data, registry);
  factory ProtocolVersion.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProtocolVersion()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProtocolVersion',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'netkeyboard.v1'),
      createEmptyInstance: ProtocolVersion.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'major', fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'minor', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProtocolVersion clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProtocolVersion copyWith(void Function(ProtocolVersion) updates) =>
      super.copyWith((message) => updates(message as ProtocolVersion))
          as ProtocolVersion;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ProtocolVersion() / ProtocolVersion.new instead')
  static ProtocolVersion create() => ProtocolVersion._();
  static $pb.GeneratedMessage $_createMessage() => ProtocolVersion._();
  @$core.override
  ProtocolVersion createEmptyInstance() => ProtocolVersion._();
  @$core.pragma('dart2js:noInline')
  static ProtocolVersion getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProtocolVersion>(
          ProtocolVersion.$_createMessage);
  static ProtocolVersion? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get major => $_getIZ(0);
  @$pb.TagNumber(1)
  set major($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMajor() => $_has(0);
  @$pb.TagNumber(1)
  void clearMajor() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get minor => $_getIZ(1);
  @$pb.TagNumber(2)
  set minor($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMinor() => $_has(1);
  @$pb.TagNumber(2)
  void clearMinor() => $_clearField(2);
}

class ServerInfoRequest extends $pb.GeneratedMessage {
  factory ServerInfoRequest() => ServerInfoRequest._();

  ServerInfoRequest._();

  factory ServerInfoRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ServerInfoRequest()..mergeFromBuffer(data, registry);
  factory ServerInfoRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ServerInfoRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ServerInfoRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'netkeyboard.v1'),
      createEmptyInstance: ServerInfoRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServerInfoRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServerInfoRequest copyWith(void Function(ServerInfoRequest) updates) =>
      super.copyWith((message) => updates(message as ServerInfoRequest))
          as ServerInfoRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ServerInfoRequest() / ServerInfoRequest.new instead')
  static ServerInfoRequest create() => ServerInfoRequest._();
  static $pb.GeneratedMessage $_createMessage() => ServerInfoRequest._();
  @$core.override
  ServerInfoRequest createEmptyInstance() => ServerInfoRequest._();
  @$core.pragma('dart2js:noInline')
  static ServerInfoRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ServerInfoRequest>(
          ServerInfoRequest.$_createMessage);
  static ServerInfoRequest? _defaultInstance;
}

class ServerInfoResponse extends $pb.GeneratedMessage {
  factory ServerInfoResponse({
    $core.String? serverId,
    $core.String? displayName,
    ProtocolVersion? protocolVersion,
    $core.String? certificateSha256,
    $core.Iterable<Capability>? capabilities,
    $core.bool? pairingEnabled,
  }) {
    final result = ServerInfoResponse._();
    if (serverId != null) result.serverId = serverId;
    if (displayName != null) result.displayName = displayName;
    if (protocolVersion != null) result.protocolVersion = protocolVersion;
    if (certificateSha256 != null) result.certificateSha256 = certificateSha256;
    if (capabilities != null) result.capabilities.addAll(capabilities);
    if (pairingEnabled != null) result.pairingEnabled = pairingEnabled;
    return result;
  }

  ServerInfoResponse._();

  factory ServerInfoResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ServerInfoResponse()..mergeFromBuffer(data, registry);
  factory ServerInfoResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ServerInfoResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ServerInfoResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'netkeyboard.v1'),
      createEmptyInstance: ServerInfoResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'serverId')
    ..aOS(2, _omitFieldNames ? '' : 'displayName')
    ..aOM<ProtocolVersion>(3, _omitFieldNames ? '' : 'protocolVersion',
        subBuilder: ProtocolVersion.$_createMessage)
    ..aOS(4, _omitFieldNames ? '' : 'certificateSha256')
    ..pc<Capability>(
        5, _omitFieldNames ? '' : 'capabilities', $pb.PbFieldType.KE,
        valueOf: Capability.valueOf,
        enumValues: Capability.values,
        defaultEnumValue: Capability.CAPABILITY_UNSPECIFIED)
    ..aOB(6, _omitFieldNames ? '' : 'pairingEnabled')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServerInfoResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServerInfoResponse copyWith(void Function(ServerInfoResponse) updates) =>
      super.copyWith((message) => updates(message as ServerInfoResponse))
          as ServerInfoResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ServerInfoResponse() / ServerInfoResponse.new instead')
  static ServerInfoResponse create() => ServerInfoResponse._();
  static $pb.GeneratedMessage $_createMessage() => ServerInfoResponse._();
  @$core.override
  ServerInfoResponse createEmptyInstance() => ServerInfoResponse._();
  @$core.pragma('dart2js:noInline')
  static ServerInfoResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ServerInfoResponse>(
          ServerInfoResponse.$_createMessage);
  static ServerInfoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get serverId => $_getSZ(0);
  @$pb.TagNumber(1)
  set serverId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasServerId() => $_has(0);
  @$pb.TagNumber(1)
  void clearServerId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get displayName => $_getSZ(1);
  @$pb.TagNumber(2)
  set displayName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDisplayName() => $_has(1);
  @$pb.TagNumber(2)
  void clearDisplayName() => $_clearField(2);

  @$pb.TagNumber(3)
  ProtocolVersion get protocolVersion => $_getN(2);
  @$pb.TagNumber(3)
  set protocolVersion(ProtocolVersion value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasProtocolVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearProtocolVersion() => $_clearField(3);
  @$pb.TagNumber(3)
  ProtocolVersion ensureProtocolVersion() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.String get certificateSha256 => $_getSZ(3);
  @$pb.TagNumber(4)
  set certificateSha256($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCertificateSha256() => $_has(3);
  @$pb.TagNumber(4)
  void clearCertificateSha256() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<Capability> get capabilities => $_getList(4);

  @$pb.TagNumber(6)
  $core.bool get pairingEnabled => $_getBF(5);
  @$pb.TagNumber(6)
  set pairingEnabled($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPairingEnabled() => $_has(5);
  @$pb.TagNumber(6)
  void clearPairingEnabled() => $_clearField(6);
}

class PairingChallengeRequest extends $pb.GeneratedMessage {
  factory PairingChallengeRequest({
    $core.String? clientInstanceId,
  }) {
    final result = PairingChallengeRequest._();
    if (clientInstanceId != null) result.clientInstanceId = clientInstanceId;
    return result;
  }

  PairingChallengeRequest._();

  factory PairingChallengeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PairingChallengeRequest()..mergeFromBuffer(data, registry);
  factory PairingChallengeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PairingChallengeRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PairingChallengeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'netkeyboard.v1'),
      createEmptyInstance: PairingChallengeRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'clientInstanceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PairingChallengeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PairingChallengeRequest copyWith(
          void Function(PairingChallengeRequest) updates) =>
      super.copyWith((message) => updates(message as PairingChallengeRequest))
          as PairingChallengeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PairingChallengeRequest() / PairingChallengeRequest.new instead')
  static PairingChallengeRequest create() => PairingChallengeRequest._();
  static $pb.GeneratedMessage $_createMessage() => PairingChallengeRequest._();
  @$core.override
  PairingChallengeRequest createEmptyInstance() => PairingChallengeRequest._();
  @$core.pragma('dart2js:noInline')
  static PairingChallengeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PairingChallengeRequest>(
          PairingChallengeRequest.$_createMessage);
  static PairingChallengeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get clientInstanceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set clientInstanceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasClientInstanceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearClientInstanceId() => $_clearField(1);
}

class PairingChallengeResponse extends $pb.GeneratedMessage {
  factory PairingChallengeResponse({
    $core.String? challengeId,
    $core.List<$core.int>? serverNonce,
    $fixnum.Int64? expiresAtUnixMs,
  }) {
    final result = PairingChallengeResponse._();
    if (challengeId != null) result.challengeId = challengeId;
    if (serverNonce != null) result.serverNonce = serverNonce;
    if (expiresAtUnixMs != null) result.expiresAtUnixMs = expiresAtUnixMs;
    return result;
  }

  PairingChallengeResponse._();

  factory PairingChallengeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PairingChallengeResponse()..mergeFromBuffer(data, registry);
  factory PairingChallengeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PairingChallengeResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PairingChallengeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'netkeyboard.v1'),
      createEmptyInstance: PairingChallengeResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'challengeId')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'serverNonce', $pb.PbFieldType.OY)
    ..aInt64(3, _omitFieldNames ? '' : 'expiresAtUnixMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PairingChallengeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PairingChallengeResponse copyWith(
          void Function(PairingChallengeResponse) updates) =>
      super.copyWith((message) => updates(message as PairingChallengeResponse))
          as PairingChallengeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PairingChallengeResponse() / PairingChallengeResponse.new instead')
  static PairingChallengeResponse create() => PairingChallengeResponse._();
  static $pb.GeneratedMessage $_createMessage() => PairingChallengeResponse._();
  @$core.override
  PairingChallengeResponse createEmptyInstance() =>
      PairingChallengeResponse._();
  @$core.pragma('dart2js:noInline')
  static PairingChallengeResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PairingChallengeResponse>(
          PairingChallengeResponse.$_createMessage);
  static PairingChallengeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get challengeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set challengeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChallengeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChallengeId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get serverNonce => $_getN(1);
  @$pb.TagNumber(2)
  set serverNonce($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasServerNonce() => $_has(1);
  @$pb.TagNumber(2)
  void clearServerNonce() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get expiresAtUnixMs => $_getI64(2);
  @$pb.TagNumber(3)
  set expiresAtUnixMs($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasExpiresAtUnixMs() => $_has(2);
  @$pb.TagNumber(3)
  void clearExpiresAtUnixMs() => $_clearField(3);
}

class PairRequest extends $pb.GeneratedMessage {
  factory PairRequest({
    $core.String? challengeId,
    $core.String? clientInstanceId,
    $core.String? clientName,
    $core.String? totpCode,
    $core.List<$core.int>? clientNonce,
    ProtocolVersion? protocolVersion,
  }) {
    final result = PairRequest._();
    if (challengeId != null) result.challengeId = challengeId;
    if (clientInstanceId != null) result.clientInstanceId = clientInstanceId;
    if (clientName != null) result.clientName = clientName;
    if (totpCode != null) result.totpCode = totpCode;
    if (clientNonce != null) result.clientNonce = clientNonce;
    if (protocolVersion != null) result.protocolVersion = protocolVersion;
    return result;
  }

  PairRequest._();

  factory PairRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PairRequest()..mergeFromBuffer(data, registry);
  factory PairRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PairRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PairRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'netkeyboard.v1'),
      createEmptyInstance: PairRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'challengeId')
    ..aOS(2, _omitFieldNames ? '' : 'clientInstanceId')
    ..aOS(3, _omitFieldNames ? '' : 'clientName')
    ..aOS(4, _omitFieldNames ? '' : 'totpCode')
    ..a<$core.List<$core.int>>(
        5, _omitFieldNames ? '' : 'clientNonce', $pb.PbFieldType.OY)
    ..aOM<ProtocolVersion>(6, _omitFieldNames ? '' : 'protocolVersion',
        subBuilder: ProtocolVersion.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PairRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PairRequest copyWith(void Function(PairRequest) updates) =>
      super.copyWith((message) => updates(message as PairRequest))
          as PairRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PairRequest() / PairRequest.new instead')
  static PairRequest create() => PairRequest._();
  static $pb.GeneratedMessage $_createMessage() => PairRequest._();
  @$core.override
  PairRequest createEmptyInstance() => PairRequest._();
  @$core.pragma('dart2js:noInline')
  static PairRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PairRequest>(
          PairRequest.$_createMessage);
  static PairRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get challengeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set challengeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChallengeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChallengeId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get clientInstanceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set clientInstanceId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasClientInstanceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearClientInstanceId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get clientName => $_getSZ(2);
  @$pb.TagNumber(3)
  set clientName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasClientName() => $_has(2);
  @$pb.TagNumber(3)
  void clearClientName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get totpCode => $_getSZ(3);
  @$pb.TagNumber(4)
  set totpCode($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTotpCode() => $_has(3);
  @$pb.TagNumber(4)
  void clearTotpCode() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.List<$core.int> get clientNonce => $_getN(4);
  @$pb.TagNumber(5)
  set clientNonce($core.List<$core.int> value) => $_setBytes(4, value);
  @$pb.TagNumber(5)
  $core.bool hasClientNonce() => $_has(4);
  @$pb.TagNumber(5)
  void clearClientNonce() => $_clearField(5);

  @$pb.TagNumber(6)
  ProtocolVersion get protocolVersion => $_getN(5);
  @$pb.TagNumber(6)
  set protocolVersion(ProtocolVersion value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasProtocolVersion() => $_has(5);
  @$pb.TagNumber(6)
  void clearProtocolVersion() => $_clearField(6);
  @$pb.TagNumber(6)
  ProtocolVersion ensureProtocolVersion() => $_ensure(5);
}

class PairResponse extends $pb.GeneratedMessage {
  factory PairResponse({
    $core.String? pairedDeviceId,
    $core.List<$core.int>? bearerToken,
    $core.String? serverId,
    ProtocolVersion? protocolVersion,
    $core.Iterable<Capability>? capabilities,
    $fixnum.Int64? tokenCreatedAtUnixMs,
  }) {
    final result = PairResponse._();
    if (pairedDeviceId != null) result.pairedDeviceId = pairedDeviceId;
    if (bearerToken != null) result.bearerToken = bearerToken;
    if (serverId != null) result.serverId = serverId;
    if (protocolVersion != null) result.protocolVersion = protocolVersion;
    if (capabilities != null) result.capabilities.addAll(capabilities);
    if (tokenCreatedAtUnixMs != null)
      result.tokenCreatedAtUnixMs = tokenCreatedAtUnixMs;
    return result;
  }

  PairResponse._();

  factory PairResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PairResponse()..mergeFromBuffer(data, registry);
  factory PairResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PairResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PairResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'netkeyboard.v1'),
      createEmptyInstance: PairResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'pairedDeviceId')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'bearerToken', $pb.PbFieldType.OY)
    ..aOS(3, _omitFieldNames ? '' : 'serverId')
    ..aOM<ProtocolVersion>(4, _omitFieldNames ? '' : 'protocolVersion',
        subBuilder: ProtocolVersion.$_createMessage)
    ..pc<Capability>(
        5, _omitFieldNames ? '' : 'capabilities', $pb.PbFieldType.KE,
        valueOf: Capability.valueOf,
        enumValues: Capability.values,
        defaultEnumValue: Capability.CAPABILITY_UNSPECIFIED)
    ..aInt64(6, _omitFieldNames ? '' : 'tokenCreatedAtUnixMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PairResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PairResponse copyWith(void Function(PairResponse) updates) =>
      super.copyWith((message) => updates(message as PairResponse))
          as PairResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PairResponse() / PairResponse.new instead')
  static PairResponse create() => PairResponse._();
  static $pb.GeneratedMessage $_createMessage() => PairResponse._();
  @$core.override
  PairResponse createEmptyInstance() => PairResponse._();
  @$core.pragma('dart2js:noInline')
  static PairResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PairResponse>(
          PairResponse.$_createMessage);
  static PairResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get pairedDeviceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set pairedDeviceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPairedDeviceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPairedDeviceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get bearerToken => $_getN(1);
  @$pb.TagNumber(2)
  set bearerToken($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBearerToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearBearerToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get serverId => $_getSZ(2);
  @$pb.TagNumber(3)
  set serverId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasServerId() => $_has(2);
  @$pb.TagNumber(3)
  void clearServerId() => $_clearField(3);

  @$pb.TagNumber(4)
  ProtocolVersion get protocolVersion => $_getN(3);
  @$pb.TagNumber(4)
  set protocolVersion(ProtocolVersion value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasProtocolVersion() => $_has(3);
  @$pb.TagNumber(4)
  void clearProtocolVersion() => $_clearField(4);
  @$pb.TagNumber(4)
  ProtocolVersion ensureProtocolVersion() => $_ensure(3);

  @$pb.TagNumber(5)
  $pb.PbList<Capability> get capabilities => $_getList(4);

  @$pb.TagNumber(6)
  $fixnum.Int64 get tokenCreatedAtUnixMs => $_getI64(5);
  @$pb.TagNumber(6)
  set tokenCreatedAtUnixMs($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTokenCreatedAtUnixMs() => $_has(5);
  @$pb.TagNumber(6)
  void clearTokenCreatedAtUnixMs() => $_clearField(6);
}

enum ClientEnvelope_Payload {
  hello,
  keyStroke,
  textInput,
  ping,
  pointerInput,
  notSet
}

class ClientEnvelope extends $pb.GeneratedMessage {
  factory ClientEnvelope({
    $fixnum.Int64? sequence,
    $core.String? eventId,
    ClientHello? hello,
    KeyStroke? keyStroke,
    TextInput? textInput,
    Ping? ping,
    PointerInput? pointerInput,
  }) {
    final result = ClientEnvelope._();
    if (sequence != null) result.sequence = sequence;
    if (eventId != null) result.eventId = eventId;
    if (hello != null) result.hello = hello;
    if (keyStroke != null) result.keyStroke = keyStroke;
    if (textInput != null) result.textInput = textInput;
    if (ping != null) result.ping = ping;
    if (pointerInput != null) result.pointerInput = pointerInput;
    return result;
  }

  ClientEnvelope._();

  factory ClientEnvelope.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientEnvelope()..mergeFromBuffer(data, registry);
  factory ClientEnvelope.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientEnvelope()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, ClientEnvelope_Payload>
      _ClientEnvelope_PayloadByTag = {
    10: ClientEnvelope_Payload.hello,
    11: ClientEnvelope_Payload.keyStroke,
    12: ClientEnvelope_Payload.textInput,
    13: ClientEnvelope_Payload.ping,
    14: ClientEnvelope_Payload.pointerInput,
    0: ClientEnvelope_Payload.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientEnvelope',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'netkeyboard.v1'),
      createEmptyInstance: ClientEnvelope.$_createMessage)
    ..oo(0, [10, 11, 12, 13, 14])
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'sequence', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'eventId')
    ..aOM<ClientHello>(10, _omitFieldNames ? '' : 'hello',
        subBuilder: ClientHello.$_createMessage)
    ..aOM<KeyStroke>(11, _omitFieldNames ? '' : 'keyStroke',
        subBuilder: KeyStroke.$_createMessage)
    ..aOM<TextInput>(12, _omitFieldNames ? '' : 'textInput',
        subBuilder: TextInput.$_createMessage)
    ..aOM<Ping>(13, _omitFieldNames ? '' : 'ping',
        subBuilder: Ping.$_createMessage)
    ..aOM<PointerInput>(14, _omitFieldNames ? '' : 'pointerInput',
        subBuilder: PointerInput.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientEnvelope clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientEnvelope copyWith(void Function(ClientEnvelope) updates) =>
      super.copyWith((message) => updates(message as ClientEnvelope))
          as ClientEnvelope;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ClientEnvelope() / ClientEnvelope.new instead')
  static ClientEnvelope create() => ClientEnvelope._();
  static $pb.GeneratedMessage $_createMessage() => ClientEnvelope._();
  @$core.override
  ClientEnvelope createEmptyInstance() => ClientEnvelope._();
  @$core.pragma('dart2js:noInline')
  static ClientEnvelope getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientEnvelope>(
          ClientEnvelope.$_createMessage);
  static ClientEnvelope? _defaultInstance;

  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  @$pb.TagNumber(13)
  @$pb.TagNumber(14)
  ClientEnvelope_Payload whichPayload() =>
      _ClientEnvelope_PayloadByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  @$pb.TagNumber(13)
  @$pb.TagNumber(14)
  void clearPayload() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $fixnum.Int64 get sequence => $_getI64(0);
  @$pb.TagNumber(1)
  set sequence($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSequence() => $_has(0);
  @$pb.TagNumber(1)
  void clearSequence() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get eventId => $_getSZ(1);
  @$pb.TagNumber(2)
  set eventId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEventId() => $_has(1);
  @$pb.TagNumber(2)
  void clearEventId() => $_clearField(2);

  @$pb.TagNumber(10)
  ClientHello get hello => $_getN(2);
  @$pb.TagNumber(10)
  set hello(ClientHello value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasHello() => $_has(2);
  @$pb.TagNumber(10)
  void clearHello() => $_clearField(10);
  @$pb.TagNumber(10)
  ClientHello ensureHello() => $_ensure(2);

  @$pb.TagNumber(11)
  KeyStroke get keyStroke => $_getN(3);
  @$pb.TagNumber(11)
  set keyStroke(KeyStroke value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasKeyStroke() => $_has(3);
  @$pb.TagNumber(11)
  void clearKeyStroke() => $_clearField(11);
  @$pb.TagNumber(11)
  KeyStroke ensureKeyStroke() => $_ensure(3);

  @$pb.TagNumber(12)
  TextInput get textInput => $_getN(4);
  @$pb.TagNumber(12)
  set textInput(TextInput value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasTextInput() => $_has(4);
  @$pb.TagNumber(12)
  void clearTextInput() => $_clearField(12);
  @$pb.TagNumber(12)
  TextInput ensureTextInput() => $_ensure(4);

  @$pb.TagNumber(13)
  Ping get ping => $_getN(5);
  @$pb.TagNumber(13)
  set ping(Ping value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasPing() => $_has(5);
  @$pb.TagNumber(13)
  void clearPing() => $_clearField(13);
  @$pb.TagNumber(13)
  Ping ensurePing() => $_ensure(5);

  @$pb.TagNumber(14)
  PointerInput get pointerInput => $_getN(6);
  @$pb.TagNumber(14)
  set pointerInput(PointerInput value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasPointerInput() => $_has(6);
  @$pb.TagNumber(14)
  void clearPointerInput() => $_clearField(14);
  @$pb.TagNumber(14)
  PointerInput ensurePointerInput() => $_ensure(6);
}

enum ServerEnvelope_Payload { hello, result, pong, closing, notSet }

class ServerEnvelope extends $pb.GeneratedMessage {
  factory ServerEnvelope({
    $fixnum.Int64? acknowledgedSequence,
    ServerHello? hello,
    CommandResult? result,
    Pong? pong,
    SessionClosing? closing,
  }) {
    final result$ = ServerEnvelope._();
    if (acknowledgedSequence != null)
      result$.acknowledgedSequence = acknowledgedSequence;
    if (hello != null) result$.hello = hello;
    if (result != null) result$.result = result;
    if (pong != null) result$.pong = pong;
    if (closing != null) result$.closing = closing;
    return result$;
  }

  ServerEnvelope._();

  factory ServerEnvelope.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ServerEnvelope()..mergeFromBuffer(data, registry);
  factory ServerEnvelope.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ServerEnvelope()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, ServerEnvelope_Payload>
      _ServerEnvelope_PayloadByTag = {
    10: ServerEnvelope_Payload.hello,
    11: ServerEnvelope_Payload.result,
    12: ServerEnvelope_Payload.pong,
    13: ServerEnvelope_Payload.closing,
    0: ServerEnvelope_Payload.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ServerEnvelope',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'netkeyboard.v1'),
      createEmptyInstance: ServerEnvelope.$_createMessage)
    ..oo(0, [10, 11, 12, 13])
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'acknowledgedSequence', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<ServerHello>(10, _omitFieldNames ? '' : 'hello',
        subBuilder: ServerHello.$_createMessage)
    ..aOM<CommandResult>(11, _omitFieldNames ? '' : 'result',
        subBuilder: CommandResult.$_createMessage)
    ..aOM<Pong>(12, _omitFieldNames ? '' : 'pong',
        subBuilder: Pong.$_createMessage)
    ..aOM<SessionClosing>(13, _omitFieldNames ? '' : 'closing',
        subBuilder: SessionClosing.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServerEnvelope clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServerEnvelope copyWith(void Function(ServerEnvelope) updates) =>
      super.copyWith((message) => updates(message as ServerEnvelope))
          as ServerEnvelope;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ServerEnvelope() / ServerEnvelope.new instead')
  static ServerEnvelope create() => ServerEnvelope._();
  static $pb.GeneratedMessage $_createMessage() => ServerEnvelope._();
  @$core.override
  ServerEnvelope createEmptyInstance() => ServerEnvelope._();
  @$core.pragma('dart2js:noInline')
  static ServerEnvelope getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ServerEnvelope>(
          ServerEnvelope.$_createMessage);
  static ServerEnvelope? _defaultInstance;

  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  @$pb.TagNumber(13)
  ServerEnvelope_Payload whichPayload() =>
      _ServerEnvelope_PayloadByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  @$pb.TagNumber(13)
  void clearPayload() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $fixnum.Int64 get acknowledgedSequence => $_getI64(0);
  @$pb.TagNumber(1)
  set acknowledgedSequence($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAcknowledgedSequence() => $_has(0);
  @$pb.TagNumber(1)
  void clearAcknowledgedSequence() => $_clearField(1);

  @$pb.TagNumber(10)
  ServerHello get hello => $_getN(1);
  @$pb.TagNumber(10)
  set hello(ServerHello value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasHello() => $_has(1);
  @$pb.TagNumber(10)
  void clearHello() => $_clearField(10);
  @$pb.TagNumber(10)
  ServerHello ensureHello() => $_ensure(1);

  @$pb.TagNumber(11)
  CommandResult get result => $_getN(2);
  @$pb.TagNumber(11)
  set result(CommandResult value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasResult() => $_has(2);
  @$pb.TagNumber(11)
  void clearResult() => $_clearField(11);
  @$pb.TagNumber(11)
  CommandResult ensureResult() => $_ensure(2);

  @$pb.TagNumber(12)
  Pong get pong => $_getN(3);
  @$pb.TagNumber(12)
  set pong(Pong value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasPong() => $_has(3);
  @$pb.TagNumber(12)
  void clearPong() => $_clearField(12);
  @$pb.TagNumber(12)
  Pong ensurePong() => $_ensure(3);

  @$pb.TagNumber(13)
  SessionClosing get closing => $_getN(4);
  @$pb.TagNumber(13)
  set closing(SessionClosing value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasClosing() => $_has(4);
  @$pb.TagNumber(13)
  void clearClosing() => $_clearField(13);
  @$pb.TagNumber(13)
  SessionClosing ensureClosing() => $_ensure(4);
}

class ClientHello extends $pb.GeneratedMessage {
  factory ClientHello({
    $core.String? clientInstanceId,
    $core.String? clientName,
    ProtocolVersion? protocolVersion,
    $core.Iterable<Capability>? capabilities,
  }) {
    final result = ClientHello._();
    if (clientInstanceId != null) result.clientInstanceId = clientInstanceId;
    if (clientName != null) result.clientName = clientName;
    if (protocolVersion != null) result.protocolVersion = protocolVersion;
    if (capabilities != null) result.capabilities.addAll(capabilities);
    return result;
  }

  ClientHello._();

  factory ClientHello.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientHello()..mergeFromBuffer(data, registry);
  factory ClientHello.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientHello()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientHello',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'netkeyboard.v1'),
      createEmptyInstance: ClientHello.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'clientInstanceId')
    ..aOS(2, _omitFieldNames ? '' : 'clientName')
    ..aOM<ProtocolVersion>(3, _omitFieldNames ? '' : 'protocolVersion',
        subBuilder: ProtocolVersion.$_createMessage)
    ..pc<Capability>(
        4, _omitFieldNames ? '' : 'capabilities', $pb.PbFieldType.KE,
        valueOf: Capability.valueOf,
        enumValues: Capability.values,
        defaultEnumValue: Capability.CAPABILITY_UNSPECIFIED)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientHello clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientHello copyWith(void Function(ClientHello) updates) =>
      super.copyWith((message) => updates(message as ClientHello))
          as ClientHello;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ClientHello() / ClientHello.new instead')
  static ClientHello create() => ClientHello._();
  static $pb.GeneratedMessage $_createMessage() => ClientHello._();
  @$core.override
  ClientHello createEmptyInstance() => ClientHello._();
  @$core.pragma('dart2js:noInline')
  static ClientHello getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientHello>(
          ClientHello.$_createMessage);
  static ClientHello? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get clientInstanceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set clientInstanceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasClientInstanceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearClientInstanceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get clientName => $_getSZ(1);
  @$pb.TagNumber(2)
  set clientName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasClientName() => $_has(1);
  @$pb.TagNumber(2)
  void clearClientName() => $_clearField(2);

  @$pb.TagNumber(3)
  ProtocolVersion get protocolVersion => $_getN(2);
  @$pb.TagNumber(3)
  set protocolVersion(ProtocolVersion value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasProtocolVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearProtocolVersion() => $_clearField(3);
  @$pb.TagNumber(3)
  ProtocolVersion ensureProtocolVersion() => $_ensure(2);

  @$pb.TagNumber(4)
  $pb.PbList<Capability> get capabilities => $_getList(3);
}

class ServerHello extends $pb.GeneratedMessage {
  factory ServerHello({
    $core.String? serverId,
    $core.String? displayName,
    ProtocolVersion? protocolVersion,
    $core.Iterable<Capability>? capabilities,
    $core.int? heartbeatIntervalSeconds,
  }) {
    final result = ServerHello._();
    if (serverId != null) result.serverId = serverId;
    if (displayName != null) result.displayName = displayName;
    if (protocolVersion != null) result.protocolVersion = protocolVersion;
    if (capabilities != null) result.capabilities.addAll(capabilities);
    if (heartbeatIntervalSeconds != null)
      result.heartbeatIntervalSeconds = heartbeatIntervalSeconds;
    return result;
  }

  ServerHello._();

  factory ServerHello.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ServerHello()..mergeFromBuffer(data, registry);
  factory ServerHello.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ServerHello()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ServerHello',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'netkeyboard.v1'),
      createEmptyInstance: ServerHello.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'serverId')
    ..aOS(2, _omitFieldNames ? '' : 'displayName')
    ..aOM<ProtocolVersion>(3, _omitFieldNames ? '' : 'protocolVersion',
        subBuilder: ProtocolVersion.$_createMessage)
    ..pc<Capability>(
        4, _omitFieldNames ? '' : 'capabilities', $pb.PbFieldType.KE,
        valueOf: Capability.valueOf,
        enumValues: Capability.values,
        defaultEnumValue: Capability.CAPABILITY_UNSPECIFIED)
    ..aI(5, _omitFieldNames ? '' : 'heartbeatIntervalSeconds',
        fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServerHello clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServerHello copyWith(void Function(ServerHello) updates) =>
      super.copyWith((message) => updates(message as ServerHello))
          as ServerHello;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ServerHello() / ServerHello.new instead')
  static ServerHello create() => ServerHello._();
  static $pb.GeneratedMessage $_createMessage() => ServerHello._();
  @$core.override
  ServerHello createEmptyInstance() => ServerHello._();
  @$core.pragma('dart2js:noInline')
  static ServerHello getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ServerHello>(
          ServerHello.$_createMessage);
  static ServerHello? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get serverId => $_getSZ(0);
  @$pb.TagNumber(1)
  set serverId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasServerId() => $_has(0);
  @$pb.TagNumber(1)
  void clearServerId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get displayName => $_getSZ(1);
  @$pb.TagNumber(2)
  set displayName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDisplayName() => $_has(1);
  @$pb.TagNumber(2)
  void clearDisplayName() => $_clearField(2);

  @$pb.TagNumber(3)
  ProtocolVersion get protocolVersion => $_getN(2);
  @$pb.TagNumber(3)
  set protocolVersion(ProtocolVersion value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasProtocolVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearProtocolVersion() => $_clearField(3);
  @$pb.TagNumber(3)
  ProtocolVersion ensureProtocolVersion() => $_ensure(2);

  @$pb.TagNumber(4)
  $pb.PbList<Capability> get capabilities => $_getList(3);

  @$pb.TagNumber(5)
  $core.int get heartbeatIntervalSeconds => $_getIZ(4);
  @$pb.TagNumber(5)
  set heartbeatIntervalSeconds($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasHeartbeatIntervalSeconds() => $_has(4);
  @$pb.TagNumber(5)
  void clearHeartbeatIntervalSeconds() => $_clearField(5);
}

class KeyStroke extends $pb.GeneratedMessage {
  factory KeyStroke({
    SemanticKey? key,
    $core.int? modifierBits,
    $core.bool? repeated,
  }) {
    final result = KeyStroke._();
    if (key != null) result.key = key;
    if (modifierBits != null) result.modifierBits = modifierBits;
    if (repeated != null) result.repeated = repeated;
    return result;
  }

  KeyStroke._();

  factory KeyStroke.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      KeyStroke()..mergeFromBuffer(data, registry);
  factory KeyStroke.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      KeyStroke()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'KeyStroke',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'netkeyboard.v1'),
      createEmptyInstance: KeyStroke.$_createMessage)
    ..aE<SemanticKey>(1, _omitFieldNames ? '' : 'key',
        enumValues: SemanticKey.values)
    ..aI(2, _omitFieldNames ? '' : 'modifierBits',
        fieldType: $pb.PbFieldType.OU3)
    ..aOB(3, _omitFieldNames ? '' : 'repeated')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KeyStroke clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KeyStroke copyWith(void Function(KeyStroke) updates) =>
      super.copyWith((message) => updates(message as KeyStroke)) as KeyStroke;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use KeyStroke() / KeyStroke.new instead')
  static KeyStroke create() => KeyStroke._();
  static $pb.GeneratedMessage $_createMessage() => KeyStroke._();
  @$core.override
  KeyStroke createEmptyInstance() => KeyStroke._();
  @$core.pragma('dart2js:noInline')
  static KeyStroke getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<KeyStroke>(KeyStroke.$_createMessage);
  static KeyStroke? _defaultInstance;

  @$pb.TagNumber(1)
  SemanticKey get key => $_getN(0);
  @$pb.TagNumber(1)
  set key(SemanticKey value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get modifierBits => $_getIZ(1);
  @$pb.TagNumber(2)
  set modifierBits($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasModifierBits() => $_has(1);
  @$pb.TagNumber(2)
  void clearModifierBits() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get repeated => $_getBF(2);
  @$pb.TagNumber(3)
  set repeated($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRepeated() => $_has(2);
  @$pb.TagNumber(3)
  void clearRepeated() => $_clearField(3);
}

class TextInput extends $pb.GeneratedMessage {
  factory TextInput({
    $core.String? text,
  }) {
    final result = TextInput._();
    if (text != null) result.text = text;
    return result;
  }

  TextInput._();

  factory TextInput.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TextInput()..mergeFromBuffer(data, registry);
  factory TextInput.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TextInput()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TextInput',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'netkeyboard.v1'),
      createEmptyInstance: TextInput.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'text')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TextInput clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TextInput copyWith(void Function(TextInput) updates) =>
      super.copyWith((message) => updates(message as TextInput)) as TextInput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TextInput() / TextInput.new instead')
  static TextInput create() => TextInput._();
  static $pb.GeneratedMessage $_createMessage() => TextInput._();
  @$core.override
  TextInput createEmptyInstance() => TextInput._();
  @$core.pragma('dart2js:noInline')
  static TextInput getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TextInput>(TextInput.$_createMessage);
  static TextInput? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get text => $_getSZ(0);
  @$pb.TagNumber(1)
  set text($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasText() => $_has(0);
  @$pb.TagNumber(1)
  void clearText() => $_clearField(1);
}

class PointerInput extends $pb.GeneratedMessage {
  factory PointerInput({
    $core.int? deltaX,
    $core.int? deltaY,
    $core.int? wheelDelta,
    PointerButton? button,
    $core.bool? buttonDown,
    $core.int? horizontalWheelDelta,
  }) {
    final result = PointerInput._();
    if (deltaX != null) result.deltaX = deltaX;
    if (deltaY != null) result.deltaY = deltaY;
    if (wheelDelta != null) result.wheelDelta = wheelDelta;
    if (button != null) result.button = button;
    if (buttonDown != null) result.buttonDown = buttonDown;
    if (horizontalWheelDelta != null)
      result.horizontalWheelDelta = horizontalWheelDelta;
    return result;
  }

  PointerInput._();

  factory PointerInput.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PointerInput()..mergeFromBuffer(data, registry);
  factory PointerInput.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PointerInput()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PointerInput',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'netkeyboard.v1'),
      createEmptyInstance: PointerInput.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'deltaX', fieldType: $pb.PbFieldType.OS3)
    ..aI(2, _omitFieldNames ? '' : 'deltaY', fieldType: $pb.PbFieldType.OS3)
    ..aI(3, _omitFieldNames ? '' : 'wheelDelta', fieldType: $pb.PbFieldType.OS3)
    ..aE<PointerButton>(4, _omitFieldNames ? '' : 'button',
        enumValues: PointerButton.values)
    ..aOB(5, _omitFieldNames ? '' : 'buttonDown')
    ..aI(7, _omitFieldNames ? '' : 'horizontalWheelDelta',
        fieldType: $pb.PbFieldType.OS3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PointerInput clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PointerInput copyWith(void Function(PointerInput) updates) =>
      super.copyWith((message) => updates(message as PointerInput))
          as PointerInput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PointerInput() / PointerInput.new instead')
  static PointerInput create() => PointerInput._();
  static $pb.GeneratedMessage $_createMessage() => PointerInput._();
  @$core.override
  PointerInput createEmptyInstance() => PointerInput._();
  @$core.pragma('dart2js:noInline')
  static PointerInput getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PointerInput>(
          PointerInput.$_createMessage);
  static PointerInput? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get deltaX => $_getIZ(0);
  @$pb.TagNumber(1)
  set deltaX($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDeltaX() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeltaX() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get deltaY => $_getIZ(1);
  @$pb.TagNumber(2)
  set deltaY($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDeltaY() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeltaY() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get wheelDelta => $_getIZ(2);
  @$pb.TagNumber(3)
  set wheelDelta($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWheelDelta() => $_has(2);
  @$pb.TagNumber(3)
  void clearWheelDelta() => $_clearField(3);

  @$pb.TagNumber(4)
  PointerButton get button => $_getN(3);
  @$pb.TagNumber(4)
  set button(PointerButton value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasButton() => $_has(3);
  @$pb.TagNumber(4)
  void clearButton() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get buttonDown => $_getBF(4);
  @$pb.TagNumber(5)
  set buttonDown($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasButtonDown() => $_has(4);
  @$pb.TagNumber(5)
  void clearButtonDown() => $_clearField(5);

  @$pb.TagNumber(7)
  $core.int get horizontalWheelDelta => $_getIZ(5);
  @$pb.TagNumber(7)
  set horizontalWheelDelta($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(7)
  $core.bool hasHorizontalWheelDelta() => $_has(5);
  @$pb.TagNumber(7)
  void clearHorizontalWheelDelta() => $_clearField(7);
}

class Ping extends $pb.GeneratedMessage {
  factory Ping({
    $fixnum.Int64? sentAtUnixMs,
  }) {
    final result = Ping._();
    if (sentAtUnixMs != null) result.sentAtUnixMs = sentAtUnixMs;
    return result;
  }

  Ping._();

  factory Ping.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Ping()..mergeFromBuffer(data, registry);
  factory Ping.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Ping()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Ping',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'netkeyboard.v1'),
      createEmptyInstance: Ping.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'sentAtUnixMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Ping clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Ping copyWith(void Function(Ping) updates) =>
      super.copyWith((message) => updates(message as Ping)) as Ping;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Ping() / Ping.new instead')
  static Ping create() => Ping._();
  static $pb.GeneratedMessage $_createMessage() => Ping._();
  @$core.override
  Ping createEmptyInstance() => Ping._();
  @$core.pragma('dart2js:noInline')
  static Ping getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Ping>(Ping.$_createMessage);
  static Ping? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get sentAtUnixMs => $_getI64(0);
  @$pb.TagNumber(1)
  set sentAtUnixMs($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSentAtUnixMs() => $_has(0);
  @$pb.TagNumber(1)
  void clearSentAtUnixMs() => $_clearField(1);
}

class Pong extends $pb.GeneratedMessage {
  factory Pong({
    $fixnum.Int64? clientSentAtUnixMs,
    $fixnum.Int64? serverSentAtUnixMs,
  }) {
    final result = Pong._();
    if (clientSentAtUnixMs != null)
      result.clientSentAtUnixMs = clientSentAtUnixMs;
    if (serverSentAtUnixMs != null)
      result.serverSentAtUnixMs = serverSentAtUnixMs;
    return result;
  }

  Pong._();

  factory Pong.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Pong()..mergeFromBuffer(data, registry);
  factory Pong.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Pong()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Pong',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'netkeyboard.v1'),
      createEmptyInstance: Pong.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'clientSentAtUnixMs')
    ..aInt64(2, _omitFieldNames ? '' : 'serverSentAtUnixMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Pong clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Pong copyWith(void Function(Pong) updates) =>
      super.copyWith((message) => updates(message as Pong)) as Pong;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Pong() / Pong.new instead')
  static Pong create() => Pong._();
  static $pb.GeneratedMessage $_createMessage() => Pong._();
  @$core.override
  Pong createEmptyInstance() => Pong._();
  @$core.pragma('dart2js:noInline')
  static Pong getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Pong>(Pong.$_createMessage);
  static Pong? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get clientSentAtUnixMs => $_getI64(0);
  @$pb.TagNumber(1)
  set clientSentAtUnixMs($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasClientSentAtUnixMs() => $_has(0);
  @$pb.TagNumber(1)
  void clearClientSentAtUnixMs() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get serverSentAtUnixMs => $_getI64(1);
  @$pb.TagNumber(2)
  set serverSentAtUnixMs($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasServerSentAtUnixMs() => $_has(1);
  @$pb.TagNumber(2)
  void clearServerSentAtUnixMs() => $_clearField(2);
}

class SessionClosing extends $pb.GeneratedMessage {
  factory SessionClosing({
    ErrorCode? reason,
    $core.String? message,
  }) {
    final result = SessionClosing._();
    if (reason != null) result.reason = reason;
    if (message != null) result.message = message;
    return result;
  }

  SessionClosing._();

  factory SessionClosing.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SessionClosing()..mergeFromBuffer(data, registry);
  factory SessionClosing.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SessionClosing()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SessionClosing',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'netkeyboard.v1'),
      createEmptyInstance: SessionClosing.$_createMessage)
    ..aE<ErrorCode>(1, _omitFieldNames ? '' : 'reason',
        enumValues: ErrorCode.values)
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionClosing clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionClosing copyWith(void Function(SessionClosing) updates) =>
      super.copyWith((message) => updates(message as SessionClosing))
          as SessionClosing;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SessionClosing() / SessionClosing.new instead')
  static SessionClosing create() => SessionClosing._();
  static $pb.GeneratedMessage $_createMessage() => SessionClosing._();
  @$core.override
  SessionClosing createEmptyInstance() => SessionClosing._();
  @$core.pragma('dart2js:noInline')
  static SessionClosing getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SessionClosing>(
          SessionClosing.$_createMessage);
  static SessionClosing? _defaultInstance;

  @$pb.TagNumber(1)
  ErrorCode get reason => $_getN(0);
  @$pb.TagNumber(1)
  set reason(ErrorCode value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasReason() => $_has(0);
  @$pb.TagNumber(1)
  void clearReason() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);
}

class CommandResult extends $pb.GeneratedMessage {
  factory CommandResult({
    $core.String? eventId,
    $core.bool? success,
    ErrorCode? errorCode,
    $core.String? message,
    $core.int? injectedEventCount,
  }) {
    final result = CommandResult._();
    if (eventId != null) result.eventId = eventId;
    if (success != null) result.success = success;
    if (errorCode != null) result.errorCode = errorCode;
    if (message != null) result.message = message;
    if (injectedEventCount != null)
      result.injectedEventCount = injectedEventCount;
    return result;
  }

  CommandResult._();

  factory CommandResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommandResult()..mergeFromBuffer(data, registry);
  factory CommandResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommandResult()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommandResult',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'netkeyboard.v1'),
      createEmptyInstance: CommandResult.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'eventId')
    ..aOB(2, _omitFieldNames ? '' : 'success')
    ..aE<ErrorCode>(3, _omitFieldNames ? '' : 'errorCode',
        enumValues: ErrorCode.values)
    ..aOS(4, _omitFieldNames ? '' : 'message')
    ..aI(5, _omitFieldNames ? '' : 'injectedEventCount',
        fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandResult copyWith(void Function(CommandResult) updates) =>
      super.copyWith((message) => updates(message as CommandResult))
          as CommandResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CommandResult() / CommandResult.new instead')
  static CommandResult create() => CommandResult._();
  static $pb.GeneratedMessage $_createMessage() => CommandResult._();
  @$core.override
  CommandResult createEmptyInstance() => CommandResult._();
  @$core.pragma('dart2js:noInline')
  static CommandResult getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CommandResult>(
          CommandResult.$_createMessage);
  static CommandResult? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get eventId => $_getSZ(0);
  @$pb.TagNumber(1)
  set eventId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEventId() => $_has(0);
  @$pb.TagNumber(1)
  void clearEventId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get success => $_getBF(1);
  @$pb.TagNumber(2)
  set success($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSuccess() => $_has(1);
  @$pb.TagNumber(2)
  void clearSuccess() => $_clearField(2);

  @$pb.TagNumber(3)
  ErrorCode get errorCode => $_getN(2);
  @$pb.TagNumber(3)
  set errorCode(ErrorCode value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasErrorCode() => $_has(2);
  @$pb.TagNumber(3)
  void clearErrorCode() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get message => $_getSZ(3);
  @$pb.TagNumber(4)
  set message($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMessage() => $_has(3);
  @$pb.TagNumber(4)
  void clearMessage() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get injectedEventCount => $_getIZ(4);
  @$pb.TagNumber(5)
  set injectedEventCount($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasInjectedEventCount() => $_has(4);
  @$pb.TagNumber(5)
  void clearInjectedEventCount() => $_clearField(5);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
