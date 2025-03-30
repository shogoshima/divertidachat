class WebSocketMessage {
  final String id;
  final String text;
  final String senderId;
  final String chatId;
  final String chatName;
  final DateTime sentAt;

  WebSocketMessage({
    required this.id,
    required this.text,
    required this.senderId,
    required this.chatId,
    required this.chatName,
    required this.sentAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'sender_id': senderId.toString(),
      'chat_id': chatId.toString(),
      'chat_name': chatName,
      'sent_at': sentAt.toUtc().toIso8601String(),
    };
  }

  static WebSocketMessage fromJson(Map<String, dynamic> json) {
    return WebSocketMessage(
      id: json['id'],
      text: json['text'],
      senderId: json['sender_id'],
      chatId: json['chat_id'],
      chatName: json['chat_name'],
      sentAt: DateTime.parse(json['sent_at']),
    );
  }
}
