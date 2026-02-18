class MatchResult {
  final String roomId;
  final String matchedUserId;

  MatchResult({required this.roomId, required this.matchedUserId});

  factory MatchResult.fromJson(Map<String, dynamic> json) {
    return MatchResult(
      roomId: json['room_id'] as String,
      matchedUserId: json['matched_user_id'] as String,
    );
  }
}
