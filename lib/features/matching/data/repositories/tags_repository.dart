import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tagsRepositoryProvider = Provider((ref) {
  return TagsRepository(Supabase.instance.client);
});

class TagsRepository {
  final SupabaseClient _supabase;

  TagsRepository(this._supabase);

  // Get top N popular tags
  Future<List<String>> getPopularTags({int limit = 20}) async {
    try {
      final response = await _supabase
          .from('tags')
          .select('name')
          .order('usage_count', ascending: false)
          .limit(limit);
          
      return (response as List).map((row) => row['name'] as String).toList();
    } catch (e) {
      print('Error fetching popular tags: $e');
      return [];
    }
  }

  // Search tags by prefix
  Future<List<String>> searchTags(String query, {int limit = 10}) async {
    try {
      final response = await _supabase
          .from('tags')
          .select('name')
          .ilike('name', '%$query%')
          .order('usage_count', ascending: false)
          .limit(limit);
          
      return (response as List).map((row) => row['name'] as String).toList();
    } catch (e) {
      print('Error searching tags: $e');
      return [];
    }
  }
}
