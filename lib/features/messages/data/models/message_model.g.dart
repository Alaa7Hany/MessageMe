// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) => MessageModel(
  tempId: json['temp_id'] as String?,
  senderUid: json['sender_uid'] as String,
  senderName: json['sender_name'] as String,
  senderImage: json['sender_image'] as String,
  content: json['content'] as String,
  type: json['type'] as String,
  timeSent: const TimestampToDateTimeConverter().fromJson(json['time_sent']),
  reactions:
      (json['reactions'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      {},
  readBy:
      (json['read_by'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, DateTime.parse(e as String)),
      ) ??
      {},
);

Map<String, dynamic> _$MessageModelToJson(
  MessageModel instance,
) => <String, dynamic>{
  'sender_uid': instance.senderUid,
  'temp_id': instance.tempId,
  'sender_name': instance.senderName,
  'sender_image': instance.senderImage,
  'content': instance.content,
  'type': instance.type,
  'time_sent': const TimestampToDateTimeConverter().toJson(instance.timeSent),
  'reactions': instance.reactions,
  'read_by': instance.readBy.map((k, e) => MapEntry(k, e.toIso8601String())),
};
