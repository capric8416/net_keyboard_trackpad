enum VoiceInputPhase {
  ready,
  pressing,
  recording,
  recognizing,
  reviewing,
  submitting,
  unavailable,
}

final class VoiceInputState {
  const VoiceInputState(
    this.phase, {
    this.operationId,
    this.reviewText,
    this.message,
  });

  const VoiceInputState.ready()
    : phase = VoiceInputPhase.ready,
      operationId = null,
      reviewText = null,
      message = null;

  final VoiceInputPhase phase;
  final String? operationId;
  final String? reviewText;
  final String? message;

  bool get hasReviewText =>
      phase == VoiceInputPhase.reviewing &&
      reviewText != null &&
      reviewText!.trim().isNotEmpty;
}
