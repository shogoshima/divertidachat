import 'package:flutter/material.dart';

Future showModificationModal(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return SizedBox(
        height: 400,
        width: double.infinity,
        child: Column(
          children: [
            Text('Modal Bottom Sheet'),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        ),
      );
    },
  );
}
