import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/saved_item_entity.dart';
import '../../domain/repositories/saved_items_repository.dart';
import '../models/saved_item_model.dart';

class SavedItemsRepositoryImpl implements SavedItemsRepository {
  SavedItemsRepositoryImpl({required this.supabaseClient});

  final SupabaseClient supabaseClient;

  @override
  Future<List<SavedItemEntity>> getSavedItems(String userId) async {
    final response = await supabaseClient
        .from('saved_items')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => SavedItemModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<SavedItemEntity>> getSavedItemsByType(
    String userId,
    SavedItemType type,
  ) async {
    final response = await supabaseClient
        .from('saved_items')
        .select()
        .eq('user_id', userId)
        .eq('item_type', type.value)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => SavedItemModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<bool> isItemSaved(
    String userId,
    SavedItemType type,
    String itemId,
  ) async {
    final response = await supabaseClient
        .from('saved_items')
        .select('id')
        .eq('user_id', userId)
        .eq('item_type', type.value)
        .eq('item_id', itemId)
        .maybeSingle();

    return response != null;
  }

  @override
  Future<SavedItemEntity> saveItem({
    required String userId,
    required SavedItemType type,
    required String itemId,
    String? notes,
  }) async {
    final response = await supabaseClient.from('saved_items').insert({
      'user_id': userId,
      'item_type': type.value,
      'item_id': itemId,
      'notes': notes,
    }).select().single();

    return SavedItemModel.fromJson(response);
  }

  @override
  Future<void> removeSavedItem(String savedItemId) async {
    await supabaseClient.from('saved_items').delete().eq('id', savedItemId);
  }

  @override
  Future<void> removeSavedItemByTypeAndId(
    String userId,
    SavedItemType type,
    String itemId,
  ) async {
    await supabaseClient
        .from('saved_items')
        .delete()
        .eq('user_id', userId)
        .eq('item_type', type.value)
        .eq('item_id', itemId);
  }

  @override
  Future<SavedItemEntity> updateSavedItemNotes(
    String savedItemId,
    String? notes,
  ) async {
    final response = await supabaseClient
        .from('saved_items')
        .update({'notes': notes})
        .eq('id', savedItemId)
        .select()
        .single();

    return SavedItemModel.fromJson(response);
  }

  @override
  Future<Map<SavedItemType, int>> getSavedItemsCount(String userId) async {
    final counts = <SavedItemType, int>{};

    for (final type in SavedItemType.values) {
      final response = await supabaseClient
          .from('saved_items')
          .select('id')
          .eq('user_id', userId)
          .eq('item_type', type.value);

      counts[type] = (response as List).length;
    }

    return counts;
  }
}
