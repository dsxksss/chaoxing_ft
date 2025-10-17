import 'package:json_annotation/json_annotation.dart';

part 'document.g.dart';

/// Document entity representing a document learning task
@JsonSerializable()
class Document {

  const Document({
    required this.id,
    required this.name,
    this.description,
    this.url,
    this.content,
    this.thumbnail,
    this.pageCount,
    this.currentPage,
    this.progress,
    this.isCompleted = false,
    this.isReading = false,
    this.format,
    this.tags,
    this.metadata,
    this.lastRead,
    this.createdAt,
    this.updatedAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) => _$DocumentFromJson(json);
  final String id;
  final String name;
  final String? description;
  final String? url;
  final String? content;
  final String? thumbnail;
  final int? pageCount;
  final int? currentPage;
  final double? progress;
  final bool isCompleted;
  final bool isReading;
  final String? format;
  final List<String>? tags;
  final Map<String, String>? metadata;
  final DateTime? lastRead;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  Map<String, dynamic> toJson() => _$DocumentToJson(this);

  Document copyWith({
    String? id,
    String? name,
    String? description,
    String? url,
    String? content,
    String? thumbnail,
    int? pageCount,
    int? currentPage,
    double? progress,
    bool? isCompleted,
    bool? isReading,
    String? format,
    List<String>? tags,
    Map<String, String>? metadata,
    DateTime? lastRead,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Document(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      url: url ?? this.url,
      content: content ?? this.content,
      thumbnail: thumbnail ?? this.thumbnail,
      pageCount: pageCount ?? this.pageCount,
      currentPage: currentPage ?? this.currentPage,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      isReading: isReading ?? this.isReading,
      format: format ?? this.format,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      lastRead: lastRead ?? this.lastRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if document is fully read
  bool get isFullyRead => progress != null && progress! >= 1.0;

  /// Check if document is partially read
  bool get isPartiallyRead => progress != null && progress! > 0.0 && progress! < 1.0;

  /// Check if document is not started
  bool get isNotStarted => progress == null || progress! == 0.0;

  /// Get remaining pages
  int? get remainingPages {
    if (pageCount == null || currentPage == null) return null;
    return pageCount! - currentPage!;
  }

  /// Get progress percentage
  int get progressPercentage {
    if (progress == null) return 0;
    return (progress! * 100).round();
  }

  /// Get formatted page info
  String get formattedPageInfo {
    if (pageCount == null) return '未知页数';
    if (currentPage == null) return '共 $pageCount 页';
    return '第 $currentPage 页 / 共 $pageCount 页';
  }

  /// Get formatted progress
  String get formattedProgress {
    if (progress == null) return '0%';
    return '$progressPercentage%';
  }

  /// Get document format icon
  String get formatIcon {
    switch (format?.toLowerCase()) {
      case 'pdf':
        return '📄';
      case 'doc':
      case 'docx':
        return '📝';
      case 'ppt':
      case 'pptx':
        return '📊';
      case 'xls':
      case 'xlsx':
        return '📈';
      case 'txt':
        return '📃';
      case 'html':
        return '🌐';
      case 'md':
        return '📋';
      default:
        return '📄';
    }
  }

  /// Get document format name
  String get formatName {
    switch (format?.toLowerCase()) {
      case 'pdf':
        return 'PDF';
      case 'doc':
      case 'docx':
        return 'Word';
      case 'ppt':
      case 'pptx':
        return 'PowerPoint';
      case 'xls':
      case 'xlsx':
        return 'Excel';
      case 'txt':
        return 'Text';
      case 'html':
        return 'HTML';
      case 'md':
        return 'Markdown';
      default:
        return 'Document';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Document && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Document(id: $id, name: $name, progress: $progress)';
  }
}
