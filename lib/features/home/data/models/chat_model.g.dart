// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatModel _$ChatModelFromJson(Map<String, dynamic> json) => ChatModel(
  name: json['name'] as String?,
  isGroup: json['is_group'] as bool,
  membersIds: (json['members'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  createdAt: const TimestampToDateTimeConverter().fromJson(json['created_at']),
  lastActive: const TimestampToDateTimeConverter().fromJson(
    json['last_active'],
  ),
  imageUrl: json['image_url'] as String?,
  lastMessageContent: json['last_message_content'] as String?,
  lastMessageType: json['last_message_type'] as String?,
  unreadCounts:
      (json['unread_counts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
);

Map<String, dynamic> _$ChatModelToJson(ChatModel instance) => <String, dynamic>{
  'name': instance.name,
  'is_group': instance.isGroup,
  'members': instance.membersIds,
  'last_message_content': instance.lastMessageContent,
  'last_message_type': instance.lastMessageType,
  'image_url': instance.imageUrl,
  'created_at': const TimestampToDateTimeConverter().toJson(instance.createdAt),
  'last_active': const TimestampToDateTimeConverter().toJson(
    instance.lastActive,
  ),
  'unread_counts': instance.unreadCounts,
};
