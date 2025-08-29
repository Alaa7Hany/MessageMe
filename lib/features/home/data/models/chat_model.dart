import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:message_me/core/firebase/firebase_keys.dart';
import 'package:message_me/core/models/user_model.dart';

import '../../../../core/helpers/time_stamp_convertor.dart';

part 'chat_model.g.dart';

@JsonSerializable()
class ChatModel {
  @JsonKey(includeFromJson: false, includeToJson: false)
  String uid;

  @JsonKey(name: FirebaseKeys.isGroup)
  final bool isGroup;

  @JsonKey(name: FirebaseKeys.members)
  final List<String> membersIds;

  @JsonKey(includeFromJson: false, includeToJson: false)
  List<UserModel> membersModels;

  @JsonKey(name: FirebaseKeys.lastMessageContent)
  final String? lastMessageContent;

  @JsonKey(name: FirebaseKeys.lastMessageType)
  final String? lastMessageType;

  @JsonKey(name: FirebaseKeys.imageUrl)
  final String? imageUrl;

  @JsonKey(name: FirebaseKeys.createdAt)
  @TimestampToDateTimeConverter()
  final DateTime createdAt;

  @JsonKey(name: FirebaseKeys.lastActive)
  @TimestampToDateTimeConverter()
  final DateTime lastActive;

  ChatModel({
    this.uid = '',
    required this.isGroup,
    required this.membersIds,
    required this.createdAt,
    required this.lastActive,
    this.imageUrl,
    this.membersModels = const [],
    this.lastMessageContent,
    this.lastMessageType,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) =>
      _$ChatModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatModelToJson(this);
}
