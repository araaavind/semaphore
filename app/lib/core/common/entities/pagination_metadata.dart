class PaginationMetadata {
  final int currentPage;
  final int pageSize;
  final int firstPage;
  final int lastPage;
  final int totalRecords;

  PaginationMetadata({
    required this.currentPage,
    required this.pageSize,
    required this.firstPage,
    required this.lastPage,
    required this.totalRecords,
  });
}
