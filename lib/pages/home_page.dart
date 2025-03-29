import 'package:divertidachat/main.dart';
import 'package:divertidachat/widgets/profile_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: () {
                // Navigate to chat page
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const ChatPage()));
              },
              child: Text('Chat')),
        ],
      )),
    );
  }
}
