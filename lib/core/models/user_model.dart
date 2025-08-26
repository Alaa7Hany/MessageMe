import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

import '../firebase/firebase_keys.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String uid;
  final String name;
  final String email;
  @JsonKey(name: FirebaseKeys.imageUrl)
  final String imageUrl;

  // We use a custom converter to handle Firestore's Timestamp
  @JsonKey(
    name: FirebaseKeys.lastActive,
    fromJson: _timestampFromEpoch,
    toJson: _timestampToEpoch,
  )
  final DateTime lastActive;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.lastActive,
  });

  // Factory constructor for creating a new UserModel instance from a map
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  // Method for converting a UserModel instance to a map
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

// Helper functions for Timestamp conversion
DateTime _timestampFromEpoch(Timestamp timestamp) => timestamp.toDate();
Timestamp _timestampToEpoch(DateTime dateTime) => Timestamp.fromDate(dateTime);
