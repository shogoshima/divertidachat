class TextFilter {
  final int id;
  final String name;
  final String emoji;
  final String command;

  const TextFilter({
    required this.id,
    required this.name,
    required this.emoji,
    required this.command,
  });

  static TextFilter fromJson(Map<String, dynamic> json) {
    return TextFilter(
      id: json['id'],
      name: json['name'],
      emoji: json['emoji'],
      command: json['command'],
    );
  }
}
