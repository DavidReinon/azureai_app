enum OcrServiceStatus {
  notStarted,
  failed,
  running,
  succeeded,
}

extension OcrServiceStatusExtension on OcrServiceStatus {
  static OcrServiceStatus fromString(String status) {
    switch (status) {
      case 'notStarted':
        return OcrServiceStatus.notStarted;
      case 'running':
        return OcrServiceStatus.running;
      case 'succeeded':
        return OcrServiceStatus.succeeded;
      case 'failed':
        return OcrServiceStatus.failed;
      default:
        throw Exception('Invalid status: $status');
    }
  }
}
