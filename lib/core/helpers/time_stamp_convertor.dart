import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// A reusable JsonConverter that converts Firestore `Timestamp` objects
/// to and from Dart `DateTime` objects.
class TimestampToDateTimeConverter
    implements JsonConverter<DateTime, Timestamp> {
  const TimestampToDateTimeConverter();

  @override
  DateTime fromJson(Timestamp timestamp) {
    return timestamp.toDate();
  }

  @override
  Timestamp toJson(DateTime date) {
    return Timestamp.fromDate(date);
  }
}
