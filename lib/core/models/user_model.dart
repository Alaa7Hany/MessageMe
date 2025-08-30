import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:message_me/core/firebase/firebase_keys.dart';

import '../helpers/time_stamp_convertor.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String uid;
  String name;
  final String email;

  @JsonKey(name: FirebaseKeys.nameToLowercase)
  final String nameToLowercase;

  @JsonKey(name: FirebaseKeys.imageUrl)
  String imageUrl;

  @JsonKey(name: FirebaseKeys.lastActive)
  @TimestampToDateTimeConverter()
  final DateTime lastActive;

  @JsonKey(name: FirebaseKeys.isOnline)
  final bool isOnline;

  UserModel({
    required this.uid,
    required this.name,
    required this.nameToLowercase,
    required this.email,
    required this.imageUrl,
    required this.lastActive,
    this.isOnline = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
