// This is a generated file - do not edit.
//
// Generated from remote_input.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use pointerButtonDescriptor instead')
const PointerButton$json = {
  '1': 'PointerButton',
  '2': [
    {'1': 'POINTER_BUTTON_NONE', '2': 0},
    {'1': 'POINTER_BUTTON_LEFT', '2': 1},
    {'1': 'POINTER_BUTTON_RIGHT', '2': 2},
    {'1': 'POINTER_BUTTON_MIDDLE', '2': 3},
  ],
};

/// Descriptor for `PointerButton`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List pointerButtonDescriptor = $convert.base64Decode(
    'Cg1Qb2ludGVyQnV0dG9uEhcKE1BPSU5URVJfQlVUVE9OX05PTkUQABIXChNQT0lOVEVSX0JVVF'
    'RPTl9MRUZUEAESGAoUUE9JTlRFUl9CVVRUT05fUklHSFQQAhIZChVQT0lOVEVSX0JVVFRPTl9N'
    'SURETEUQAw==');

@$core.Deprecated('Use systemGestureDescriptor instead')
const SystemGesture$json = {
  '1': 'SystemGesture',
  '2': [
    {'1': 'SYSTEM_GESTURE_NONE', '2': 0},
    {'1': 'SYSTEM_GESTURE_ZOOM_IN', '2': 1},
    {'1': 'SYSTEM_GESTURE_ZOOM_OUT', '2': 2},
    {'1': 'SYSTEM_GESTURE_TASK_VIEW', '2': 3},
    {'1': 'SYSTEM_GESTURE_SHOW_DESKTOP', '2': 4},
    {'1': 'SYSTEM_GESTURE_SWITCH_APP_NEXT', '2': 5},
    {'1': 'SYSTEM_GESTURE_SWITCH_APP_PREVIOUS', '2': 6},
  ],
};

/// Descriptor for `SystemGesture`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List systemGestureDescriptor = $convert.base64Decode(
    'Cg1TeXN0ZW1HZXN0dXJlEhcKE1NZU1RFTV9HRVNUVVJFX05PTkUQABIaChZTWVNURU1fR0VTVF'
    'VSRV9aT09NX0lOEAESGwoXU1lTVEVNX0dFU1RVUkVfWk9PTV9PVVQQAhIcChhTWVNURU1fR0VT'
    'VFVSRV9UQVNLX1ZJRVcQAxIfChtTWVNURU1fR0VTVFVSRV9TSE9XX0RFU0tUT1AQBBIiCh5TWV'
    'NURU1fR0VTVFVSRV9TV0lUQ0hfQVBQX05FWFQQBRImCiJTWVNURU1fR0VTVFVSRV9TV0lUQ0hf'
    'QVBQX1BSRVZJT1VTEAY=');

@$core.Deprecated('Use capabilityDescriptor instead')
const Capability$json = {
  '1': 'Capability',
  '2': [
    {'1': 'CAPABILITY_UNSPECIFIED', '2': 0},
    {'1': 'CAPABILITY_KEY_STROKE', '2': 1},
    {'1': 'CAPABILITY_UNICODE_TEXT', '2': 2},
    {'1': 'CAPABILITY_POINTER', '2': 3},
  ],
};

/// Descriptor for `Capability`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List capabilityDescriptor = $convert.base64Decode(
    'CgpDYXBhYmlsaXR5EhoKFkNBUEFCSUxJVFlfVU5TUEVDSUZJRUQQABIZChVDQVBBQklMSVRZX0'
    'tFWV9TVFJPS0UQARIbChdDQVBBQklMSVRZX1VOSUNPREVfVEVYVBACEhYKEkNBUEFCSUxJVFlf'
    'UE9JTlRFUhAD');

@$core.Deprecated('Use errorCodeDescriptor instead')
const ErrorCode$json = {
  '1': 'ErrorCode',
  '2': [
    {'1': 'ERROR_CODE_UNSPECIFIED', '2': 0},
    {'1': 'ERROR_CODE_OK', '2': 1},
    {'1': 'ERROR_CODE_UNAUTHENTICATED', '2': 2},
    {'1': 'ERROR_CODE_PAIRING_DISABLED', '2': 3},
    {'1': 'ERROR_CODE_PAIRING_EXPIRED', '2': 4},
    {'1': 'ERROR_CODE_INVALID_TOTP', '2': 5},
    {'1': 'ERROR_CODE_RATE_LIMITED', '2': 6},
    {'1': 'ERROR_CODE_CERTIFICATE_CHANGED', '2': 7},
    {'1': 'ERROR_CODE_INCOMPATIBLE_PROTOCOL', '2': 8},
    {'1': 'ERROR_CODE_CONTROLLER_BUSY', '2': 9},
    {'1': 'ERROR_CODE_INVALID_SEQUENCE', '2': 10},
    {'1': 'ERROR_CODE_DUPLICATE_EVENT', '2': 11},
    {'1': 'ERROR_CODE_UNSUPPORTED_KEY', '2': 12},
    {'1': 'ERROR_CODE_INVALID_TEXT', '2': 13},
    {'1': 'ERROR_CODE_NO_FOREGROUND_TARGET', '2': 14},
    {'1': 'ERROR_CODE_INPUT_BLOCKED', '2': 15},
    {'1': 'ERROR_CODE_INPUT_PARTIAL', '2': 16},
    {'1': 'ERROR_CODE_INTERNAL', '2': 17},
  ],
};

/// Descriptor for `ErrorCode`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List errorCodeDescriptor = $convert.base64Decode(
    'CglFcnJvckNvZGUSGgoWRVJST1JfQ09ERV9VTlNQRUNJRklFRBAAEhEKDUVSUk9SX0NPREVfT0'
    'sQARIeChpFUlJPUl9DT0RFX1VOQVVUSEVOVElDQVRFRBACEh8KG0VSUk9SX0NPREVfUEFJUklO'
    'R19ESVNBQkxFRBADEh4KGkVSUk9SX0NPREVfUEFJUklOR19FWFBJUkVEEAQSGwoXRVJST1JfQ0'
    '9ERV9JTlZBTElEX1RPVFAQBRIbChdFUlJPUl9DT0RFX1JBVEVfTElNSVRFRBAGEiIKHkVSUk9S'
    'X0NPREVfQ0VSVElGSUNBVEVfQ0hBTkdFRBAHEiQKIEVSUk9SX0NPREVfSU5DT01QQVRJQkxFX1'
    'BST1RPQ09MEAgSHgoaRVJST1JfQ09ERV9DT05UUk9MTEVSX0JVU1kQCRIfChtFUlJPUl9DT0RF'
    'X0lOVkFMSURfU0VRVUVOQ0UQChIeChpFUlJPUl9DT0RFX0RVUExJQ0FURV9FVkVOVBALEh4KGk'
    'VSUk9SX0NPREVfVU5TVVBQT1JURURfS0VZEAwSGwoXRVJST1JfQ09ERV9JTlZBTElEX1RFWFQQ'
    'DRIjCh9FUlJPUl9DT0RFX05PX0ZPUkVHUk9VTkRfVEFSR0VUEA4SHAoYRVJST1JfQ09ERV9JTl'
    'BVVF9CTE9DS0VEEA8SHAoYRVJST1JfQ09ERV9JTlBVVF9QQVJUSUFMEBASFwoTRVJST1JfQ09E'
    'RV9JTlRFUk5BTBAR');

@$core.Deprecated('Use semanticKeyDescriptor instead')
const SemanticKey$json = {
  '1': 'SemanticKey',
  '2': [
    {'1': 'SEMANTIC_KEY_UNSPECIFIED', '2': 0},
    {'1': 'SEMANTIC_KEY_ESCAPE', '2': 1},
    {'1': 'SEMANTIC_KEY_F1', '2': 2},
    {'1': 'SEMANTIC_KEY_F2', '2': 3},
    {'1': 'SEMANTIC_KEY_F3', '2': 4},
    {'1': 'SEMANTIC_KEY_F4', '2': 5},
    {'1': 'SEMANTIC_KEY_F5', '2': 6},
    {'1': 'SEMANTIC_KEY_F6', '2': 7},
    {'1': 'SEMANTIC_KEY_F7', '2': 8},
    {'1': 'SEMANTIC_KEY_F8', '2': 9},
    {'1': 'SEMANTIC_KEY_F9', '2': 10},
    {'1': 'SEMANTIC_KEY_F10', '2': 11},
    {'1': 'SEMANTIC_KEY_F11', '2': 12},
    {'1': 'SEMANTIC_KEY_F12', '2': 13},
    {'1': 'SEMANTIC_KEY_PRINT_SCREEN', '2': 14},
    {'1': 'SEMANTIC_KEY_DELETE', '2': 15},
    {'1': 'SEMANTIC_KEY_HOME', '2': 16},
    {'1': 'SEMANTIC_KEY_BACKQUOTE', '2': 17},
    {'1': 'SEMANTIC_KEY_DIGIT_1', '2': 18},
    {'1': 'SEMANTIC_KEY_DIGIT_2', '2': 19},
    {'1': 'SEMANTIC_KEY_DIGIT_3', '2': 20},
    {'1': 'SEMANTIC_KEY_DIGIT_4', '2': 21},
    {'1': 'SEMANTIC_KEY_DIGIT_5', '2': 22},
    {'1': 'SEMANTIC_KEY_DIGIT_6', '2': 23},
    {'1': 'SEMANTIC_KEY_DIGIT_7', '2': 24},
    {'1': 'SEMANTIC_KEY_DIGIT_8', '2': 25},
    {'1': 'SEMANTIC_KEY_DIGIT_9', '2': 26},
    {'1': 'SEMANTIC_KEY_DIGIT_0', '2': 27},
    {'1': 'SEMANTIC_KEY_MINUS', '2': 28},
    {'1': 'SEMANTIC_KEY_EQUAL', '2': 29},
    {'1': 'SEMANTIC_KEY_BACKSPACE', '2': 30},
    {'1': 'SEMANTIC_KEY_PAGE_UP', '2': 31},
    {'1': 'SEMANTIC_KEY_TAB', '2': 32},
    {'1': 'SEMANTIC_KEY_KEY_Q', '2': 33},
    {'1': 'SEMANTIC_KEY_KEY_W', '2': 34},
    {'1': 'SEMANTIC_KEY_KEY_E', '2': 35},
    {'1': 'SEMANTIC_KEY_KEY_R', '2': 36},
    {'1': 'SEMANTIC_KEY_KEY_T', '2': 37},
    {'1': 'SEMANTIC_KEY_KEY_Y', '2': 38},
    {'1': 'SEMANTIC_KEY_KEY_U', '2': 39},
    {'1': 'SEMANTIC_KEY_KEY_I', '2': 40},
    {'1': 'SEMANTIC_KEY_KEY_O', '2': 41},
    {'1': 'SEMANTIC_KEY_KEY_P', '2': 42},
    {'1': 'SEMANTIC_KEY_BRACKET_LEFT', '2': 43},
    {'1': 'SEMANTIC_KEY_BRACKET_RIGHT', '2': 44},
    {'1': 'SEMANTIC_KEY_BACKSLASH', '2': 45},
    {'1': 'SEMANTIC_KEY_PAGE_DOWN', '2': 46},
    {'1': 'SEMANTIC_KEY_CAPS_LOCK', '2': 47},
    {'1': 'SEMANTIC_KEY_KEY_A', '2': 48},
    {'1': 'SEMANTIC_KEY_KEY_S', '2': 49},
    {'1': 'SEMANTIC_KEY_KEY_D', '2': 50},
    {'1': 'SEMANTIC_KEY_KEY_F', '2': 51},
    {'1': 'SEMANTIC_KEY_KEY_G', '2': 52},
    {'1': 'SEMANTIC_KEY_KEY_H', '2': 53},
    {'1': 'SEMANTIC_KEY_KEY_J', '2': 54},
    {'1': 'SEMANTIC_KEY_KEY_K', '2': 55},
    {'1': 'SEMANTIC_KEY_KEY_L', '2': 56},
    {'1': 'SEMANTIC_KEY_SEMICOLON', '2': 57},
    {'1': 'SEMANTIC_KEY_QUOTE', '2': 58},
    {'1': 'SEMANTIC_KEY_ENTER', '2': 59},
    {'1': 'SEMANTIC_KEY_KEY_Z', '2': 60},
    {'1': 'SEMANTIC_KEY_KEY_X', '2': 61},
    {'1': 'SEMANTIC_KEY_KEY_C', '2': 62},
    {'1': 'SEMANTIC_KEY_KEY_V', '2': 63},
    {'1': 'SEMANTIC_KEY_KEY_B', '2': 64},
    {'1': 'SEMANTIC_KEY_KEY_N', '2': 65},
    {'1': 'SEMANTIC_KEY_KEY_M', '2': 66},
    {'1': 'SEMANTIC_KEY_COMMA', '2': 67},
    {'1': 'SEMANTIC_KEY_PERIOD', '2': 68},
    {'1': 'SEMANTIC_KEY_SLASH', '2': 69},
    {'1': 'SEMANTIC_KEY_ARROW_UP', '2': 70},
    {'1': 'SEMANTIC_KEY_END', '2': 71},
    {'1': 'SEMANTIC_KEY_SPACE', '2': 72},
    {'1': 'SEMANTIC_KEY_MENU', '2': 73},
    {'1': 'SEMANTIC_KEY_ARROW_LEFT', '2': 74},
    {'1': 'SEMANTIC_KEY_ARROW_DOWN', '2': 75},
    {'1': 'SEMANTIC_KEY_ARROW_RIGHT', '2': 76},
  ],
};

/// Descriptor for `SemanticKey`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List semanticKeyDescriptor = $convert.base64Decode(
    'CgtTZW1hbnRpY0tleRIcChhTRU1BTlRJQ19LRVlfVU5TUEVDSUZJRUQQABIXChNTRU1BTlRJQ1'
    '9LRVlfRVNDQVBFEAESEwoPU0VNQU5USUNfS0VZX0YxEAISEwoPU0VNQU5USUNfS0VZX0YyEAMS'
    'EwoPU0VNQU5USUNfS0VZX0YzEAQSEwoPU0VNQU5USUNfS0VZX0Y0EAUSEwoPU0VNQU5USUNfS0'
    'VZX0Y1EAYSEwoPU0VNQU5USUNfS0VZX0Y2EAcSEwoPU0VNQU5USUNfS0VZX0Y3EAgSEwoPU0VN'
    'QU5USUNfS0VZX0Y4EAkSEwoPU0VNQU5USUNfS0VZX0Y5EAoSFAoQU0VNQU5USUNfS0VZX0YxMB'
    'ALEhQKEFNFTUFOVElDX0tFWV9GMTEQDBIUChBTRU1BTlRJQ19LRVlfRjEyEA0SHQoZU0VNQU5U'
    'SUNfS0VZX1BSSU5UX1NDUkVFThAOEhcKE1NFTUFOVElDX0tFWV9ERUxFVEUQDxIVChFTRU1BTl'
    'RJQ19LRVlfSE9NRRAQEhoKFlNFTUFOVElDX0tFWV9CQUNLUVVPVEUQERIYChRTRU1BTlRJQ19L'
    'RVlfRElHSVRfMRASEhgKFFNFTUFOVElDX0tFWV9ESUdJVF8yEBMSGAoUU0VNQU5USUNfS0VZX0'
    'RJR0lUXzMQFBIYChRTRU1BTlRJQ19LRVlfRElHSVRfNBAVEhgKFFNFTUFOVElDX0tFWV9ESUdJ'
    'VF81EBYSGAoUU0VNQU5USUNfS0VZX0RJR0lUXzYQFxIYChRTRU1BTlRJQ19LRVlfRElHSVRfNx'
    'AYEhgKFFNFTUFOVElDX0tFWV9ESUdJVF84EBkSGAoUU0VNQU5USUNfS0VZX0RJR0lUXzkQGhIY'
    'ChRTRU1BTlRJQ19LRVlfRElHSVRfMBAbEhYKElNFTUFOVElDX0tFWV9NSU5VUxAcEhYKElNFTU'
    'FOVElDX0tFWV9FUVVBTBAdEhoKFlNFTUFOVElDX0tFWV9CQUNLU1BBQ0UQHhIYChRTRU1BTlRJ'
    'Q19LRVlfUEFHRV9VUBAfEhQKEFNFTUFOVElDX0tFWV9UQUIQIBIWChJTRU1BTlRJQ19LRVlfS0'
    'VZX1EQIRIWChJTRU1BTlRJQ19LRVlfS0VZX1cQIhIWChJTRU1BTlRJQ19LRVlfS0VZX0UQIxIW'
    'ChJTRU1BTlRJQ19LRVlfS0VZX1IQJBIWChJTRU1BTlRJQ19LRVlfS0VZX1QQJRIWChJTRU1BTl'
    'RJQ19LRVlfS0VZX1kQJhIWChJTRU1BTlRJQ19LRVlfS0VZX1UQJxIWChJTRU1BTlRJQ19LRVlf'
    'S0VZX0kQKBIWChJTRU1BTlRJQ19LRVlfS0VZX08QKRIWChJTRU1BTlRJQ19LRVlfS0VZX1AQKh'
    'IdChlTRU1BTlRJQ19LRVlfQlJBQ0tFVF9MRUZUECsSHgoaU0VNQU5USUNfS0VZX0JSQUNLRVRf'
    'UklHSFQQLBIaChZTRU1BTlRJQ19LRVlfQkFDS1NMQVNIEC0SGgoWU0VNQU5USUNfS0VZX1BBR0'
    'VfRE9XThAuEhoKFlNFTUFOVElDX0tFWV9DQVBTX0xPQ0sQLxIWChJTRU1BTlRJQ19LRVlfS0VZ'
    'X0EQMBIWChJTRU1BTlRJQ19LRVlfS0VZX1MQMRIWChJTRU1BTlRJQ19LRVlfS0VZX0QQMhIWCh'
    'JTRU1BTlRJQ19LRVlfS0VZX0YQMxIWChJTRU1BTlRJQ19LRVlfS0VZX0cQNBIWChJTRU1BTlRJ'
    'Q19LRVlfS0VZX0gQNRIWChJTRU1BTlRJQ19LRVlfS0VZX0oQNhIWChJTRU1BTlRJQ19LRVlfS0'
    'VZX0sQNxIWChJTRU1BTlRJQ19LRVlfS0VZX0wQOBIaChZTRU1BTlRJQ19LRVlfU0VNSUNPTE9O'
    'EDkSFgoSU0VNQU5USUNfS0VZX1FVT1RFEDoSFgoSU0VNQU5USUNfS0VZX0VOVEVSEDsSFgoSU0'
    'VNQU5USUNfS0VZX0tFWV9aEDwSFgoSU0VNQU5USUNfS0VZX0tFWV9YED0SFgoSU0VNQU5USUNf'
    'S0VZX0tFWV9DED4SFgoSU0VNQU5USUNfS0VZX0tFWV9WED8SFgoSU0VNQU5USUNfS0VZX0tFWV'
    '9CEEASFgoSU0VNQU5USUNfS0VZX0tFWV9OEEESFgoSU0VNQU5USUNfS0VZX0tFWV9NEEISFgoS'
    'U0VNQU5USUNfS0VZX0NPTU1BEEMSFwoTU0VNQU5USUNfS0VZX1BFUklPRBBEEhYKElNFTUFOVE'
    'lDX0tFWV9TTEFTSBBFEhkKFVNFTUFOVElDX0tFWV9BUlJPV19VUBBGEhQKEFNFTUFOVElDX0tF'
    'WV9FTkQQRxIWChJTRU1BTlRJQ19LRVlfU1BBQ0UQSBIVChFTRU1BTlRJQ19LRVlfTUVOVRBJEh'
    'sKF1NFTUFOVElDX0tFWV9BUlJPV19MRUZUEEoSGwoXU0VNQU5USUNfS0VZX0FSUk9XX0RPV04Q'
    'SxIcChhTRU1BTlRJQ19LRVlfQVJST1dfUklHSFQQTA==');

@$core.Deprecated('Use protocolVersionDescriptor instead')
const ProtocolVersion$json = {
  '1': 'ProtocolVersion',
  '2': [
    {'1': 'major', '3': 1, '4': 1, '5': 13, '10': 'major'},
    {'1': 'minor', '3': 2, '4': 1, '5': 13, '10': 'minor'},
  ],
};

/// Descriptor for `ProtocolVersion`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List protocolVersionDescriptor = $convert.base64Decode(
    'Cg9Qcm90b2NvbFZlcnNpb24SFAoFbWFqb3IYASABKA1SBW1ham9yEhQKBW1pbm9yGAIgASgNUg'
    'VtaW5vcg==');

@$core.Deprecated('Use serverInfoRequestDescriptor instead')
const ServerInfoRequest$json = {
  '1': 'ServerInfoRequest',
};

/// Descriptor for `ServerInfoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List serverInfoRequestDescriptor =
    $convert.base64Decode('ChFTZXJ2ZXJJbmZvUmVxdWVzdA==');

@$core.Deprecated('Use serverInfoResponseDescriptor instead')
const ServerInfoResponse$json = {
  '1': 'ServerInfoResponse',
  '2': [
    {'1': 'server_id', '3': 1, '4': 1, '5': 9, '10': 'serverId'},
    {'1': 'display_name', '3': 2, '4': 1, '5': 9, '10': 'displayName'},
    {
      '1': 'protocol_version',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.netkeyboard.v1.ProtocolVersion',
      '10': 'protocolVersion'
    },
    {
      '1': 'certificate_sha256',
      '3': 4,
      '4': 1,
      '5': 9,
      '10': 'certificateSha256'
    },
    {
      '1': 'capabilities',
      '3': 5,
      '4': 3,
      '5': 14,
      '6': '.netkeyboard.v1.Capability',
      '10': 'capabilities'
    },
    {'1': 'pairing_enabled', '3': 6, '4': 1, '5': 8, '10': 'pairingEnabled'},
  ],
};

/// Descriptor for `ServerInfoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List serverInfoResponseDescriptor = $convert.base64Decode(
    'ChJTZXJ2ZXJJbmZvUmVzcG9uc2USGwoJc2VydmVyX2lkGAEgASgJUghzZXJ2ZXJJZBIhCgxkaX'
    'NwbGF5X25hbWUYAiABKAlSC2Rpc3BsYXlOYW1lEkoKEHByb3RvY29sX3ZlcnNpb24YAyABKAsy'
    'Hy5uZXRrZXlib2FyZC52MS5Qcm90b2NvbFZlcnNpb25SD3Byb3RvY29sVmVyc2lvbhItChJjZX'
    'J0aWZpY2F0ZV9zaGEyNTYYBCABKAlSEWNlcnRpZmljYXRlU2hhMjU2Ej4KDGNhcGFiaWxpdGll'
    'cxgFIAMoDjIaLm5ldGtleWJvYXJkLnYxLkNhcGFiaWxpdHlSDGNhcGFiaWxpdGllcxInCg9wYW'
    'lyaW5nX2VuYWJsZWQYBiABKAhSDnBhaXJpbmdFbmFibGVk');

@$core.Deprecated('Use pairingChallengeRequestDescriptor instead')
const PairingChallengeRequest$json = {
  '1': 'PairingChallengeRequest',
  '2': [
    {
      '1': 'client_instance_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '10': 'clientInstanceId'
    },
  ],
};

/// Descriptor for `PairingChallengeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pairingChallengeRequestDescriptor =
    $convert.base64Decode(
        'ChdQYWlyaW5nQ2hhbGxlbmdlUmVxdWVzdBIsChJjbGllbnRfaW5zdGFuY2VfaWQYASABKAlSEG'
        'NsaWVudEluc3RhbmNlSWQ=');

@$core.Deprecated('Use pairingChallengeResponseDescriptor instead')
const PairingChallengeResponse$json = {
  '1': 'PairingChallengeResponse',
  '2': [
    {'1': 'challenge_id', '3': 1, '4': 1, '5': 9, '10': 'challengeId'},
    {'1': 'server_nonce', '3': 2, '4': 1, '5': 12, '10': 'serverNonce'},
    {
      '1': 'expires_at_unix_ms',
      '3': 3,
      '4': 1,
      '5': 3,
      '10': 'expiresAtUnixMs'
    },
  ],
};

/// Descriptor for `PairingChallengeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pairingChallengeResponseDescriptor = $convert.base64Decode(
    'ChhQYWlyaW5nQ2hhbGxlbmdlUmVzcG9uc2USIQoMY2hhbGxlbmdlX2lkGAEgASgJUgtjaGFsbG'
    'VuZ2VJZBIhCgxzZXJ2ZXJfbm9uY2UYAiABKAxSC3NlcnZlck5vbmNlEisKEmV4cGlyZXNfYXRf'
    'dW5peF9tcxgDIAEoA1IPZXhwaXJlc0F0VW5peE1z');

@$core.Deprecated('Use pairRequestDescriptor instead')
const PairRequest$json = {
  '1': 'PairRequest',
  '2': [
    {'1': 'challenge_id', '3': 1, '4': 1, '5': 9, '10': 'challengeId'},
    {
      '1': 'client_instance_id',
      '3': 2,
      '4': 1,
      '5': 9,
      '10': 'clientInstanceId'
    },
    {'1': 'client_name', '3': 3, '4': 1, '5': 9, '10': 'clientName'},
    {'1': 'totp_code', '3': 4, '4': 1, '5': 9, '10': 'totpCode'},
    {'1': 'client_nonce', '3': 5, '4': 1, '5': 12, '10': 'clientNonce'},
    {
      '1': 'protocol_version',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.netkeyboard.v1.ProtocolVersion',
      '10': 'protocolVersion'
    },
  ],
};

/// Descriptor for `PairRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pairRequestDescriptor = $convert.base64Decode(
    'CgtQYWlyUmVxdWVzdBIhCgxjaGFsbGVuZ2VfaWQYASABKAlSC2NoYWxsZW5nZUlkEiwKEmNsaW'
    'VudF9pbnN0YW5jZV9pZBgCIAEoCVIQY2xpZW50SW5zdGFuY2VJZBIfCgtjbGllbnRfbmFtZRgD'
    'IAEoCVIKY2xpZW50TmFtZRIbCgl0b3RwX2NvZGUYBCABKAlSCHRvdHBDb2RlEiEKDGNsaWVudF'
    '9ub25jZRgFIAEoDFILY2xpZW50Tm9uY2USSgoQcHJvdG9jb2xfdmVyc2lvbhgGIAEoCzIfLm5l'
    'dGtleWJvYXJkLnYxLlByb3RvY29sVmVyc2lvblIPcHJvdG9jb2xWZXJzaW9u');

@$core.Deprecated('Use pairResponseDescriptor instead')
const PairResponse$json = {
  '1': 'PairResponse',
  '2': [
    {'1': 'paired_device_id', '3': 1, '4': 1, '5': 9, '10': 'pairedDeviceId'},
    {'1': 'bearer_token', '3': 2, '4': 1, '5': 12, '10': 'bearerToken'},
    {'1': 'server_id', '3': 3, '4': 1, '5': 9, '10': 'serverId'},
    {
      '1': 'protocol_version',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.netkeyboard.v1.ProtocolVersion',
      '10': 'protocolVersion'
    },
    {
      '1': 'capabilities',
      '3': 5,
      '4': 3,
      '5': 14,
      '6': '.netkeyboard.v1.Capability',
      '10': 'capabilities'
    },
    {
      '1': 'token_created_at_unix_ms',
      '3': 6,
      '4': 1,
      '5': 3,
      '10': 'tokenCreatedAtUnixMs'
    },
  ],
};

/// Descriptor for `PairResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pairResponseDescriptor = $convert.base64Decode(
    'CgxQYWlyUmVzcG9uc2USKAoQcGFpcmVkX2RldmljZV9pZBgBIAEoCVIOcGFpcmVkRGV2aWNlSW'
    'QSIQoMYmVhcmVyX3Rva2VuGAIgASgMUgtiZWFyZXJUb2tlbhIbCglzZXJ2ZXJfaWQYAyABKAlS'
    'CHNlcnZlcklkEkoKEHByb3RvY29sX3ZlcnNpb24YBCABKAsyHy5uZXRrZXlib2FyZC52MS5Qcm'
    '90b2NvbFZlcnNpb25SD3Byb3RvY29sVmVyc2lvbhI+CgxjYXBhYmlsaXRpZXMYBSADKA4yGi5u'
    'ZXRrZXlib2FyZC52MS5DYXBhYmlsaXR5UgxjYXBhYmlsaXRpZXMSNgoYdG9rZW5fY3JlYXRlZF'
    '9hdF91bml4X21zGAYgASgDUhR0b2tlbkNyZWF0ZWRBdFVuaXhNcw==');

@$core.Deprecated('Use clientEnvelopeDescriptor instead')
const ClientEnvelope$json = {
  '1': 'ClientEnvelope',
  '2': [
    {'1': 'sequence', '3': 1, '4': 1, '5': 4, '10': 'sequence'},
    {'1': 'event_id', '3': 2, '4': 1, '5': 9, '10': 'eventId'},
    {
      '1': 'hello',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.netkeyboard.v1.ClientHello',
      '9': 0,
      '10': 'hello'
    },
    {
      '1': 'key_stroke',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.netkeyboard.v1.KeyStroke',
      '9': 0,
      '10': 'keyStroke'
    },
    {
      '1': 'text_input',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.netkeyboard.v1.TextInput',
      '9': 0,
      '10': 'textInput'
    },
    {
      '1': 'ping',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.netkeyboard.v1.Ping',
      '9': 0,
      '10': 'ping'
    },
    {
      '1': 'pointer_input',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.netkeyboard.v1.PointerInput',
      '9': 0,
      '10': 'pointerInput'
    },
  ],
  '8': [
    {'1': 'payload'},
  ],
};

/// Descriptor for `ClientEnvelope`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientEnvelopeDescriptor = $convert.base64Decode(
    'Cg5DbGllbnRFbnZlbG9wZRIaCghzZXF1ZW5jZRgBIAEoBFIIc2VxdWVuY2USGQoIZXZlbnRfaW'
    'QYAiABKAlSB2V2ZW50SWQSMwoFaGVsbG8YCiABKAsyGy5uZXRrZXlib2FyZC52MS5DbGllbnRI'
    'ZWxsb0gAUgVoZWxsbxI6CgprZXlfc3Ryb2tlGAsgASgLMhkubmV0a2V5Ym9hcmQudjEuS2V5U3'
    'Ryb2tlSABSCWtleVN0cm9rZRI6Cgp0ZXh0X2lucHV0GAwgASgLMhkubmV0a2V5Ym9hcmQudjEu'
    'VGV4dElucHV0SABSCXRleHRJbnB1dBIqCgRwaW5nGA0gASgLMhQubmV0a2V5Ym9hcmQudjEuUG'
    'luZ0gAUgRwaW5nEkMKDXBvaW50ZXJfaW5wdXQYDiABKAsyHC5uZXRrZXlib2FyZC52MS5Qb2lu'
    'dGVySW5wdXRIAFIMcG9pbnRlcklucHV0QgkKB3BheWxvYWQ=');

@$core.Deprecated('Use serverEnvelopeDescriptor instead')
const ServerEnvelope$json = {
  '1': 'ServerEnvelope',
  '2': [
    {
      '1': 'acknowledged_sequence',
      '3': 1,
      '4': 1,
      '5': 4,
      '10': 'acknowledgedSequence'
    },
    {
      '1': 'hello',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.netkeyboard.v1.ServerHello',
      '9': 0,
      '10': 'hello'
    },
    {
      '1': 'result',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.netkeyboard.v1.CommandResult',
      '9': 0,
      '10': 'result'
    },
    {
      '1': 'pong',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.netkeyboard.v1.Pong',
      '9': 0,
      '10': 'pong'
    },
    {
      '1': 'closing',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.netkeyboard.v1.SessionClosing',
      '9': 0,
      '10': 'closing'
    },
  ],
  '8': [
    {'1': 'payload'},
  ],
};

/// Descriptor for `ServerEnvelope`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List serverEnvelopeDescriptor = $convert.base64Decode(
    'Cg5TZXJ2ZXJFbnZlbG9wZRIzChVhY2tub3dsZWRnZWRfc2VxdWVuY2UYASABKARSFGFja25vd2'
    'xlZGdlZFNlcXVlbmNlEjMKBWhlbGxvGAogASgLMhsubmV0a2V5Ym9hcmQudjEuU2VydmVySGVs'
    'bG9IAFIFaGVsbG8SNwoGcmVzdWx0GAsgASgLMh0ubmV0a2V5Ym9hcmQudjEuQ29tbWFuZFJlc3'
    'VsdEgAUgZyZXN1bHQSKgoEcG9uZxgMIAEoCzIULm5ldGtleWJvYXJkLnYxLlBvbmdIAFIEcG9u'
    'ZxI6CgdjbG9zaW5nGA0gASgLMh4ubmV0a2V5Ym9hcmQudjEuU2Vzc2lvbkNsb3NpbmdIAFIHY2'
    'xvc2luZ0IJCgdwYXlsb2Fk');

@$core.Deprecated('Use clientHelloDescriptor instead')
const ClientHello$json = {
  '1': 'ClientHello',
  '2': [
    {
      '1': 'client_instance_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '10': 'clientInstanceId'
    },
    {'1': 'client_name', '3': 2, '4': 1, '5': 9, '10': 'clientName'},
    {
      '1': 'protocol_version',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.netkeyboard.v1.ProtocolVersion',
      '10': 'protocolVersion'
    },
    {
      '1': 'capabilities',
      '3': 4,
      '4': 3,
      '5': 14,
      '6': '.netkeyboard.v1.Capability',
      '10': 'capabilities'
    },
  ],
};

/// Descriptor for `ClientHello`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientHelloDescriptor = $convert.base64Decode(
    'CgtDbGllbnRIZWxsbxIsChJjbGllbnRfaW5zdGFuY2VfaWQYASABKAlSEGNsaWVudEluc3Rhbm'
    'NlSWQSHwoLY2xpZW50X25hbWUYAiABKAlSCmNsaWVudE5hbWUSSgoQcHJvdG9jb2xfdmVyc2lv'
    'bhgDIAEoCzIfLm5ldGtleWJvYXJkLnYxLlByb3RvY29sVmVyc2lvblIPcHJvdG9jb2xWZXJzaW'
    '9uEj4KDGNhcGFiaWxpdGllcxgEIAMoDjIaLm5ldGtleWJvYXJkLnYxLkNhcGFiaWxpdHlSDGNh'
    'cGFiaWxpdGllcw==');

@$core.Deprecated('Use serverHelloDescriptor instead')
const ServerHello$json = {
  '1': 'ServerHello',
  '2': [
    {'1': 'server_id', '3': 1, '4': 1, '5': 9, '10': 'serverId'},
    {'1': 'display_name', '3': 2, '4': 1, '5': 9, '10': 'displayName'},
    {
      '1': 'protocol_version',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.netkeyboard.v1.ProtocolVersion',
      '10': 'protocolVersion'
    },
    {
      '1': 'capabilities',
      '3': 4,
      '4': 3,
      '5': 14,
      '6': '.netkeyboard.v1.Capability',
      '10': 'capabilities'
    },
    {
      '1': 'heartbeat_interval_seconds',
      '3': 5,
      '4': 1,
      '5': 13,
      '10': 'heartbeatIntervalSeconds'
    },
  ],
};

/// Descriptor for `ServerHello`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List serverHelloDescriptor = $convert.base64Decode(
    'CgtTZXJ2ZXJIZWxsbxIbCglzZXJ2ZXJfaWQYASABKAlSCHNlcnZlcklkEiEKDGRpc3BsYXlfbm'
    'FtZRgCIAEoCVILZGlzcGxheU5hbWUSSgoQcHJvdG9jb2xfdmVyc2lvbhgDIAEoCzIfLm5ldGtl'
    'eWJvYXJkLnYxLlByb3RvY29sVmVyc2lvblIPcHJvdG9jb2xWZXJzaW9uEj4KDGNhcGFiaWxpdG'
    'llcxgEIAMoDjIaLm5ldGtleWJvYXJkLnYxLkNhcGFiaWxpdHlSDGNhcGFiaWxpdGllcxI8Chpo'
    'ZWFydGJlYXRfaW50ZXJ2YWxfc2Vjb25kcxgFIAEoDVIYaGVhcnRiZWF0SW50ZXJ2YWxTZWNvbm'
    'Rz');

@$core.Deprecated('Use keyStrokeDescriptor instead')
const KeyStroke$json = {
  '1': 'KeyStroke',
  '2': [
    {
      '1': 'key',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.netkeyboard.v1.SemanticKey',
      '10': 'key'
    },
    {'1': 'modifier_bits', '3': 2, '4': 1, '5': 13, '10': 'modifierBits'},
    {'1': 'repeated', '3': 3, '4': 1, '5': 8, '10': 'repeated'},
  ],
};

/// Descriptor for `KeyStroke`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List keyStrokeDescriptor = $convert.base64Decode(
    'CglLZXlTdHJva2USLQoDa2V5GAEgASgOMhsubmV0a2V5Ym9hcmQudjEuU2VtYW50aWNLZXlSA2'
    'tleRIjCg1tb2RpZmllcl9iaXRzGAIgASgNUgxtb2RpZmllckJpdHMSGgoIcmVwZWF0ZWQYAyAB'
    'KAhSCHJlcGVhdGVk');

@$core.Deprecated('Use textInputDescriptor instead')
const TextInput$json = {
  '1': 'TextInput',
  '2': [
    {'1': 'text', '3': 1, '4': 1, '5': 9, '10': 'text'},
  ],
};

/// Descriptor for `TextInput`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List textInputDescriptor =
    $convert.base64Decode('CglUZXh0SW5wdXQSEgoEdGV4dBgBIAEoCVIEdGV4dA==');

@$core.Deprecated('Use pointerInputDescriptor instead')
const PointerInput$json = {
  '1': 'PointerInput',
  '2': [
    {'1': 'delta_x', '3': 1, '4': 1, '5': 17, '10': 'deltaX'},
    {'1': 'delta_y', '3': 2, '4': 1, '5': 17, '10': 'deltaY'},
    {'1': 'wheel_delta', '3': 3, '4': 1, '5': 17, '10': 'wheelDelta'},
    {
      '1': 'button',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.netkeyboard.v1.PointerButton',
      '10': 'button'
    },
    {'1': 'button_down', '3': 5, '4': 1, '5': 8, '10': 'buttonDown'},
    {
      '1': 'gesture',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.netkeyboard.v1.SystemGesture',
      '10': 'gesture'
    },
    {
      '1': 'horizontal_wheel_delta',
      '3': 7,
      '4': 1,
      '5': 17,
      '10': 'horizontalWheelDelta'
    },
  ],
};

/// Descriptor for `PointerInput`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pointerInputDescriptor = $convert.base64Decode(
    'CgxQb2ludGVySW5wdXQSFwoHZGVsdGFfeBgBIAEoEVIGZGVsdGFYEhcKB2RlbHRhX3kYAiABKB'
    'FSBmRlbHRhWRIfCgt3aGVlbF9kZWx0YRgDIAEoEVIKd2hlZWxEZWx0YRI1CgZidXR0b24YBCAB'
    'KA4yHS5uZXRrZXlib2FyZC52MS5Qb2ludGVyQnV0dG9uUgZidXR0b24SHwoLYnV0dG9uX2Rvd2'
    '4YBSABKAhSCmJ1dHRvbkRvd24SNwoHZ2VzdHVyZRgGIAEoDjIdLm5ldGtleWJvYXJkLnYxLlN5'
    'c3RlbUdlc3R1cmVSB2dlc3R1cmUSNAoWaG9yaXpvbnRhbF93aGVlbF9kZWx0YRgHIAEoEVIUaG'
    '9yaXpvbnRhbFdoZWVsRGVsdGE=');

@$core.Deprecated('Use pingDescriptor instead')
const Ping$json = {
  '1': 'Ping',
  '2': [
    {'1': 'sent_at_unix_ms', '3': 1, '4': 1, '5': 3, '10': 'sentAtUnixMs'},
  ],
};

/// Descriptor for `Ping`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pingDescriptor = $convert.base64Decode(
    'CgRQaW5nEiUKD3NlbnRfYXRfdW5peF9tcxgBIAEoA1IMc2VudEF0VW5peE1z');

@$core.Deprecated('Use pongDescriptor instead')
const Pong$json = {
  '1': 'Pong',
  '2': [
    {
      '1': 'client_sent_at_unix_ms',
      '3': 1,
      '4': 1,
      '5': 3,
      '10': 'clientSentAtUnixMs'
    },
    {
      '1': 'server_sent_at_unix_ms',
      '3': 2,
      '4': 1,
      '5': 3,
      '10': 'serverSentAtUnixMs'
    },
  ],
};

/// Descriptor for `Pong`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pongDescriptor = $convert.base64Decode(
    'CgRQb25nEjIKFmNsaWVudF9zZW50X2F0X3VuaXhfbXMYASABKANSEmNsaWVudFNlbnRBdFVuaX'
    'hNcxIyChZzZXJ2ZXJfc2VudF9hdF91bml4X21zGAIgASgDUhJzZXJ2ZXJTZW50QXRVbml4TXM=');

@$core.Deprecated('Use sessionClosingDescriptor instead')
const SessionClosing$json = {
  '1': 'SessionClosing',
  '2': [
    {
      '1': 'reason',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.netkeyboard.v1.ErrorCode',
      '10': 'reason'
    },
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `SessionClosing`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sessionClosingDescriptor = $convert.base64Decode(
    'Cg5TZXNzaW9uQ2xvc2luZxIxCgZyZWFzb24YASABKA4yGS5uZXRrZXlib2FyZC52MS5FcnJvck'
    'NvZGVSBnJlYXNvbhIYCgdtZXNzYWdlGAIgASgJUgdtZXNzYWdl');

@$core.Deprecated('Use commandResultDescriptor instead')
const CommandResult$json = {
  '1': 'CommandResult',
  '2': [
    {'1': 'event_id', '3': 1, '4': 1, '5': 9, '10': 'eventId'},
    {'1': 'success', '3': 2, '4': 1, '5': 8, '10': 'success'},
    {
      '1': 'error_code',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.netkeyboard.v1.ErrorCode',
      '10': 'errorCode'
    },
    {'1': 'message', '3': 4, '4': 1, '5': 9, '10': 'message'},
    {
      '1': 'injected_event_count',
      '3': 5,
      '4': 1,
      '5': 13,
      '10': 'injectedEventCount'
    },
  ],
};

/// Descriptor for `CommandResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commandResultDescriptor = $convert.base64Decode(
    'Cg1Db21tYW5kUmVzdWx0EhkKCGV2ZW50X2lkGAEgASgJUgdldmVudElkEhgKB3N1Y2Nlc3MYAi'
    'ABKAhSB3N1Y2Nlc3MSOAoKZXJyb3JfY29kZRgDIAEoDjIZLm5ldGtleWJvYXJkLnYxLkVycm9y'
    'Q29kZVIJZXJyb3JDb2RlEhgKB21lc3NhZ2UYBCABKAlSB21lc3NhZ2USMAoUaW5qZWN0ZWRfZX'
    'ZlbnRfY291bnQYBSABKA1SEmluamVjdGVkRXZlbnRDb3VudA==');
