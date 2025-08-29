// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) => MessageModel(
  senderUid: json['sender_uid'] as String,
  senderName: json['sender_name'] as String,
  senderImage: json['sender_image'] as String,
  content: json['content'] as String,
  type: json['type'] as String,
  timeSent: const TimestampToDateTimeConverter().fromJson(
    json['time_sent'] as Timestamp,
  ),
);

Map<String, dynamic> _$MessageModelToJson(
  MessageModel instance,
) => <String, dynamic>{
  'sender_uid': instance.senderUid,
  'sender_name': instance.senderName,
  'sender_image': instance.senderImage,
  'content': instance.content,
  'type': instance.type,
  'time_sent': const TimestampToDateTimeConverter().toJson(instance.timeSent),
};
