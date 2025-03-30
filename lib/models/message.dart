class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String text;
  final DateTime sentAt;
  final bool seen;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    required this.sentAt,
    this.seen = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId.toString(),
      'sender_id': senderId.toString(),
      'text': text,
      'sent_at': sentAt.toIso8601String(),
      'seen': seen,
    };
  }

  static Message fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      chatId: json['chat_id'],
      senderId: json['sender_id'],
      text: json['text'],
      sentAt: DateTime.parse(json['sent_at']),
      seen: json['seen'],
    );
  }
}
