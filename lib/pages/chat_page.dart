import 'package:divertidachat/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _channel = WebSocketChannel.connect(
    Uri.parse('ws://192.168.15.5:8080/ws'),
  );

  final List<types.Message> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();

    // Listen to the WebSocket stream outside of the build method
    _channel.stream.listen((data) {
      final textMessage = types.TextMessage(
        author: types.User(
          id: 'other-user-id',
        ),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: data.toString(),
      );
      // Update the state safely here
      _addMessage(textMessage);
    });
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      _messages[index] = updatedMessage;
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: types.User(
        id: Provider.of<AuthState>(context, listen: false).user?.id ??
            'user-id',
      ),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    _channel.sink.add(message.text);
    _addMessage(textMessage);
  }

  void _loadMessages() async {
    // Load initial messages if necessary.
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Chat'),
        ),
        body: Chat(
          messages: _messages,
          onPreviewDataFetched: _handlePreviewDataFetched,
          onSendPressed: _handleSendPressed,
          showUserAvatars: true,
          showUserNames: true,
          user: types.User(
            id: Provider.of<AuthState>(context, listen: false).user?.id ??
                'user-id',
          ),
        ),
      );
}
