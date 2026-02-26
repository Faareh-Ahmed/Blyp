import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:blyp_app/data/repositories/match_repository.dart';
import 'package:blyp_app/domain/models/match_result.dart';

final matchRepositoryProvider = Provider.autoDispose<MatchRepository>((ref) {
  return MatchRepository(Supabase.instance.client);
});

final matchControllerProvider =
    StateNotifierProvider.autoDispose<
      MatchController,
      AsyncValue<MatchResult?>
    >((ref) {
      final repository = ref.read(matchRepositoryProvider);
      return MatchController(repository);
    });

final onlineUsersProvider = StreamProvider.autoDispose<int>((ref) {
  final repository = ref.watch(matchRepositoryProvider);
  return repository.subscribeToOnlineUsers();
});

class MatchController extends StateNotifier<AsyncValue<MatchResult?>> {
  final MatchRepository _repository;
  bool _isCancelled = false;

  StreamSubscription<MatchResult>? _matchSubscription;

  MatchController(this._repository) : super(const AsyncValue.data(null));

  Future<void> startSearching() async {
    state = const AsyncValue.loading();
    _isCancelled = false;

    // 1. Initial check
    try {
      final result = await _repository.findMatch();
      if (_isCancelled) return;

      if (result != null) {
        state = AsyncValue.data(result);
        return;
      }
    } catch (e, st) {
      if (!_isCancelled) {
        state = AsyncValue.error(e, st);
      }
      return;
    }

    // 2. Subscribe to real-time updates if no immediate match
    _matchSubscription?.cancel();
    // Use a more generous lookback period (e.g. 1 minute) or rely on other mechanisms
    // Relying on client vs server time is risky. Let's use 60 seconds to be safe against clock skew.
    // Ideally we should use server time, but for now a generous buffer helps.
    final searchStartTime = DateTime.now().subtract(
      const Duration(seconds: 60),
    );

    _matchSubscription = _repository
        .subscribeToMatches(minCreatedAt: searchStartTime)
        .listen(
          (matchResult) {
            if (_isCancelled) return;

            // Guard: If we already have a match (e.g. from a previous event or race condition), ignore.
            // This prevents duplicate emissions or processing a match after one was already found.
            if (state.value != null) {
              print(
                'MatchController: Already matched, ignoring new stream event on ${matchResult.roomId}',
              );
              return;
            }

            print(
              'MatchController: Match found via stream: ${matchResult.roomId}',
            );
            state = AsyncValue.data(matchResult);
            _matchSubscription?.cancel(); // Stop listening after match
          },
          onError: (error, stack) {
            print('MatchController: Stream error: $error');
            if (!_isCancelled) {
              state = AsyncValue.error(error, stack);
            }
          },
        );
  }

  Future<void> cancelSearch() async {
    _isCancelled = true;
    await _matchSubscription?.cancel();
    _matchSubscription = null;
    state = const AsyncValue.data(null);
    try {
      await _repository.cancelSearch();
    } catch (_) {
      // Ignore errors during cancellation
    }
  }

  @override
  void dispose() {
    _isCancelled = true;
    _matchSubscription?.cancel();
    super.dispose();
  }
}
