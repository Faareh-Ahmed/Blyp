import 'dart:async';
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
  });

  tearDown(() {
    container.dispose();
  });

  test('startSearching verifies duplicate emission guard', () async {
    final matchResult1 = MatchResult(roomId: 'room_1', matchedUserId: 'user_1');
    final matchResult2 = MatchResult(roomId: 'room_2', matchedUserId: 'user_2');

    final controller = container.read(matchControllerProvider.notifier);
    // Keep provider alive via subscription
    container.listen(matchControllerProvider, (_, __) {});
    final streamController = StreamController<MatchResult>();

    when(() => mockRepository.findMatch()).thenAnswer((_) async => null);
    when(
      () => mockRepository.subscribeToMatches(
        minCreatedAt: any(named: 'minCreatedAt'),
      ),
    ).thenAnswer((_) => streamController.stream);

    await controller.startSearching();

    // Emit first match
    streamController.add(matchResult1);
    await Future.delayed(const Duration(milliseconds: 50));

    // Verify first match is set
    expect(container.read(matchControllerProvider).value, matchResult1);

    // Emit second match (duplicate or race condition)
    streamController.add(matchResult2);
    await Future.delayed(const Duration(milliseconds: 50));

    // Verify state matches first result, IGNORING second result
    expect(container.read(matchControllerProvider).value, matchResult1);

    await streamController.close();
  });

  test('cancelSearch stops processing stream events', () async {
    final matchResult = MatchResult(roomId: 'room_1', matchedUserId: 'user_1');
    final controller = container.read(matchControllerProvider.notifier);
    final streamController = StreamController<MatchResult>();

    when(() => mockRepository.findMatch()).thenAnswer((_) async => null);
    when(
      () => mockRepository.subscribeToMatches(
        minCreatedAt: any(named: 'minCreatedAt'),
      ),
    ).thenAnswer((_) => streamController.stream);
    when(() => mockRepository.cancelSearch()).thenAnswer((_) async {});

    await controller.startSearching();

    // Cancel search
    await controller.cancelSearch();

    // Emit match active AFTER cancellation
    streamController.add(matchResult);
    await Future.delayed(const Duration(milliseconds: 50));

    // Verify state is still null (cancelled)
    expect(container.read(matchControllerProvider).value, isNull);

    await streamController.close();
  });
}
