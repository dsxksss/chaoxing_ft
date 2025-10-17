import '../entities/document.dart';

/// Document repository interface
abstract class DocumentRepository {
  /// Get document by ID
  Future<Document?> getDocumentById(String documentId);

  /// Get documents by course ID
  Future<List<Document>> getDocumentsByCourseId(String courseId);

  /// Get documents by chapter ID
  Future<List<Document>> getDocumentsByChapterId(String chapterId);

  /// Get documents by format
  Future<List<Document>> getDocumentsByFormat(String format);

  /// Update document progress
  Future<void> updateDocumentProgress(String documentId, int currentPage, double progress);

  /// Mark document as completed
  Future<void> markDocumentAsCompleted(String documentId);

  /// Update document reading position
  Future<void> updateDocumentReadingPosition(String documentId, int page, int position);

  /// Get document content
  Future<String?> getDocumentContent(String documentId);

  /// Save document content
  Future<void> saveDocumentContent(String documentId, String content);

  /// Get document metadata
  Future<Map<String, dynamic>> getDocumentMetadata(String documentId);

  /// Update document metadata
  Future<void> updateDocumentMetadata(String documentId, Map<String, dynamic> metadata);

  /// Get document reading history
  Future<List<Map<String, dynamic>>> getDocumentReadingHistory(String documentId);

  /// Add document reading record
  Future<void> addDocumentReadingRecord(String documentId, int page, int position, Duration readingTime);

  /// Get document statistics
  Future<Map<String, dynamic>> getDocumentStatistics(String documentId);

  /// Search documents
  Future<List<Document>> searchDocuments(String query, {String? courseId, String? chapterId});

  /// Get document bookmarks
  Future<List<Map<String, dynamic>>> getDocumentBookmarks(String documentId);

  /// Add document bookmark
  Future<void> addDocumentBookmark(String documentId, int page, String note);

  /// Remove document bookmark
  Future<void> removeDocumentBookmark(String documentId, String bookmarkId);

  /// Get document annotations
  Future<List<Map<String, dynamic>>> getDocumentAnnotations(String documentId);

  /// Add document annotation
  Future<void> addDocumentAnnotation(String documentId, int page, String annotation);

  /// Remove document annotation
  Future<void> removeDocumentAnnotation(String documentId, String annotationId);

  /// Refresh document data
  Future<void> refreshDocumentData(String documentId);

  /// Clear document cache
  Future<void> clearDocumentCache(String documentId);

  /// Download document
  Future<String?> downloadDocument(String documentId);

  /// Check document availability
  Future<bool> isDocumentAvailable(String documentId);

  /// Get document size
  Future<int?> getDocumentSize(String documentId);

  /// Get document last modified
  Future<DateTime?> getDocumentLastModified(String documentId);
}
