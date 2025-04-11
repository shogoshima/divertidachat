import 'package:divertidachat/main.dart';
import 'package:divertidachat/models/models.dart';
import 'package:divertidachat/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeState _homeState;
  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _homeState = Provider.of<HomeState>(context, listen: false);
    _homeState.connect(
        Provider.of<AuthState>(context, listen: false).user?.id ?? 'user-id');
    // Initialize the chats future only once
    _homeState.loadChats();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize the WebSocket connection
    _homeState.listen(context);
  }

  @override
  void dispose() {
    _homeState.disconnect();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthState>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('DivertidaChat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authState.signOut();
            },
          ),
        ],
      ),
      body: Center(
          child: Column(
        children: [
          ProfileCard(
            name: authState.user?.name,
            username: authState.user?.username,
            photoUrl: authState.user?.photoUrl,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  // Ensure TextField takes available space
                  child: TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Enter username',
                      border: OutlineInputBorder(),
                      hintText: 'Search for a user',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () async {
                          final username = _usernameController.text;
                          if (username.isNotEmpty) {
                            User? user = await Provider.of<HomeState>(context,
                                    listen: false)
                                .searchUser(username, context);

                            if (user != null) {
                              if (!context.mounted) return;
                              showUserDialog(
                                context,
                                user,
                                (username) async {
                                  try {
                                    await _homeState.createChat(username);
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: $e'),
                                      ),
                                    );
                                  }
                                },
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Consumer<HomeState>(
            builder: (context, homeState, child) {
              final chats = homeState.chats; // Get chats from homeState
              return chats.isEmpty
                  ? const Text('No chats available')
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: chats.length,
                      itemBuilder: (context, index) {
                        final chat = chats.values.elementAt(index);
                        final pictures = chat.participants
                            .map((participant) => participant.photoUrl)
                            .where((url) =>
                                url != null && url != authState.user?.photoUrl)
                            .cast<String>()
                            .toList();
                        return ListTile(
                          leading: pictures.isNotEmpty
                              ? MultiImageAvatar(imageUrls: pictures)
                              : const CircleAvatar(
                                  child: Icon(Icons.person),
                                ),
                          title: Text(chat.chatName),
                          subtitle: chat.messages.isNotEmpty
                              ? Text(
                                  chat.messages[0].text,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : const Text('No messages'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  userId: authState.user?.id ?? 'user-id',
                                  chatId: chat.chatId,
                                  chatName: chat.chatName,
                                  chatPhotoUrl: chat.participants
                                          .firstWhere((participant) =>
                                              participant.id !=
                                              authState.user?.id)
                                          .photoUrl ??
                                      '',
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
            },
          ),
        ],
      )),
    );
  }
}
