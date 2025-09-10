import 'package:json_annotation/json_annotation.dart';
import '../../../../core/firebase/firebase_keys.dart';
import '../../../../core/models/user_model.dart';

import '../../../../core/helpers/time_stamp_convertor.dart';

part 'chat_model.g.dart';

@JsonSerializable()
class ChatModel {
  @JsonKey(includeFromJson: false, includeToJson: false)
  String uid;

  @JsonKey(name: FirebaseKeys.name)
  String? name;

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
  String? imageUrl;

  @JsonKey(name: FirebaseKeys.createdAt)
  @TimestampToDateTimeConverter()
  final DateTime createdAt;

  @JsonKey(name: FirebaseKeys.lastActive)
  @TimestampToDateTimeConverter()
  final DateTime lastActive;

  @JsonKey(includeFromJson: false, includeToJson: false)
  bool hasUnreadMessage;

  @JsonKey(name: FirebaseKeys.unreadCounts)
  final Map<String, int> unreadCounts;

  ChatModel({
    this.uid = '',
    required this.name,
    required this.isGroup,
    required this.membersIds,
    required this.createdAt,
    required this.lastActive,
    this.imageUrl,
    this.membersModels = const [],
    this.lastMessageContent,
    this.lastMessageType,
    this.hasUnreadMessage = false,
    this.unreadCounts = const {},
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) =>
      _$ChatModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatModelToJson(this);

  ChatModel copyWith({
    String? uid,
    String? name,
    bool? isGroup,
    List<String>? membersIds,
    List<UserModel>? membersModels,
    String? lastMessageContent,
    String? lastMessageType,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? lastActive,
    bool? hasUnreadMessage,
    Map<String, int>? unreadCounts,
  }) {
    return ChatModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      isGroup: isGroup ?? this.isGroup,
      membersIds: membersIds ?? this.membersIds,
      membersModels: membersModels ?? this.membersModels,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      lastMessageType: lastMessageType ?? this.lastMessageType,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      hasUnreadMessage: hasUnreadMessage ?? this.hasUnreadMessage,
      unreadCounts: unreadCounts ?? this.unreadCounts,
    );
  }
}
