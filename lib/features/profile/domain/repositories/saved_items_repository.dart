import '../entities/saved_item_entity.dart';

/// Repository for saved items (bookmarks)
abstract class SavedItemsRepository {
  /// Get all saved items for a user
  Future<List<SavedItemEntity>> getSavedItems(String userId);

  /// Get saved items by type
  Future<List<SavedItemEntity>> getSavedItemsByType(
    String userId,
    SavedItemType type,
  );

  /// Check if an item is saved
  Future<bool> isItemSaved(String userId, SavedItemType type, String itemId);

  /// Save an item
  Future<SavedItemEntity> saveItem({
    required String userId,
    required SavedItemType type,
    required String itemId,
    String? notes,
  });

  /// Remove a saved item
  Future<void> removeSavedItem(String savedItemId);

  /// Remove a saved item by type and item ID
  Future<void> removeSavedItemByTypeAndId(
    String userId,
    SavedItemType type,
    String itemId,
  );

  /// Update saved item notes
  Future<SavedItemEntity> updateSavedItemNotes(
    String savedItemId,
    String? notes,
  );

  /// Get saved items count by type
  Future<Map<SavedItemType, int>> getSavedItemsCount(String userId);
}
