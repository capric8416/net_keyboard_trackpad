// This is a generated file - do not edit.
//
// Generated from remote_input.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'remote_input.pb.dart' as $0;

export 'remote_input.pb.dart';

@$pb.GrpcServiceName('netkeyboard.v1.RemoteInputService')
class RemoteInputServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  RemoteInputServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.ServerInfoResponse> getServerInfo(
    $0.ServerInfoRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getServerInfo, request, options: options);
  }

  $grpc.ResponseFuture<$0.PairingChallengeResponse> createPairingChallenge(
    $0.PairingChallengeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createPairingChallenge, request,
        options: options);
  }

  $grpc.ResponseFuture<$0.PairResponse> pair(
    $0.PairRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$pair, request, options: options);
  }

  $grpc.ResponseStream<$0.ServerEnvelope> control(
    $async.Stream<$0.ClientEnvelope> request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(_$control, request, options: options);
  }

  // method descriptors

  static final _$getServerInfo =
      $grpc.ClientMethod<$0.ServerInfoRequest, $0.ServerInfoResponse>(
          '/netkeyboard.v1.RemoteInputService/GetServerInfo',
          ($0.ServerInfoRequest value) => value.writeToBuffer(),
          $0.ServerInfoResponse.fromBuffer);
  static final _$createPairingChallenge = $grpc.ClientMethod<
          $0.PairingChallengeRequest, $0.PairingChallengeResponse>(
      '/netkeyboard.v1.RemoteInputService/CreatePairingChallenge',
      ($0.PairingChallengeRequest value) => value.writeToBuffer(),
      $0.PairingChallengeResponse.fromBuffer);
  static final _$pair = $grpc.ClientMethod<$0.PairRequest, $0.PairResponse>(
      '/netkeyboard.v1.RemoteInputService/Pair',
      ($0.PairRequest value) => value.writeToBuffer(),
      $0.PairResponse.fromBuffer);
  static final _$control =
      $grpc.ClientMethod<$0.ClientEnvelope, $0.ServerEnvelope>(
          '/netkeyboard.v1.RemoteInputService/Control',
          ($0.ClientEnvelope value) => value.writeToBuffer(),
          $0.ServerEnvelope.fromBuffer);
}

@$pb.GrpcServiceName('netkeyboard.v1.RemoteInputService')
abstract class RemoteInputServiceBase extends $grpc.Service {
  $core.String get $name => 'netkeyboard.v1.RemoteInputService';

  RemoteInputServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.ServerInfoRequest, $0.ServerInfoResponse>(
        'GetServerInfo',
        getServerInfo_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ServerInfoRequest.fromBuffer(value),
        ($0.ServerInfoResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PairingChallengeRequest,
            $0.PairingChallengeResponse>(
        'CreatePairingChallenge',
        createPairingChallenge_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.PairingChallengeRequest.fromBuffer(value),
        ($0.PairingChallengeResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PairRequest, $0.PairResponse>(
        'Pair',
        pair_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.PairRequest.fromBuffer(value),
        ($0.PairResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ClientEnvelope, $0.ServerEnvelope>(
        'Control',
        control,
        true,
        true,
        ($core.List<$core.int> value) => $0.ClientEnvelope.fromBuffer(value),
        ($0.ServerEnvelope value) => value.writeToBuffer()));
  }

  $async.Future<$0.ServerInfoResponse> getServerInfo_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ServerInfoRequest> $request) async {
    return getServerInfo($call, await $request);
  }

  $async.Future<$0.ServerInfoResponse> getServerInfo(
      $grpc.ServiceCall call, $0.ServerInfoRequest request);

  $async.Future<$0.PairingChallengeResponse> createPairingChallenge_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.PairingChallengeRequest> $request) async {
    return createPairingChallenge($call, await $request);
  }

  $async.Future<$0.PairingChallengeResponse> createPairingChallenge(
      $grpc.ServiceCall call, $0.PairingChallengeRequest request);

  $async.Future<$0.PairResponse> pair_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.PairRequest> $request) async {
    return pair($call, await $request);
  }

  $async.Future<$0.PairResponse> pair(
      $grpc.ServiceCall call, $0.PairRequest request);

  $async.Stream<$0.ServerEnvelope> control(
      $grpc.ServiceCall call, $async.Stream<$0.ClientEnvelope> request);
}
