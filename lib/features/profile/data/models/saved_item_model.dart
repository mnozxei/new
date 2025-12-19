import '../../domain/entities/saved_item_entity.dart';

class SavedItemModel extends SavedItemEntity {
  const SavedItemModel({
    required super.id,
    required super.userId,
    required super.itemType,
    required super.itemId,
    super.notes,
    required super.createdAt,
    super.item,
  });

  factory SavedItemModel.fromJson(Map<String, dynamic> json) {
    return SavedItemModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      itemType: SavedItemType.fromString(json['item_type'] as String),
      itemId: json['item_id'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      // Item data is loaded separately based on type
      item: json['item'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'item_type': itemType.value,
      'item_id': itemId,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create a SavedItemModel from entity
  factory SavedItemModel.fromEntity(SavedItemEntity entity) {
    return SavedItemModel(
      id: entity.id,
      userId: entity.userId,
      itemType: entity.itemType,
      itemId: entity.itemId,
      notes: entity.notes,
      createdAt: entity.createdAt,
      item: entity.item,
    );
  }
}
