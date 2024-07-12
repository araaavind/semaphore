import 'dart:convert';

import 'package:smphr_sdk/smphr_sdk.dart';

class ErrorResponseModel extends ErrorResponse {
  ErrorResponseModel(super.message, {super.fieldErrors});

  ErrorResponseModel copyWith({
    String? message,
    Map<String, String>? fieldErrors,
  }) {
    return ErrorResponseModel(
      message ?? this.message,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'message': message,
      'field_errors': fieldErrors,
    };
  }

  factory ErrorResponseModel.fromMap(Map<String, dynamic> map) {
    return ErrorResponseModel(
      map['message'] as String,
      fieldErrors: map['field_errors'] != null
          ? Map<String, String>.from(
              (map['field_errors'] as Map<String, String>),
            )
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ErrorResponseModel.fromJson(String source) =>
      ErrorResponseModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'ErrorResponseModel(message: $message, fieldErrors: $fieldErrors)';
}
