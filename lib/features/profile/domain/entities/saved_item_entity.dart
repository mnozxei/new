import 'package:equatable/equatable.dart';

/// Type of saved item
enum SavedItemType {
  post('post'),
  job('job'),
  course('course'),
  company('company');

  const SavedItemType(this.value);
  final String value;

  static SavedItemType fromString(String value) {
    return SavedItemType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SavedItemType.post,
    );
  }

  String get displayName {
    switch (this) {
      case SavedItemType.post:
        return 'منشور';
      case SavedItemType.job:
        return 'وظيفة';
      case SavedItemType.course:
        return 'دورة';
      case SavedItemType.company:
        return 'شركة';
    }
  }

  String get displayNameEn {
    switch (this) {
      case SavedItemType.post:
        return 'Post';
      case SavedItemType.job:
        return 'Job';
      case SavedItemType.course:
        return 'Course';
      case SavedItemType.company:
        return 'Company';
    }
  }
}

/// Saved item entity - represents a bookmarked item
class SavedItemEntity extends Equatable {
  const SavedItemEntity({
    required this.id,
    required this.userId,
    required this.itemType,
    required this.itemId,
    this.notes,
    required this.createdAt,
    this.item,
  });

  final String id;
  final String userId;
  final SavedItemType itemType;
  final String itemId;
  final String? notes;
  final DateTime createdAt;

  /// The actual item data (post, job, course, or company)
  final dynamic item;

  SavedItemEntity copyWith({
    String? id,
    String? userId,
    SavedItemType? itemType,
    String? itemId,
    String? notes,
    DateTime? createdAt,
    dynamic item,
  }) {
    return SavedItemEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      itemType: itemType ?? this.itemType,
      itemId: itemId ?? this.itemId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      item: item ?? this.item,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        itemType,
        itemId,
        notes,
        createdAt,
        item,
      ];
}

/// Helper class for saved item with specific type
class SavedPost extends SavedItemEntity {
  const SavedPost({
    required super.id,
    required super.userId,
    required super.itemId,
    super.notes,
    required super.createdAt,
    super.item,
  }) : super(itemType: SavedItemType.post);
}

class SavedJob extends SavedItemEntity {
  const SavedJob({
    required super.id,
    required super.userId,
    required super.itemId,
    super.notes,
    required super.createdAt,
    super.item,
  }) : super(itemType: SavedItemType.job);
}

class SavedCourse extends SavedItemEntity {
  const SavedCourse({
    required super.id,
    required super.userId,
    required super.itemId,
    super.notes,
    required super.createdAt,
    super.item,
  }) : super(itemType: SavedItemType.course);
}

class SavedCompany extends SavedItemEntity {
  const SavedCompany({
    required super.id,
    required super.userId,
    required super.itemId,
    super.notes,
    required super.createdAt,
    super.item,
  }) : super(itemType: SavedItemType.company);
}
