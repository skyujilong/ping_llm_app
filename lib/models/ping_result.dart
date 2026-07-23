/// Result of a single ping operation.
class PingResult {
  PingResult({
    required this.providerId,
    required this.success,
    this.latencyMs,
    this.timestamp,
    this.errorMessage,
    this.responseBody,
    this.tokensUsed,
  });

  final String providerId;
  final bool success;
  final int? latencyMs;
  final DateTime? timestamp;
  final String? errorMessage;
  final String? responseBody;
  final int? tokensUsed;
}
