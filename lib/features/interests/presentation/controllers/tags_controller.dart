import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blyp_app/features/matching/data/repositories/tags_repository.dart';

final popularTagsProvider = FutureProvider<List<String>>((ref) {
  final repository = ref.watch(tagsRepositoryProvider);
  return repository.getPopularTags();
});

final searchTagsQueryProvider = StateProvider<String>((ref) => '');

final searchedTagsProvider = FutureProvider<List<String>>((ref) async {
  final query = ref.watch(searchTagsQueryProvider);
  if (query.isEmpty) {
    return ref.watch(popularTagsProvider.future);
  }
  
  final repository = ref.watch(tagsRepositoryProvider);
  return repository.searchTags(query);
});
