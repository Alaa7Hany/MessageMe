import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// A reusable JsonConverter that converts Firestore `Timestamp` objects
/// to and from Dart `DateTime` objects.
class TimestampToDateTimeConverter implements JsonConverter<DateTime, Object?> {
  const TimestampToDateTimeConverter();

  @override
  DateTime fromJson(Object? json) {
    // This code will now be reached correctly.
    // We add a type check for safety.
    if (json is Timestamp) {
      return json.toDate();
    }
    // If the value is null or not a Timestamp, return the current time as a fallback.
    return DateTime.now();
  }

  @override
  Object toJson(DateTime date) {
    // This part can remain the same.
    return Timestamp.fromDate(date);
  }
}
