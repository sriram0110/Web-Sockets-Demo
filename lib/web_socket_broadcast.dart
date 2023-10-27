import 'dart:async';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(const WebSocketDemo());
}

class WebSocketDemo extends StatelessWidget {
  const WebSocketDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WebSocketBroadcast(),
    );
  }
}

class WebSocketBroadcast extends StatefulWidget {
  const WebSocketBroadcast({super.key});

  @override
  State<WebSocketBroadcast> createState() => _WebSocketBroadcastState();
}

class _WebSocketBroadcastState extends State<WebSocketBroadcast> {
  WebSocketChannel channel =
      IOWebSocketChannel.connect("wss://ws.ifelse.io/");
  StreamController<String> broadcastStreamController =
      StreamController<String>.broadcast();

  void _sendMessage(String message) {
    channel.sink.add(message);
  }

  @override
  void initState() {
    super.initState();

    channel.stream.listen((message) {
      broadcastStreamController.add(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WebSocket Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _sendMessage('Received from Client 1');
              },
              child: const Text('Send Message 1'),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                _sendMessage('Received from Client 2');
              },
              child: const Text('Send Message 2'),
            ),
            const SizedBox(
              height: 10,
            ),
            StreamBuilder(
              stream: broadcastStreamController.stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Text('Received: ${snapshot.data}');
                }
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    broadcastStreamController.close();
    super.dispose();
  }
}
