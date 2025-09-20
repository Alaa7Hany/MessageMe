// lib/features/messages/data/models/message_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../../../core/firebase/firebase_keys.dart';

import '../../../../core/helpers/time_stamp_convertor.dart';

part 'message_model.g.dart';

enum MessageStatus { sending, sent, failed }

enum MessageReadStatus { sent, delivered, read }

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

  @JsonKey(name: FirebaseKeys.readBy, defaultValue: {})
  final Map<String, DateTime> readBy;

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
    this.readBy = const {},
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);

  factory MessageModel.fromSnapshot(DocumentSnapshot doc) {
    final json = doc.data() as Map<String, dynamic>;
    final timeSentData = json[FirebaseKeys.timeSent];

    return MessageModel(
      uid: json[FirebaseKeys.uid],
      tempId: json[FirebaseKeys.tempId],
      senderUid: json[FirebaseKeys.senderUid],
      senderName: json[FirebaseKeys.senderName],
      senderImage: json[FirebaseKeys.senderImage],
      content: json[FirebaseKeys.content],
      type: json[FirebaseKeys.type],
      // Make the timeSent parsing more robust
      timeSent: timeSentData is Timestamp
          ? timeSentData.toDate()
          : DateTime.now(),
      reactions: Map<String, String>.from(json[FirebaseKeys.reactions] ?? {}),
      // Fix the unsafe cast for the readBy map
      readBy:
          (json[FirebaseKeys.readBy] as Map<String, dynamic>?)?.map((k, e) {
            final timestamp = e as Timestamp?;
            return MapEntry(k, timestamp?.toDate() ?? DateTime.now());
          }) ??
          {},
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
    Map<String, DateTime>? readBy,
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
      readBy: readBy ?? this.readBy,
    );
  }

  MessageReadStatus getReadStatus(String currentUserId, int memberCount) {
    if (readBy.length == memberCount - 1) {
      return MessageReadStatus.read;
    } else if (readBy.isNotEmpty) {
      return MessageReadStatus.delivered;
    }
    return MessageReadStatus.sent;
  }
}
