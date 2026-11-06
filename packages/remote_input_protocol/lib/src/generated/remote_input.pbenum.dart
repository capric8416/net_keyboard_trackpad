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

import 'package:protobuf/protobuf.dart' as $pb;

class PointerButton extends $pb.ProtobufEnum {
  static const PointerButton POINTER_BUTTON_NONE =
      PointerButton._(0, _omitEnumNames ? '' : 'POINTER_BUTTON_NONE');
  static const PointerButton POINTER_BUTTON_LEFT =
      PointerButton._(1, _omitEnumNames ? '' : 'POINTER_BUTTON_LEFT');
  static const PointerButton POINTER_BUTTON_RIGHT =
      PointerButton._(2, _omitEnumNames ? '' : 'POINTER_BUTTON_RIGHT');
  static const PointerButton POINTER_BUTTON_MIDDLE =
      PointerButton._(3, _omitEnumNames ? '' : 'POINTER_BUTTON_MIDDLE');

  static const $core.List<PointerButton> values = <PointerButton>[
    POINTER_BUTTON_NONE,
    POINTER_BUTTON_LEFT,
    POINTER_BUTTON_RIGHT,
    POINTER_BUTTON_MIDDLE,
  ];

  static final $core.List<PointerButton?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static PointerButton? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const PointerButton._(super.value, super.name);
}

class SystemGesture extends $pb.ProtobufEnum {
  static const SystemGesture SYSTEM_GESTURE_NONE =
      SystemGesture._(0, _omitEnumNames ? '' : 'SYSTEM_GESTURE_NONE');
  static const SystemGesture SYSTEM_GESTURE_ZOOM_IN =
      SystemGesture._(1, _omitEnumNames ? '' : 'SYSTEM_GESTURE_ZOOM_IN');
  static const SystemGesture SYSTEM_GESTURE_ZOOM_OUT =
      SystemGesture._(2, _omitEnumNames ? '' : 'SYSTEM_GESTURE_ZOOM_OUT');
  static const SystemGesture SYSTEM_GESTURE_TASK_VIEW =
      SystemGesture._(3, _omitEnumNames ? '' : 'SYSTEM_GESTURE_TASK_VIEW');
  static const SystemGesture SYSTEM_GESTURE_SHOW_DESKTOP =
      SystemGesture._(4, _omitEnumNames ? '' : 'SYSTEM_GESTURE_SHOW_DESKTOP');
  static const SystemGesture SYSTEM_GESTURE_SWITCH_APP_NEXT = SystemGesture._(
      5, _omitEnumNames ? '' : 'SYSTEM_GESTURE_SWITCH_APP_NEXT');
  static const SystemGesture SYSTEM_GESTURE_SWITCH_APP_PREVIOUS =
      SystemGesture._(
          6, _omitEnumNames ? '' : 'SYSTEM_GESTURE_SWITCH_APP_PREVIOUS');

  static const $core.List<SystemGesture> values = <SystemGesture>[
    SYSTEM_GESTURE_NONE,
    SYSTEM_GESTURE_ZOOM_IN,
    SYSTEM_GESTURE_ZOOM_OUT,
    SYSTEM_GESTURE_TASK_VIEW,
    SYSTEM_GESTURE_SHOW_DESKTOP,
    SYSTEM_GESTURE_SWITCH_APP_NEXT,
    SYSTEM_GESTURE_SWITCH_APP_PREVIOUS,
  ];

  static final $core.List<SystemGesture?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 6);
  static SystemGesture? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SystemGesture._(super.value, super.name);
}

class Capability extends $pb.ProtobufEnum {
  static const Capability CAPABILITY_UNSPECIFIED =
      Capability._(0, _omitEnumNames ? '' : 'CAPABILITY_UNSPECIFIED');
  static const Capability CAPABILITY_KEY_STROKE =
      Capability._(1, _omitEnumNames ? '' : 'CAPABILITY_KEY_STROKE');
  static const Capability CAPABILITY_UNICODE_TEXT =
      Capability._(2, _omitEnumNames ? '' : 'CAPABILITY_UNICODE_TEXT');
  static const Capability CAPABILITY_POINTER =
      Capability._(3, _omitEnumNames ? '' : 'CAPABILITY_POINTER');

  static const $core.List<Capability> values = <Capability>[
    CAPABILITY_UNSPECIFIED,
    CAPABILITY_KEY_STROKE,
    CAPABILITY_UNICODE_TEXT,
    CAPABILITY_POINTER,
  ];

  static final $core.List<Capability?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static Capability? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Capability._(super.value, super.name);
}

class ErrorCode extends $pb.ProtobufEnum {
  static const ErrorCode ERROR_CODE_UNSPECIFIED =
      ErrorCode._(0, _omitEnumNames ? '' : 'ERROR_CODE_UNSPECIFIED');
  static const ErrorCode ERROR_CODE_OK =
      ErrorCode._(1, _omitEnumNames ? '' : 'ERROR_CODE_OK');
  static const ErrorCode ERROR_CODE_UNAUTHENTICATED =
      ErrorCode._(2, _omitEnumNames ? '' : 'ERROR_CODE_UNAUTHENTICATED');
  static const ErrorCode ERROR_CODE_PAIRING_DISABLED =
      ErrorCode._(3, _omitEnumNames ? '' : 'ERROR_CODE_PAIRING_DISABLED');
  static const ErrorCode ERROR_CODE_PAIRING_EXPIRED =
      ErrorCode._(4, _omitEnumNames ? '' : 'ERROR_CODE_PAIRING_EXPIRED');
  static const ErrorCode ERROR_CODE_INVALID_TOTP =
      ErrorCode._(5, _omitEnumNames ? '' : 'ERROR_CODE_INVALID_TOTP');
  static const ErrorCode ERROR_CODE_RATE_LIMITED =
      ErrorCode._(6, _omitEnumNames ? '' : 'ERROR_CODE_RATE_LIMITED');
  static const ErrorCode ERROR_CODE_CERTIFICATE_CHANGED =
      ErrorCode._(7, _omitEnumNames ? '' : 'ERROR_CODE_CERTIFICATE_CHANGED');
  static const ErrorCode ERROR_CODE_INCOMPATIBLE_PROTOCOL =
      ErrorCode._(8, _omitEnumNames ? '' : 'ERROR_CODE_INCOMPATIBLE_PROTOCOL');
  static const ErrorCode ERROR_CODE_CONTROLLER_BUSY =
      ErrorCode._(9, _omitEnumNames ? '' : 'ERROR_CODE_CONTROLLER_BUSY');
  static const ErrorCode ERROR_CODE_INVALID_SEQUENCE =
      ErrorCode._(10, _omitEnumNames ? '' : 'ERROR_CODE_INVALID_SEQUENCE');
  static const ErrorCode ERROR_CODE_DUPLICATE_EVENT =
      ErrorCode._(11, _omitEnumNames ? '' : 'ERROR_CODE_DUPLICATE_EVENT');
  static const ErrorCode ERROR_CODE_UNSUPPORTED_KEY =
      ErrorCode._(12, _omitEnumNames ? '' : 'ERROR_CODE_UNSUPPORTED_KEY');
  static const ErrorCode ERROR_CODE_INVALID_TEXT =
      ErrorCode._(13, _omitEnumNames ? '' : 'ERROR_CODE_INVALID_TEXT');
  static const ErrorCode ERROR_CODE_NO_FOREGROUND_TARGET =
      ErrorCode._(14, _omitEnumNames ? '' : 'ERROR_CODE_NO_FOREGROUND_TARGET');
  static const ErrorCode ERROR_CODE_INPUT_BLOCKED =
      ErrorCode._(15, _omitEnumNames ? '' : 'ERROR_CODE_INPUT_BLOCKED');
  static const ErrorCode ERROR_CODE_INPUT_PARTIAL =
      ErrorCode._(16, _omitEnumNames ? '' : 'ERROR_CODE_INPUT_PARTIAL');
  static const ErrorCode ERROR_CODE_INTERNAL =
      ErrorCode._(17, _omitEnumNames ? '' : 'ERROR_CODE_INTERNAL');

  static const $core.List<ErrorCode> values = <ErrorCode>[
    ERROR_CODE_UNSPECIFIED,
    ERROR_CODE_OK,
    ERROR_CODE_UNAUTHENTICATED,
    ERROR_CODE_PAIRING_DISABLED,
    ERROR_CODE_PAIRING_EXPIRED,
    ERROR_CODE_INVALID_TOTP,
    ERROR_CODE_RATE_LIMITED,
    ERROR_CODE_CERTIFICATE_CHANGED,
    ERROR_CODE_INCOMPATIBLE_PROTOCOL,
    ERROR_CODE_CONTROLLER_BUSY,
    ERROR_CODE_INVALID_SEQUENCE,
    ERROR_CODE_DUPLICATE_EVENT,
    ERROR_CODE_UNSUPPORTED_KEY,
    ERROR_CODE_INVALID_TEXT,
    ERROR_CODE_NO_FOREGROUND_TARGET,
    ERROR_CODE_INPUT_BLOCKED,
    ERROR_CODE_INPUT_PARTIAL,
    ERROR_CODE_INTERNAL,
  ];

  static final $core.List<ErrorCode?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 17);
  static ErrorCode? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ErrorCode._(super.value, super.name);
}

class SemanticKey extends $pb.ProtobufEnum {
  static const SemanticKey SEMANTIC_KEY_UNSPECIFIED =
      SemanticKey._(0, _omitEnumNames ? '' : 'SEMANTIC_KEY_UNSPECIFIED');
  static const SemanticKey SEMANTIC_KEY_ESCAPE =
      SemanticKey._(1, _omitEnumNames ? '' : 'SEMANTIC_KEY_ESCAPE');
  static const SemanticKey SEMANTIC_KEY_F1 =
      SemanticKey._(2, _omitEnumNames ? '' : 'SEMANTIC_KEY_F1');
  static const SemanticKey SEMANTIC_KEY_F2 =
      SemanticKey._(3, _omitEnumNames ? '' : 'SEMANTIC_KEY_F2');
  static const SemanticKey SEMANTIC_KEY_F3 =
      SemanticKey._(4, _omitEnumNames ? '' : 'SEMANTIC_KEY_F3');
  static const SemanticKey SEMANTIC_KEY_F4 =
      SemanticKey._(5, _omitEnumNames ? '' : 'SEMANTIC_KEY_F4');
  static const SemanticKey SEMANTIC_KEY_F5 =
      SemanticKey._(6, _omitEnumNames ? '' : 'SEMANTIC_KEY_F5');
  static const SemanticKey SEMANTIC_KEY_F6 =
      SemanticKey._(7, _omitEnumNames ? '' : 'SEMANTIC_KEY_F6');
  static const SemanticKey SEMANTIC_KEY_F7 =
      SemanticKey._(8, _omitEnumNames ? '' : 'SEMANTIC_KEY_F7');
  static const SemanticKey SEMANTIC_KEY_F8 =
      SemanticKey._(9, _omitEnumNames ? '' : 'SEMANTIC_KEY_F8');
  static const SemanticKey SEMANTIC_KEY_F9 =
      SemanticKey._(10, _omitEnumNames ? '' : 'SEMANTIC_KEY_F9');
  static const SemanticKey SEMANTIC_KEY_F10 =
      SemanticKey._(11, _omitEnumNames ? '' : 'SEMANTIC_KEY_F10');
  static const SemanticKey SEMANTIC_KEY_F11 =
      SemanticKey._(12, _omitEnumNames ? '' : 'SEMANTIC_KEY_F11');
  static const SemanticKey SEMANTIC_KEY_F12 =
      SemanticKey._(13, _omitEnumNames ? '' : 'SEMANTIC_KEY_F12');
  static const SemanticKey SEMANTIC_KEY_PRINT_SCREEN =
      SemanticKey._(14, _omitEnumNames ? '' : 'SEMANTIC_KEY_PRINT_SCREEN');
  static const SemanticKey SEMANTIC_KEY_DELETE =
      SemanticKey._(15, _omitEnumNames ? '' : 'SEMANTIC_KEY_DELETE');
  static const SemanticKey SEMANTIC_KEY_HOME =
      SemanticKey._(16, _omitEnumNames ? '' : 'SEMANTIC_KEY_HOME');
  static const SemanticKey SEMANTIC_KEY_BACKQUOTE =
      SemanticKey._(17, _omitEnumNames ? '' : 'SEMANTIC_KEY_BACKQUOTE');
  static const SemanticKey SEMANTIC_KEY_DIGIT_1 =
      SemanticKey._(18, _omitEnumNames ? '' : 'SEMANTIC_KEY_DIGIT_1');
  static const SemanticKey SEMANTIC_KEY_DIGIT_2 =
      SemanticKey._(19, _omitEnumNames ? '' : 'SEMANTIC_KEY_DIGIT_2');
  static const SemanticKey SEMANTIC_KEY_DIGIT_3 =
      SemanticKey._(20, _omitEnumNames ? '' : 'SEMANTIC_KEY_DIGIT_3');
  static const SemanticKey SEMANTIC_KEY_DIGIT_4 =
      SemanticKey._(21, _omitEnumNames ? '' : 'SEMANTIC_KEY_DIGIT_4');
  static const SemanticKey SEMANTIC_KEY_DIGIT_5 =
      SemanticKey._(22, _omitEnumNames ? '' : 'SEMANTIC_KEY_DIGIT_5');
  static const SemanticKey SEMANTIC_KEY_DIGIT_6 =
      SemanticKey._(23, _omitEnumNames ? '' : 'SEMANTIC_KEY_DIGIT_6');
  static const SemanticKey SEMANTIC_KEY_DIGIT_7 =
      SemanticKey._(24, _omitEnumNames ? '' : 'SEMANTIC_KEY_DIGIT_7');
  static const SemanticKey SEMANTIC_KEY_DIGIT_8 =
      SemanticKey._(25, _omitEnumNames ? '' : 'SEMANTIC_KEY_DIGIT_8');
  static const SemanticKey SEMANTIC_KEY_DIGIT_9 =
      SemanticKey._(26, _omitEnumNames ? '' : 'SEMANTIC_KEY_DIGIT_9');
  static const SemanticKey SEMANTIC_KEY_DIGIT_0 =
      SemanticKey._(27, _omitEnumNames ? '' : 'SEMANTIC_KEY_DIGIT_0');
  static const SemanticKey SEMANTIC_KEY_MINUS =
      SemanticKey._(28, _omitEnumNames ? '' : 'SEMANTIC_KEY_MINUS');
  static const SemanticKey SEMANTIC_KEY_EQUAL =
      SemanticKey._(29, _omitEnumNames ? '' : 'SEMANTIC_KEY_EQUAL');
  static const SemanticKey SEMANTIC_KEY_BACKSPACE =
      SemanticKey._(30, _omitEnumNames ? '' : 'SEMANTIC_KEY_BACKSPACE');
  static const SemanticKey SEMANTIC_KEY_PAGE_UP =
      SemanticKey._(31, _omitEnumNames ? '' : 'SEMANTIC_KEY_PAGE_UP');
  static const SemanticKey SEMANTIC_KEY_TAB =
      SemanticKey._(32, _omitEnumNames ? '' : 'SEMANTIC_KEY_TAB');
  static const SemanticKey SEMANTIC_KEY_KEY_Q =
      SemanticKey._(33, _omitEnumNames ? '' : 'SEMANTIC_KEY_KEY_Q');
  static const SemanticKey SEMANTIC_KEY_KEY_W =
      SemanticKey._(34, _omitEnumNames ? '' : 'SEMANTIC_KEY_KEY_W');
  static const SemanticKey SEMANTIC_KEY_KEY_E =
      SemanticKey._(35, _omitEnumNames ? '' : 'SEMANTIC_KEY_KEY_E');
  static const SemanticKey SEMANTIC_KEY_KEY_R =
      SemanticKey._(36, _omitEnumNames ? '' : 'SEMANTIC_KEY_KEY_R');
  static const SemanticKey SEMANTIC_KEY_KEY_T =
      SemanticKey._(37, _omitEnumNames ? '' : 'SEMANTIC_KEY_KEY_T');
  static const SemanticKey SEMANTIC_KEY_KEY_Y =
      SemanticKey._(38, _omitEnumNames ? '' : 'SEMANTIC_KEY_KEY_Y');
  static const SemanticKey SEMANTIC_KEY_KEY_U =
      SemanticKey._(39, _omitEnumNames ? '' : 'SEMANTIC_KEY_KEY_U');
  static const SemanticKey SEMANTIC_KEY_KEY_I =
      SemanticKey._(40, _omitEnumNames ? '' : 'SEMANTIC_KEY_KEY_I');
  static const SemanticKey SEMANTIC_KEY_KEY_O =
      SemanticKey._(41, _omitEnumNames ? '' : 'SEMANTIC_KEY_KEY_O');
  static const SemanticKey SEMANTIC_KEY_KEY_P =
      SemanticKey._(42, _omitEnumNames ? '' : 'SEMANTIC_KEY_KEY_P');
  static const SemanticKey SEMANTIC_KEY_BRACKET_LEFT =
      SemanticKey._(43, _omitEnumNames ? '' : 'SEMANTIC_KEY_BRACKET_LEFT');
  static const SemanticKey SEMANTIC_KEY_BRACKET_RIGHT =
      SemanticKey._(44, _omitEnumNames ? '' : 'SEMANTIC_KEY_BRACKET_RIGHT');
  static const SemanticKey SEMANTIC_KEY_BACKSLASH =
      SemanticKey._(45, _omitEnumNames ? '' : 'SEMANTIC_KEY_BACKSLASH');
  static const SemanticKey SEMANTIC_KEY_PAGE_DOWN =
      SemanticKey._(46, _omitEnumNames ? '' : 'SEMANTIC_KEY_PAGE_DOWN');
  static const SemanticKey SEMANTIC_KEY_CAPS_LOCK =
      SemanticKey._(47, _omitEnumNames ? '' : 'SEMANTIC_KEY_CAPS_LOCK');
  static const SemanticKey SEMANTIC_KEY_KEY_A =
      SemanticKey._(48, _omitEnumNames ? '' : 'SEMANTIC_KEY_KEY_A');
  static const SemanticKey SEMANTIC_KEY_KEY_S =
      SemanticKey._(49, _omitEnumNames ? '' : 'SEMANTIC_KEY_KEY_S');
  static const SemanticKey SEMANTIC_KEY_KEY_D =
      SemanticKey._(50, _omitEnumNames ? '' : 'SEMANTIC_KEY_KEY_D');
  static const SemanticKey SEMANTIC_KEY_KEY_F =
      SemanticKey._(51, _omitEnumNames ? '' : 'SEMANTIC_KEY_KEY_F');
  static const SemanticKey SEMANTIC_KEY_KEY_G =
      SemanticKey._(52, _omitEnumNames ? '' : 'SEMANTIC_KEY_KEY_G');
  static const SemanticKey SEMANTIC_KEY_KEY_H =
      SemanticKey._(53, _omitEnumNames ? '' : 'SEMANTIC_KEY_KEY_H');
  static const SemanticKey SEMANTIC_KEY_KEY_J =
      SemanticKey._(54, _omitEnumNames ? '' : 'SEMANTIC_KEY_KEY_J');
  static const SemanticKey SEMANTIC_KEY_KEY_K =
      SemanticKey._(55, _omitEnumNames ? '' : 'SEMANTIC_KEY_KEY_K');
  static const SemanticKey SEMANTIC_KEY_KEY_L =
      SemanticKey._(56, _omitEnumNames ? '' : 'SEMANTIC_KEY_KEY_L');
  static const SemanticKey SEMANTIC_KEY_SEMICOLON =
      SemanticKey._(57, _omitEnumNames ? '' : 'SEMANTIC_KEY_SEMICOLON');
  static const SemanticKey SEMANTIC_KEY_QUOTE =
      SemanticKey._(58, _omitEnumNames ? '' : 'SEMANTIC_KEY_QUOTE');
  static const SemanticKey SEMANTIC_KEY_ENTER =
      SemanticKey._(59, _omitEnumNames ? '' : 'SEMANTIC_KEY_ENTER');
  static const SemanticKey SEMANTIC_KEY_KEY_Z =
      SemanticKey._(60, _omitEnumNames ? '' : 'SEMANTIC_KEY_KEY_Z');
  static const SemanticKey SEMANTIC_KEY_KEY_X =
      SemanticKey._(61, _omitEnumNames ? '' : 'SEMANTIC_KEY_KEY_X');
  static const SemanticKey SEMANTIC_KEY_KEY_C =
      SemanticKey._(62, _omitEnumNames ? '' : 'SEMANTIC_KEY_KEY_C');
  static const SemanticKey SEMANTIC_KEY_KEY_V =
      SemanticKey._(63, _omitEnumNames ? '' : 'SEMANTIC_KEY_KEY_V');
  static const SemanticKey SEMANTIC_KEY_KEY_B =
      SemanticKey._(64, _omitEnumNames ? '' : 'SEMANTIC_KEY_KEY_B');
  static const SemanticKey SEMANTIC_KEY_KEY_N =
      SemanticKey._(65, _omitEnumNames ? '' : 'SEMANTIC_KEY_KEY_N');
  static const SemanticKey SEMANTIC_KEY_KEY_M =
      SemanticKey._(66, _omitEnumNames ? '' : 'SEMANTIC_KEY_KEY_M');
  static const SemanticKey SEMANTIC_KEY_COMMA =
      SemanticKey._(67, _omitEnumNames ? '' : 'SEMANTIC_KEY_COMMA');
  static const SemanticKey SEMANTIC_KEY_PERIOD =
      SemanticKey._(68, _omitEnumNames ? '' : 'SEMANTIC_KEY_PERIOD');
  static const SemanticKey SEMANTIC_KEY_SLASH =
      SemanticKey._(69, _omitEnumNames ? '' : 'SEMANTIC_KEY_SLASH');
  static const SemanticKey SEMANTIC_KEY_ARROW_UP =
      SemanticKey._(70, _omitEnumNames ? '' : 'SEMANTIC_KEY_ARROW_UP');
  static const SemanticKey SEMANTIC_KEY_END =
      SemanticKey._(71, _omitEnumNames ? '' : 'SEMANTIC_KEY_END');
  static const SemanticKey SEMANTIC_KEY_SPACE =
      SemanticKey._(72, _omitEnumNames ? '' : 'SEMANTIC_KEY_SPACE');
  static const SemanticKey SEMANTIC_KEY_MENU =
      SemanticKey._(73, _omitEnumNames ? '' : 'SEMANTIC_KEY_MENU');
  static const SemanticKey SEMANTIC_KEY_ARROW_LEFT =
      SemanticKey._(74, _omitEnumNames ? '' : 'SEMANTIC_KEY_ARROW_LEFT');
  static const SemanticKey SEMANTIC_KEY_ARROW_DOWN =
      SemanticKey._(75, _omitEnumNames ? '' : 'SEMANTIC_KEY_ARROW_DOWN');
  static const SemanticKey SEMANTIC_KEY_ARROW_RIGHT =
      SemanticKey._(76, _omitEnumNames ? '' : 'SEMANTIC_KEY_ARROW_RIGHT');

  static const $core.List<SemanticKey> values = <SemanticKey>[
    SEMANTIC_KEY_UNSPECIFIED,
    SEMANTIC_KEY_ESCAPE,
    SEMANTIC_KEY_F1,
    SEMANTIC_KEY_F2,
    SEMANTIC_KEY_F3,
    SEMANTIC_KEY_F4,
    SEMANTIC_KEY_F5,
    SEMANTIC_KEY_F6,
    SEMANTIC_KEY_F7,
    SEMANTIC_KEY_F8,
    SEMANTIC_KEY_F9,
    SEMANTIC_KEY_F10,
    SEMANTIC_KEY_F11,
    SEMANTIC_KEY_F12,
    SEMANTIC_KEY_PRINT_SCREEN,
    SEMANTIC_KEY_DELETE,
    SEMANTIC_KEY_HOME,
    SEMANTIC_KEY_BACKQUOTE,
    SEMANTIC_KEY_DIGIT_1,
    SEMANTIC_KEY_DIGIT_2,
    SEMANTIC_KEY_DIGIT_3,
    SEMANTIC_KEY_DIGIT_4,
    SEMANTIC_KEY_DIGIT_5,
    SEMANTIC_KEY_DIGIT_6,
    SEMANTIC_KEY_DIGIT_7,
    SEMANTIC_KEY_DIGIT_8,
    SEMANTIC_KEY_DIGIT_9,
    SEMANTIC_KEY_DIGIT_0,
    SEMANTIC_KEY_MINUS,
    SEMANTIC_KEY_EQUAL,
    SEMANTIC_KEY_BACKSPACE,
    SEMANTIC_KEY_PAGE_UP,
    SEMANTIC_KEY_TAB,
    SEMANTIC_KEY_KEY_Q,
    SEMANTIC_KEY_KEY_W,
    SEMANTIC_KEY_KEY_E,
    SEMANTIC_KEY_KEY_R,
    SEMANTIC_KEY_KEY_T,
    SEMANTIC_KEY_KEY_Y,
    SEMANTIC_KEY_KEY_U,
    SEMANTIC_KEY_KEY_I,
    SEMANTIC_KEY_KEY_O,
    SEMANTIC_KEY_KEY_P,
    SEMANTIC_KEY_BRACKET_LEFT,
    SEMANTIC_KEY_BRACKET_RIGHT,
    SEMANTIC_KEY_BACKSLASH,
    SEMANTIC_KEY_PAGE_DOWN,
    SEMANTIC_KEY_CAPS_LOCK,
    SEMANTIC_KEY_KEY_A,
    SEMANTIC_KEY_KEY_S,
    SEMANTIC_KEY_KEY_D,
    SEMANTIC_KEY_KEY_F,
    SEMANTIC_KEY_KEY_G,
    SEMANTIC_KEY_KEY_H,
    SEMANTIC_KEY_KEY_J,
    SEMANTIC_KEY_KEY_K,
    SEMANTIC_KEY_KEY_L,
    SEMANTIC_KEY_SEMICOLON,
    SEMANTIC_KEY_QUOTE,
    SEMANTIC_KEY_ENTER,
    SEMANTIC_KEY_KEY_Z,
    SEMANTIC_KEY_KEY_X,
    SEMANTIC_KEY_KEY_C,
    SEMANTIC_KEY_KEY_V,
    SEMANTIC_KEY_KEY_B,
    SEMANTIC_KEY_KEY_N,
    SEMANTIC_KEY_KEY_M,
    SEMANTIC_KEY_COMMA,
    SEMANTIC_KEY_PERIOD,
    SEMANTIC_KEY_SLASH,
    SEMANTIC_KEY_ARROW_UP,
    SEMANTIC_KEY_END,
    SEMANTIC_KEY_SPACE,
    SEMANTIC_KEY_MENU,
    SEMANTIC_KEY_ARROW_LEFT,
    SEMANTIC_KEY_ARROW_DOWN,
    SEMANTIC_KEY_ARROW_RIGHT,
  ];

  static final $core.List<SemanticKey?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 76);
  static SemanticKey? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SemanticKey._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
