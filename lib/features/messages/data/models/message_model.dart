import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../../../core/firebase/firebase_keys.dart';

import '../../../../core/helpers/time_stamp_convertor.dart';

part 'message_model.g.dart';

enum MessageStatus { sending, sent, failed }

@JsonSerializable()
class MessageModel {
  @JsonKey(name: FirebaseKeys.senderUid)
  final String senderUid;

  @JsonKey(name: FirebaseKeys.tempId)
  final String? tempId;

  @JsonKey(name: FirebaseKeys.senderName)
  final String senderName;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? uid;

  @JsonKey(name: FirebaseKeys.senderImage)
  final String senderImage;

  @JsonKey(name: FirebaseKeys.content)
  final String content;

  @JsonKey(name: FirebaseKeys.type)
  final String type;

  @JsonKey(name: FirebaseKeys.timeSent)
  @TimestampToDateTimeConverter()
  final DateTime timeSent;
  @JsonKey(includeFromJson: false, includeToJson: false)
  MessageStatus status;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final DocumentSnapshot? rawDoc;

  @JsonKey(name: FirebaseKeys.reactions, defaultValue: {})
  final Map<String, String> reactions;

  MessageModel({
    this.uid,
    this.tempId,
    this.status = MessageStatus.sent,
    required this.senderUid,
    required this.senderName,
    required this.senderImage,
    required this.content,
    required this.type,
    required this.timeSent,
    this.rawDoc,
    this.reactions = const {},
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);

  factory MessageModel.fromSnapshot(DocumentSnapshot doc) {
    final json = doc.data() as Map<String, dynamic>;
    return MessageModel(
      uid: json[FirebaseKeys.uid],
      tempId: json[FirebaseKeys.tempId],
      senderUid: json[FirebaseKeys.senderUid],
      senderName: json[FirebaseKeys.senderName],
      senderImage: json[FirebaseKeys.senderImage],
      content: json[FirebaseKeys.content],
      type: json[FirebaseKeys.type],
      timeSent: const TimestampToDateTimeConverter().fromJson(
        json[FirebaseKeys.timeSent],
      ),
      reactions: Map<String, String>.from(json[FirebaseKeys.reactions] ?? {}),
      status: MessageStatus.sent,
      rawDoc: doc,
    );
  }

  MessageModel copyWith({
    String? uid,
    String? tempId,
    MessageStatus? status,
    String? content,
    Map<String, String>? reactions,
  }) {
    return MessageModel(
      uid: uid ?? this.uid,
      tempId: tempId ?? this.tempId,
      status: status ?? this.status,
      content: content ?? this.content,
      senderUid: senderUid,
      senderName: senderName,
      senderImage: senderImage,
      type: type,
      timeSent: timeSent,
      rawDoc: rawDoc,
      reactions: reactions ?? this.reactions,
    );
  }
}
