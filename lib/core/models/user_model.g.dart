// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  uid: json['uid'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  imageUrl: json['image_url'] as String,
  lastActive: const TimestampToDateTimeConverter().fromJson(
    json['last_active'] as Timestamp,
  ),
  isOnline: json['is_online'] as bool? ?? false,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'uid': instance.uid,
  'name': instance.name,
  'email': instance.email,
  'image_url': instance.imageUrl,
  'last_active': const TimestampToDateTimeConverter().toJson(
    instance.lastActive,
  ),
  'is_online': instance.isOnline,
};
