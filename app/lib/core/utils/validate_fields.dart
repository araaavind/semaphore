String? validateFields({
  required String jsonKey,
  Map<String, String>? fieldErrors,
}) {
  if (fieldErrors != null &&
      fieldErrors.isNotEmpty &&
      fieldErrors[jsonKey] != null) {
    return fieldErrors[jsonKey];
  }
  return null;
}
