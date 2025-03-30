import 'package:divertidachat/models/models.dart';
import 'package:flutter/material.dart';

Future<void> showUserDialog(
    BuildContext context, User user, Function(String) onConfirm) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Start chat with ${user.name}?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(user.photoUrl ?? ''),
              radius: 60,
            ),
          ],
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Start Chat'),
                onPressed: () {
                  Navigator.of(context).pop();
                  onConfirm(user.username);
                },
              ),
            ],
          ),
        ],
      );
    },
  );
}
