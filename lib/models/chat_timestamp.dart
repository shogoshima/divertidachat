class ChatTimestamp {
  final String chatId;
  final DateTime updatedAt;

  ChatTimestamp({
    required this.chatId,
    required this.updatedAt,
  });

  static ChatTimestamp fromJson(Map<String, dynamic> json) {
    return ChatTimestamp(
      chatId: json['chat_id'],
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
