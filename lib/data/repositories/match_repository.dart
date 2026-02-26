import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:blyp_app/domain/models/match_result.dart';
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

    // Listen for INSERT events on the 'matches' table using postgresChanges
    return _supabase
        .from('matches')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((maps) {
          // Stream returns a List<Map<String, dynamic>> of rows
          // We assume RLS allows us to see rows where we are user_1 or user_2
          if (maps.isEmpty) {
            print('Stream: No matches yet');
            return null;
          }

          // Client-side filtering to be double sure and safe
          final relevantMatches = maps.where((data) {
            final isUser = data['user_1'] == userId || data['user_2'] == userId;
            if (!isUser) return false;

            if (minCreatedAt != null) {
              final createdAtStr = data['created_at'] as String?;
              if (createdAtStr == null) return false; // Should not happen
              final createdAt = DateTime.tryParse(createdAtStr);
              if (createdAt == null || createdAt.isBefore(minCreatedAt)) {
                return false;
              }
            }
            return true;
          }).toList();

          if (relevantMatches.isEmpty) {
            print('Stream: No relevant matches found (after filtering)');
            return null;
          }

          print('Stream: Found relevant match: ${relevantMatches.first}');
          return relevantMatches.first;
        })
        .where((data) => data != null)
        .map((data) {
          final matchData = data!;
          // Determine who the matched user is
          final user1 = matchData['user_1'] as String;
          final user2 = matchData['user_2'] as String;
          final matchedUserId = (user1 == userId) ? user2 : user1;

          return MatchResult(
            roomId: matchData['room_id'] as String,
            matchedUserId: matchedUserId,
            createdAt: matchData['created_at'] != null
                ? DateTime.parse(matchData['created_at'] as String)
                : null,
          );
        });
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
