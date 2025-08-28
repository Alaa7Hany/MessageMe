import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:message_me/core/firebase/firebase_keys.dart';

import '../../../../core/helpers/time_stamp_convertor.dart';

part 'message_model.g.dart';

@JsonSerializable()
class MessageModel {
  @JsonKey(name: FirebaseKeys.senderUid)
  final String senderUid;

  @JsonKey(name: FirebaseKeys.senderName)
  final String senderName;

  @JsonKey(name: FirebaseKeys.senderImage)
  final String senderImage;

  @JsonKey(name: FirebaseKeys.content)
  final String content;

  @JsonKey(name: FirebaseKeys.type)
  final String type;

  @JsonKey(name: FirebaseKeys.timeSent)
  @TimestampToDateTimeConverter()
  final DateTime timeSent;

  MessageModel({
    required this.senderUid,
    required this.senderName,
    required this.senderImage,
    required this.content,
    required this.type,
    required this.timeSent,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);
}
