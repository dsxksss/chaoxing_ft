import '../../domain/entities/document.dart';
import '../../domain/repositories/document_repository.dart';
import '../../core/errors/error_handler.dart';

/// Document service
class DocumentService {

  DocumentService(this._documentRepository, this._errorHandler);
  final DocumentRepository _documentRepository;
  final ErrorHandler _errorHandler;

  /// Get document by ID
  Future<Document?> getDocumentById(String documentId) async {
    try {
      if (documentId.isEmpty) {
        throw _errorHandler.createDataParsingError('Document ID cannot be empty');
      }

      _errorHandler.logInfo('Fetching document: $documentId');
      final document = await _documentRepository.getDocumentById(documentId);
      
      if (document != null) {
        _errorHandler.logInfo('Document found: ${document.name}');
      } else {
        _errorHandler.logWarning('Document not found: $documentId');
      }
      
      return document;
    } catch (e) {
      _errorHandler.handleError(e, context: 'DocumentService.getDocumentById');
      return null;
    }
  }

  /// Get documents by course ID
  Future<List<Document>> getDocumentsByCourseId(String courseId) async {
    try {
      if (courseId.isEmpty) {
        throw _errorHandler.createDataParsingError('Course ID cannot be empty');
      }

      _errorHandler.logInfo('Fetching documents for course: $courseId');
      final documents = await _documentRepository.getDocumentsByCourseId(courseId);
      _errorHandler.logInfo('Retrieved ${documents.length} documents');
      return documents;
    } catch (e) {
      _errorHandler.handleError(e, context: 'DocumentService.getDocumentsByCourseId');
      return [];
    }
  }

  /// Get documents by chapter ID
  Future<List<Document>> getDocumentsByChapterId(String chapterId) async {
    try {
      if (chapterId.isEmpty) {
        throw _errorHandler.createDataParsingError('Chapter ID cannot be empty');
      }

      _errorHandler.logInfo('Fetching documents for chapter: $chapterId');
      final documents = await _documentRepository.getDocumentsByChapterId(chapterId);
      _errorHandler.logInfo('Retrieved ${documents.length} documents');
      return documents;
    } catch (e) {
      _errorHandler.handleError(e, context: 'DocumentService.getDocumentsByChapterId');
      return [];
    }
  }

  /// Get documents by format
  Future<List<Document>> getDocumentsByFormat(String format) async {
    try {
      if (format.isEmpty) {
        throw _errorHandler.createDataParsingError('Format cannot be empty');
      }

      _errorHandler.logInfo('Fetching documents by format: $format');
      final documents = await _documentRepository.getDocumentsByFormat(format);
      _errorHandler.logInfo('Retrieved ${documents.length} documents');
      return documents;
    } catch (e) {
      _errorHandler.handleError(e, context: 'DocumentService.getDocumentsByFormat');
      return [];
    }
  }

  /// Update document progress
  Future<void> updateDocumentProgress(String documentId, int currentPage, double progress) async {
    try {
      if (documentId.isEmpty) {
        throw _errorHandler.createDataParsingError('Document ID cannot be empty');
      }

      if (currentPage < 0) {
        throw _errorHandler.createDataParsingError('Current page cannot be negative');
      }

      if (progress < 0.0 || progress > 1.0) {
        throw _errorHandler.createDataParsingError('Progress must be between 0.0 and 1.0');
      }

      _errorHandler.logInfo('Updating progress for document $documentId: page $currentPage, progress $progress');
      await _documentRepository.updateDocumentProgress(documentId, currentPage, progress);
      _errorHandler.logInfo('Document progress updated successfully');
    } catch (e) {
      _errorHandler.handleError(e, context: 'DocumentService.updateDocumentProgress');
      rethrow;
    }
  }

  /// Mark document as completed
  Future<void> markDocumentAsCompleted(String documentId) async {
    try {
      if (documentId.isEmpty) {
        throw _errorHandler.createDataParsingError('Document ID cannot be empty');
      }

      _errorHandler.logInfo('Marking document as completed: $documentId');
      await _documentRepository.markDocumentAsCompleted(documentId);
      _errorHandler.logInfo('Document marked as completed');
    } catch (e) {
      _errorHandler.handleError(e, context: 'DocumentService.markDocumentAsCompleted');
      rethrow;
    }
  }

  /// Update document reading position
  Future<void> updateDocumentReadingPosition(String documentId, int page, int position) async {
    try {
      if (documentId.isEmpty) {
        throw _errorHandler.createDataParsingError('Document ID cannot be empty');
      }

      if (page < 0) {
        throw _errorHandler.createDataParsingError('Page cannot be negative');
      }

      if (position < 0) {
        throw _errorHandler.createDataParsingError('Position cannot be negative');
      }

      _errorHandler.logInfo('Updating reading position for document $documentId: page $page, position $position');
      await _documentRepository.updateDocumentReadingPosition(documentId, page, position);
      _errorHandler.logInfo('Document reading position updated successfully');
    } catch (e) {
      _errorHandler.handleError(e, context: 'DocumentService.updateDocumentReadingPosition');
      rethrow;
    }
  }

  /// Get document content
  Future<String?> getDocumentContent(String documentId) async {
    try {
      if (documentId.isEmpty) {
        throw _errorHandler.createDataParsingError('Document ID cannot be empty');
      }

      _errorHandler.logInfo('Fetching content for document: $documentId');
      final content = await _documentRepository.getDocumentContent(documentId);
      _errorHandler.logInfo('Document content retrieved');
      return content;
    } catch (e) {
      _errorHandler.handleError(e, context: 'DocumentService.getDocumentContent');
      return null;
    }
  }

  /// Save document content
  Future<void> saveDocumentContent(String documentId, String content) async {
    try {
      if (documentId.isEmpty) {
        throw _errorHandler.createDataParsingError('Document ID cannot be empty');
      }

      if (content.isEmpty) {
        throw _errorHandler.createDataParsingError('Content cannot be empty');
      }

      _errorHandler.logInfo('Saving content for document: $documentId');
      await _documentRepository.saveDocumentContent(documentId, content);
      _errorHandler.logInfo('Document content saved successfully');
    } catch (e) {
      _errorHandler.handleError(e, context: 'DocumentService.saveDocumentContent');
      rethrow;
    }
  }

  /// Get document metadata
  Future<Map<String, dynamic>> getDocumentMetadata(String documentId) async {
    try {
      if (documentId.isEmpty) {
        throw _errorHandler.createDataParsingError('Document ID cannot be empty');
      }

      _errorHandler.logInfo('Fetching metadata for document: $documentId');
      final metadata = await _documentRepository.getDocumentMetadata(documentId);
      _errorHandler.logInfo('Document metadata retrieved');
      return metadata;
    } catch (e) {
      _errorHandler.handleError(e, context: 'DocumentService.getDocumentMetadata');
      return {};
    }
  }

  /// Update document metadata
  Future<void> updateDocumentMetadata(String documentId, Map<String, dynamic> metadata) async {
    try {
      if (documentId.isEmpty) {
        throw _errorHandler.createDataParsingError('Document ID cannot be empty');
      }

      _errorHandler.logInfo('Updating metadata for document: $documentId');
      await _documentRepository.updateDocumentMetadata(documentId, metadata);
      _errorHandler.logInfo('Document metadata updated successfully');
    } catch (e) {
      _errorHandler.handleError(e, context: 'DocumentService.updateDocumentMetadata');
      rethrow;
    }
  }

  /// Get document reading history
  Future<List<Map<String, dynamic>>> getDocumentReadingHistory(String documentId) async {
    try {
      if (documentId.isEmpty) {
        throw _errorHandler.createDataParsingError('Document ID cannot be empty');
      }

      _errorHandler.logInfo('Fetching reading history for document: $documentId');
      final history = await _documentRepository.getDocumentReadingHistory(documentId);
      _errorHandler.logInfo('Retrieved ${history.length} reading records');
      return history;
    } catch (e) {
      _errorHandler.handleError(e, context: 'DocumentService.getDocumentReadingHistory');
      return [];
    }
  }

  /// Add document reading record
  Future<void> addDocumentReadingRecord(String documentId, int page, int position, Duration readingTime) async {
    try {
      if (documentId.isEmpty) {
        throw _errorHandler.createDataParsingError('Document ID cannot be empty');
      }

      if (page < 0) {
        throw _errorHandler.createDataParsingError('Page cannot be negative');
      }

      if (position < 0) {
        throw _errorHandler.createDataParsingError('Position cannot be negative');
      }

      _errorHandler.logInfo('Adding reading record for document: $documentId');
      await _documentRepository.addDocumentReadingRecord(documentId, page, position, readingTime);
      _errorHandler.logInfo('Document reading record added successfully');
    } catch (e) {
      _errorHandler.handleError(e, context: 'DocumentService.addDocumentReadingRecord');
      rethrow;
    }
  }

  /// Get document statistics
  Future<Map<String, dynamic>> getDocumentStatistics(String documentId) async {
    try {
      if (documentId.isEmpty) {
        throw _errorHandler.createDataParsingError('Document ID cannot be empty');
      }

      _errorHandler.logInfo('Fetching statistics for document: $documentId');
      final statistics = await _documentRepository.getDocumentStatistics(documentId);
      _errorHandler.logInfo('Document statistics retrieved');
      return statistics;
    } catch (e) {
      _errorHandler.handleError(e, context: 'DocumentService.getDocumentStatistics');
      return {};
    }
  }

  /// Search documents
  Future<List<Document>> searchDocuments(String query, {String? courseId, String? chapterId}) async {
    try {
      if (query.isEmpty) {
        throw _errorHandler.createDataParsingError('Search query cannot be empty');
      }

      _errorHandler.logInfo('Searching documents with query: $query');
      final documents = await _documentRepository.searchDocuments(query, courseId: courseId, chapterId: chapterId);
      _errorHandler.logInfo('Found ${documents.length} documents');
      return documents;
    } catch (e) {
      _errorHandler.handleError(e, context: 'DocumentService.searchDocuments');
      return [];
    }
  }

  /// Get document bookmarks
  Future<List<Map<String, dynamic>>> getDocumentBookmarks(String documentId) async {
    try {
      if (documentId.isEmpty) {
        throw _errorHandler.createDataParsingError('Document ID cannot be empty');
      }

      _errorHandler.logInfo('Fetching bookmarks for document: $documentId');
      final bookmarks = await _documentRepository.getDocumentBookmarks(documentId);
      _errorHandler.logInfo('Retrieved ${bookmarks.length} bookmarks');
      return bookmarks;
    } catch (e) {
      _errorHandler.handleError(e, context: 'DocumentService.getDocumentBookmarks');
      return [];
    }
  }

  /// Add document bookmark
  Future<void> addDocumentBookmark(String documentId, int page, String note) async {
    try {
      if (documentId.isEmpty) {
        throw _errorHandler.createDataParsingError('Document ID cannot be empty');
      }

      if (page < 0) {
        throw _errorHandler.createDataParsingError('Page cannot be negative');
      }

      _errorHandler.logInfo('Adding bookmark for document: $documentId');
      await _documentRepository.addDocumentBookmark(documentId, page, note);
      _errorHandler.logInfo('Document bookmark added successfully');
    } catch (e) {
      _errorHandler.handleError(e, context: 'DocumentService.addDocumentBookmark');
      rethrow;
    }
  }

  /// Remove document bookmark
  Future<void> removeDocumentBookmark(String documentId, String bookmarkId) async {
    try {
      if (documentId.isEmpty) {
        throw _errorHandler.createDataParsingError('Document ID cannot be empty');
      }

      if (bookmarkId.isEmpty) {
        throw _errorHandler.createDataParsingError('Bookmark ID cannot be empty');
      }

      _errorHandler.logInfo('Removing bookmark for document: $documentId');
      await _documentRepository.removeDocumentBookmark(documentId, bookmarkId);
      _errorHandler.logInfo('Document bookmark removed successfully');
    } catch (e) {
      _errorHandler.handleError(e, context: 'DocumentService.removeDocumentBookmark');
      rethrow;
    }
  }

  /// Get document annotations
  Future<List<Map<String, dynamic>>> getDocumentAnnotations(String documentId) async {
    try {
      if (documentId.isEmpty) {
        throw _errorHandler.createDataParsingError('Document ID cannot be empty');
      }

      _errorHandler.logInfo('Fetching annotations for document: $documentId');
      final annotations = await _documentRepository.getDocumentAnnotations(documentId);
      _errorHandler.logInfo('Retrieved ${annotations.length} annotations');
      return annotations;
    } catch (e) {
      _errorHandler.handleError(e, context: 'DocumentService.getDocumentAnnotations');
      return [];
    }
  }

  /// Add document annotation
  Future<void> addDocumentAnnotation(String documentId, int page, String annotation) async {
    try {
      if (documentId.isEmpty) {
        throw _errorHandler.createDataParsingError('Document ID cannot be empty');
      }

      if (page < 0) {
        throw _errorHandler.createDataParsingError('Page cannot be negative');
      }

      if (annotation.isEmpty) {
        throw _errorHandler.createDataParsingError('Annotation cannot be empty');
      }

      _errorHandler.logInfo('Adding annotation for document: $documentId');
      await _documentRepository.addDocumentAnnotation(documentId, page, annotation);
      _errorHandler.logInfo('Document annotation added successfully');
    } catch (e) {
      _errorHandler.handleError(e, context: 'DocumentService.addDocumentAnnotation');
      rethrow;
    }
  }

  /// Remove document annotation
  Future<void> removeDocumentAnnotation(String documentId, String annotationId) async {
    try {
      if (documentId.isEmpty) {
        throw _errorHandler.createDataParsingError('Document ID cannot be empty');
      }

      if (annotationId.isEmpty) {
        throw _errorHandler.createDataParsingError('Annotation ID cannot be empty');
      }

      _errorHandler.logInfo('Removing annotation for document: $documentId');
      await _documentRepository.removeDocumentAnnotation(documentId, annotationId);
      _errorHandler.logInfo('Document annotation removed successfully');
    } catch (e) {
      _errorHandler.handleError(e, context: 'DocumentService.removeDocumentAnnotation');
      rethrow;
    }
  }

  /// Refresh document data
  Future<void> refreshDocumentData(String documentId) async {
    try {
      if (documentId.isEmpty) {
        throw _errorHandler.createDataParsingError('Document ID cannot be empty');
      }

      _errorHandler.logInfo('Refreshing data for document: $documentId');
      await _documentRepository.refreshDocumentData(documentId);
      _errorHandler.logInfo('Document data refreshed successfully');
    } catch (e) {
      _errorHandler.handleError(e, context: 'DocumentService.refreshDocumentData');
      rethrow;
    }
  }

  /// Clear document cache
  Future<void> clearDocumentCache(String documentId) async {
    try {
      if (documentId.isEmpty) {
        throw _errorHandler.createDataParsingError('Document ID cannot be empty');
      }

      _errorHandler.logInfo('Clearing cache for document: $documentId');
      await _documentRepository.clearDocumentCache(documentId);
      _errorHandler.logInfo('Document cache cleared');
    } catch (e) {
      _errorHandler.handleError(e, context: 'DocumentService.clearDocumentCache');
      rethrow;
    }
  }

  /// Download document
  Future<String?> downloadDocument(String documentId) async {
    try {
      if (documentId.isEmpty) {
        throw _errorHandler.createDataParsingError('Document ID cannot be empty');
      }

      _errorHandler.logInfo('Downloading document: $documentId');
      final path = await _documentRepository.downloadDocument(documentId);
      _errorHandler.logInfo('Document downloaded successfully');
      return path;
    } catch (e) {
      _errorHandler.handleError(e, context: 'DocumentService.downloadDocument');
      return null;
    }
  }

  /// Check document availability
  Future<bool> isDocumentAvailable(String documentId) async {
    try {
      if (documentId.isEmpty) {
        throw _errorHandler.createDataParsingError('Document ID cannot be empty');
      }

      _errorHandler.logInfo('Checking availability for document: $documentId');
      final isAvailable = await _documentRepository.isDocumentAvailable(documentId);
      _errorHandler.logInfo('Document availability: $isAvailable');
      return isAvailable;
    } catch (e) {
      _errorHandler.handleError(e, context: 'DocumentService.isDocumentAvailable');
      return false;
    }
  }

  /// Get document size
  Future<int?> getDocumentSize(String documentId) async {
    try {
      if (documentId.isEmpty) {
        throw _errorHandler.createDataParsingError('Document ID cannot be empty');
      }

      _errorHandler.logInfo('Getting size for document: $documentId');
      final size = await _documentRepository.getDocumentSize(documentId);
      _errorHandler.logInfo('Document size: $size bytes');
      return size;
    } catch (e) {
      _errorHandler.handleError(e, context: 'DocumentService.getDocumentSize');
      return null;
    }
  }

  /// Get document last modified
  Future<DateTime?> getDocumentLastModified(String documentId) async {
    try {
      if (documentId.isEmpty) {
        throw _errorHandler.createDataParsingError('Document ID cannot be empty');
      }

      _errorHandler.logInfo('Getting last modified for document: $documentId');
      final lastModified = await _documentRepository.getDocumentLastModified(documentId);
      _errorHandler.logInfo('Document last modified: $lastModified');
      return lastModified;
    } catch (e) {
      _errorHandler.handleError(e, context: 'DocumentService.getDocumentLastModified');
      return null;
    }
  }

  /// Get user-friendly error message
  String getUserFriendlyErrorMessage(dynamic error) {
    return _errorHandler.getUserFriendlyMessage(error);
  }
}
