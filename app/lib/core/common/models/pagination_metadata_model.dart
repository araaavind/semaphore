import 'dart:convert';

import 'package:app/core/common/entities/pagination_metadata.dart';

class PaginationMetadataModel extends PaginationMetadata {
  const PaginationMetadataModel({
    required super.currentPage,
    required super.pageSize,
    required super.firstPage,
    required super.lastPage,
    required super.totalRecords,
  });

  PaginationMetadataModel copyWith({
    int? currentPage,
    int? pageSize,
    int? firstPage,
    int? lastPage,
    int? totalRecords,
  }) {
    return PaginationMetadataModel(
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      firstPage: firstPage ?? this.firstPage,
      lastPage: lastPage ?? this.lastPage,
      totalRecords: totalRecords ?? this.totalRecords,
    );
  }

  factory PaginationMetadataModel.fromMap(Map<String, dynamic> map) {
    return PaginationMetadataModel(
      currentPage: map['current_page'] as int,
      pageSize: map['page_size'] as int,
      firstPage: map['first_page'] as int,
      lastPage: map['last_page'] as int,
      totalRecords: map['total_records'] as int,
    );
  }

  factory PaginationMetadataModel.fromJson(String source) =>
      PaginationMetadataModel.fromMap(
          json.decode(source) as Map<String, dynamic>);
}
