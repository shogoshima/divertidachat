import 'package:divertidachat/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:provider/provider.dart';
import 'package:divertidachat/models/models.dart' as models;

class ChatPage extends StatefulWidget {
  final String userId;
  final String chatId;
  final String chatName;
  const ChatPage({
    super.key,
    required this.userId,
    required this.chatId,
    required this.chatName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  void _handleSendPressed(types.PartialText message) {
    Provider.of<HomeState>(context, listen: false)
        .sendMessage(widget.userId, widget.chatId, message.text);
  }

  List<types.TextMessage> _formatMessages(List<models.Message> messages) {
    final messagesFormatted = messages.map((message) => types.TextMessage(
          author: types.User(id: message.senderId),
          id: message.id,
          text: message.text,
          createdAt: message.sentAt.millisecondsSinceEpoch,
        ));
    return messagesFormatted.toList();
  }

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthState>(context, listen: false);
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.chatName),
        ),
        body: Consumer<HomeState>(
          builder: (context, homeState, child) => Chat(
            messages:
                _formatMessages(homeState.chats[widget.chatId]?.messages ?? []),
            onSendPressed: _handleSendPressed,
            showUserAvatars: true,
            showUserNames: true,
            user: types.User(
              id: authState.user?.id ?? 'user-id',
            ),
          ),
        ));
  }
}
