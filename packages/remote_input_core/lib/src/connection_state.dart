enum ConnectionPhase {
  disconnected,
  resolving,
  tlsConnecting,
  authenticating,
  openingControl,
  connected,
  backingOff,
  pairingRequired,
  userActionRequired,
  error,
}

final class ConnectionStatus {
  const ConnectionStatus(this.phase, {this.message, this.retryAttempt = 0});

  final ConnectionPhase phase;
  final String? message;
  final int retryAttempt;

  bool get canSend => phase == ConnectionPhase.connected;

  ConnectionStatus copyWith({
    ConnectionPhase? phase,
    String? message,
    int? retryAttempt,
  }) => ConnectionStatus(
    phase ?? this.phase,
    message: message ?? this.message,
    retryAttempt: retryAttempt ?? this.retryAttempt,
  );
}
