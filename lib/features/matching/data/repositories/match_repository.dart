import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:blyp_app/features/matching/domain/models/match_result.dart';
import 'dart:async';

class MatchRepository {
  final SupabaseClient _supabase;

  MatchRepository(this._supabase);

  Future<void> updateInterests(List<String> interests) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    print('Updating interests for user $userId: $interests');
    await _supabase
        .from('profiles')
        .update({'interests': interests})
        .eq('id', userId);
  }

  Future<MatchResult?> findMatch() async {
    final userId = _supabase.auth.currentUser!.id;
    print('Find match called for user: $userId');
    try {
      final response = await _supabase.rpc(
        'find_match',
        params: {'user_id': userId},
      );
      print('Find match response: $response');

      if (response != null && (response as List).isNotEmpty) {
        final data = response[0] as Map<String, dynamic>;
        print('Match found immediately: $data');
        return MatchResult.fromJson(data);
      }
      print(
        'No immediate match found, waiting... (Check if interests are set or compatible)',
      );
      return null;
    } catch (e) {
      print('Error finding match: $e');
      // If error occurs, rethrow or handle specific errors
      rethrow;
    }
  }

  Future<void> cancelSearch() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase
        .from('profiles')
        .update({'is_searching': false})
        .eq('id', userId);
  }

  Stream<MatchResult> subscribeToMatches({DateTime? minCreatedAt}) {
    final userId = _supabase.auth.currentUser!.id;
    print(
      'Subscribing to matches for user: $userId (minCreatedAt: $minCreatedAt)',
    );

    late RealtimeChannel channel;
    late StreamController<MatchResult> controller;

    controller = StreamController<MatchResult>(
      onListen: () {
        channel = _supabase.channel('matches_realtime_$userId');

        channel.onPostgresChanges(
          event: PostgresChangeEvent.insert,
          table: 'matches',
          schema: 'public',
          callback: (payload) {
            final data = payload.newRecord;
            final isUser = data['user_1'] == userId || data['user_2'] == userId;
            if (!isUser) {
              print('PostgresChange: Not our match, skipping');
              return;
            }

            if (minCreatedAt != null) {
              final createdAtStr = data['created_at'] as String?;
              if (createdAtStr == null) {
                print('PostgresChange: No created_at, skipping');
                return;
              }
              final createdAt = DateTime.tryParse(createdAtStr);
              if (createdAt == null || createdAt.isBefore(minCreatedAt)) {
                print('PostgresChange: Match too old, skipping');
                return;
              }
            }

            if (controller.isClosed) return;

            final user1 = data['user_1'] as String;
            final user2 = data['user_2'] as String;
            final matchedUserId = (user1 == userId) ? user2 : user1;

            print('PostgresChange: Match found for user $userId');
            controller.add(MatchResult(
              roomId: data['room_id'] as String,
              matchedUserId: matchedUserId,
              createdAt: data['created_at'] != null
                  ? DateTime.parse(data['created_at'] as String)
                  : null,
            ));
          },
        ).subscribe();
      },
      onCancel: () {
        channel.unsubscribe();
      },
    );

    return controller.stream;
  }

  Stream<int> subscribeToOnlineUsers() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return Stream.value(0);

    // Create a stream controller to emit counts
    late StreamController<int> controller;
    RealtimeChannel? channel;

    controller = StreamController<int>(
      onListen: () {
        channel = _supabase.channel('online_users');

        channel!.onPresenceSync((payload) {
          if (!controller.isClosed) {
            // presenceState returns Map<String, List<Presence>>
            // We count the number of keys (unique users)
            final state = channel!.presenceState();
            controller.add(state.length);
          }
        });

        channel!.subscribe((status, error) {
          if (status == RealtimeSubscribeStatus.subscribed) {
            // Track presence for the current user
            // We can send metadata, but 'online_at' is enough to count them
            channel!.track({'online_at': DateTime.now().toIso8601String()});
          }
        });
      },
      onCancel: () {
        channel?.unsubscribe();
      },
    );

    return controller.stream;
  }
}
