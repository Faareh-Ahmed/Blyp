class MatchResult {
  final String roomId;
  final String matchedUserId;
  final DateTime? createdAt;

  MatchResult({
    required this.roomId,
    required this.matchedUserId,
    this.createdAt,
  });

  factory MatchResult.fromJson(Map<String, dynamic> json) {
    // Helper to get the ID safely
    String getId() {
      if (json['matched_user_id'] != null) {
        return json['matched_user_id'] as String;
      }
      // If we are looking at raw match row where we need to figure out which user is the "other" one
      // This logic is flawed if we don't know "our" user ID here.
      // However, usually 'matched_user_id' is returned by the RPC or calculated before passed here.
      // For creating from stream events, match_repository calculates matchedUserId before creating MatchResult
      // But let's keep it safe.
      return (json['matched_user_id'] ?? json['user_2'] ?? json['user_1'])
          as String;
    }

    return MatchResult(
      roomId: json['room_id'] as String,
      matchedUserId: getId(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}
