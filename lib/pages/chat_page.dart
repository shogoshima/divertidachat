import 'package:divertidachat/main.dart';
import 'package:divertidachat/widgets/show_modification_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:provider/provider.dart';
import 'package:divertidachat/models/models.dart' as models;

class ChatPage extends StatefulWidget {
  final String userId;
  final String chatId;
  final String chatName;
  final String chatPhotoUrl;
  const ChatPage({
    super.key,
    required this.userId,
    required this.chatId,
    required this.chatName,
    required this.chatPhotoUrl,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  void _handleSendPressed(types.PartialText message) {
    if (message.text.length > 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message too long.'),
        ),
      );
      return;
    }

    Provider.of<HomeState>(context, listen: false)
        .sendMessage(widget.userId, widget.chatId, message.text);
  }

  List<types.TextMessage> _formatMessages(models.ChatDetails? chatDetails) {
    if (chatDetails == null) {
      return [];
    }

    final messages = chatDetails.messages;
    final participants = chatDetails.participants;
    final Map<String, String> names = {};
    final Map<String, String?> photos = {};
    for (final participant in participants) {
      names[participant.id] = participant.name;
      photos[participant.id] = participant.photoUrl;
    }
    final messagesFormatted = messages.map((message) => types.TextMessage(
          author: types.User(
            id: message.senderId,
            firstName: names[message.senderId] ?? 'Unknown',
            imageUrl: photos[message.senderId],
          ),
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
          title: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                  widget.chatPhotoUrl,
                ),
              ),
              const SizedBox(width: 8),
              Text(widget.chatName),
            ],
          ),
        ),
        body: Consumer<HomeState>(
          builder: (context, homeState, child) => Chat(
              messages: _formatMessages(homeState.chats[widget.chatId]),
              onSendPressed: _handleSendPressed,
              showUserAvatars: homeState.chats[widget.chatId]?.isGroup ?? true,
              showUserNames: homeState.chats[widget.chatId]?.isGroup ?? true,
              user: types.User(
                id: authState.user?.id ?? 'user-id',
              ),
              onAttachmentPressed: () {
                showModificationModal(context);
              },
              theme: const DefaultChatTheme(
                primaryColor: Color(0xFF007AFF),
                secondaryColor: Color.fromARGB(160, 0, 79, 163),
                backgroundColor: Colors.white,
                inputBackgroundColor: Color.fromARGB(255, 221, 221, 221),
                inputTextColor: Colors.black,
                sentMessageBodyTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
                receivedMessageBodyTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
                attachmentButtonIcon: Icon(
                  Icons.theater_comedy_outlined,
                  color: Colors.black,
                ),
              )),
        ));
  }
}
