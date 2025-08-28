// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatModel _$ChatModelFromJson(Map<String, dynamic> json) => ChatModel(
  isGroup: json['is_group'] as bool,
  membersIds: (json['members'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  lastMessage: json['last_message'] == null
      ? null
      : MessageModel.fromJson(json['last_message'] as Map<String, dynamic>),
  createdAt: const TimestampToDateTimeConverter().fromJson(
    json['created_at'] as Timestamp,
  ),
  lastActive: const TimestampToDateTimeConverter().fromJson(
    json['last_active'] as Timestamp,
  ),
  imageUrl: json['image_url'] as String?,
);

Map<String, dynamic> _$ChatModelToJson(ChatModel instance) => <String, dynamic>{
  'is_group': instance.isGroup,
  'members': instance.membersIds,
  'last_message': instance.lastMessage,
  'image_url': instance.imageUrl,
  'created_at': const TimestampToDateTimeConverter().toJson(instance.createdAt),
  'last_active': const TimestampToDateTimeConverter().toJson(
    instance.lastActive,
  ),
};
