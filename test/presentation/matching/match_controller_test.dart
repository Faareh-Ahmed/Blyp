import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:blyp_app/features/matching/presentation/controllers/match_controller.dart';
import 'package:blyp_app/features/matching/data/repositories/match_repository.dart';
import 'package:blyp_app/features/matching/domain/models/match_result.dart';

class MockMatchRepository extends Mock implements MatchRepository {}

void main() {
  late MockMatchRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockMatchRepository();
    container = ProviderContainer(
      overrides: [matchRepositoryProvider.overrideWithValue(mockRepository)],
    );
    // Keep provider alive
    container.listen(matchControllerProvider, (_, __) {});
  });

  tearDown(() {
    container.dispose();
  });

  test('startSearching emits data when match is found immediately', () async {
    final matchResult = MatchResult(
      roomId: 'room_123',
      matchedUserId: 'user_456',
    );
    when(() => mockRepository.findMatch()).thenAnswer((_) async => matchResult);
    when(() => mockRepository.cancelSearch()).thenAnswer((_) async {});
    // Even if found immediately, controller technically doesn't subscribe, so strict verify might fail if we checked subscribe call
    // But let's verify logic flow

    final controller = container.read(matchControllerProvider.notifier);

    // Initial state check
    expect(
      container.read(matchControllerProvider),
      const AsyncValue<MatchResult?>.data(null),
    );

    // Start searching
    await controller.startSearching();

    // Check final state
    expect(
      container.read(matchControllerProvider),
      isA<AsyncData<MatchResult?>>().having(
        (d) => d.value,
        'value',
        matchResult,
      ),
    );
    verify(() => mockRepository.findMatch()).called(1);
    verifyNever(() => mockRepository.subscribeToMatches());
  });

  test('startSearching subscribes to stream if no match immediately', () async {
    final matchResult = MatchResult(
      roomId: 'room_123',
      matchedUserId: 'user_456',
    );
    when(() => mockRepository.findMatch()).thenAnswer((_) async => null);
    when(
      () => mockRepository.subscribeToMatches(),
    ).thenAnswer((_) => Stream.value(matchResult));
    when(() => mockRepository.cancelSearch()).thenAnswer((_) async {});

    final controller = container.read(matchControllerProvider.notifier);

    await controller.startSearching();

    // Allow stream to emit and controller to update
    await Future.delayed(const Duration(milliseconds: 100));

    expect(
      container.read(matchControllerProvider),
      isA<AsyncData<MatchResult?>>().having(
        (d) => d.value,
        'value',
        matchResult,
      ),
    );
    verify(() => mockRepository.findMatch()).called(1);
    verify(() => mockRepository.subscribeToMatches()).called(1);
  });

  test('startSearching handles errors', () async {
    final exception = Exception('Network error');
    when(() => mockRepository.findMatch()).thenThrow(exception);
    when(() => mockRepository.cancelSearch()).thenAnswer((_) async {});

    final controller = container.read(matchControllerProvider.notifier);

    await controller.startSearching();

    final state = container.read(matchControllerProvider);
    expect(state.hasError, true);
    expect(state.error, exception);
  });
}
