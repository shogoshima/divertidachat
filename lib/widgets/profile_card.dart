import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final String? name;
  final String? username;
  final String? email;
  final String? photoUrl;

  const ProfileCard({
    super.key,
    this.name,
    this.username,
    this.email,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(photoUrl ?? ''),
              radius: 40,
            ),
            const SizedBox(height: 5),
            Text(name ?? 'No Name'),
            const SizedBox(height: 2),
            Text(username ?? 'No Username'),
            const SizedBox(height: 2),
            Text(email ?? 'No Email'),
          ],
        ),
      ),
    );
  }
}
