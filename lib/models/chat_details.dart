import 'package:divertidachat/models/models.dart';

class ChatDetails {
  final String chatId;
  final String chatName;
  final bool isGroup;
  final List<Message> messages;
  final List<User> participants;

  ChatDetails({
    required this.chatId,
    required this.chatName,
    required this.isGroup,
    required this.messages,
    required this.participants,
  });

  static ChatDetails fromJson(Map<String, dynamic> json) {
    return ChatDetails(
      chatId: json['chat_id'],
      chatName: json['chat_name'],
      isGroup: json['is_group'] ?? false,
      messages: (json['messages'] as List)
          .map((message) => Message.fromJson(message))
          .toList(),
      participants: (json['participants'] as List)
          .map((participant) => User.fromJson(participant))
          .toList(),
    );
  }
}
