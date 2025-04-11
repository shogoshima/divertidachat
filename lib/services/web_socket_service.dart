import 'dart:convert';

import 'package:divertidachat/models/models.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  final String wsUrl;
  WebSocketChannel? _channel;

  WebSocketService(this.wsUrl);

  /// Connects to the WebSocket using the provided [userId].
  void connect(String userId) {
    // If there's an existing channel, close it before reconnecting.
    _channel?.sink.close();

    _channel = WebSocketChannel.connect(
      Uri.parse('$wsUrl/ws/$userId'),
    );
  }

  /// Listen for incoming data with a provided callback.
  void listen(void Function(dynamic) onData, BuildContext context) {
    if (_channel == null) {
      throw Exception('WebSocket is not connected.');
    }
    _channel!.stream.listen(
      (data) {
        final decoded = jsonDecode(data);
        if (decoded['type'] == 'error') {
          // Handle error: show snackbar
          final snackBar = SnackBar(
            content:
                Text("⚠️ WebSocket error: ${decoded['payload']['message']}"),
            backgroundColor: Colors.red,
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        } else if (decoded['type'] == 'message') {
          onData(decoded['payload']); // regular message
        }
      },
      onError: (error) {
        throw Exception('WebSocket error: $error');
      },
    );
  }

  /// Sends a message over the WebSocket connection.
  void sendMessage(WebSocketMessage message) {
    if (_channel == null) {
      throw Exception('WebSocket is not connected.');
    }
    _channel!.sink.add(jsonEncode(message));
  }

  /// Closes the WebSocket connection.
  void close() {
    _channel?.sink.close();
    _channel = null;
  }
}
