// ignore_for_file: non_constant_identifier_names, file_names

import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final getData = GetStorage();

// Helper function to convert Timestamp objects to strings recursively
dynamic _convertTimestampsToStrings(dynamic data) {
  if (data is Timestamp) {
    return data.toDate().toIso8601String();
  } else if (data is Map<String, dynamic>) {
    Map<String, dynamic> converted = {};
    data.forEach((key, value) {
      converted[key] = _convertTimestampsToStrings(value);
    });
    return converted;
  } else if (data is List) {
    return data.map((item) => _convertTimestampsToStrings(item)).toList();
  } else {
    return data;
  }
}

save(Key, val) {
  final data = GetStorage();
  // Convert any Timestamp objects to strings before saving
  dynamic convertedVal = _convertTimestampsToStrings(val);
  data.write(Key, convertedVal);
}
