import 'package:equatable/equatable.dart';

class PaginationMetadata extends Equatable {
  final int currentPage;
  final int pageSize;
  final int firstPage;
  final int lastPage;
  final int totalRecords;

  const PaginationMetadata({
    required this.currentPage,
    required this.pageSize,
    required this.firstPage,
    required this.lastPage,
    required this.totalRecords,
  });

  @override
  List<Object> get props => [
        currentPage,
        pageSize,
        firstPage,
        lastPage,
        totalRecords,
      ];
}
