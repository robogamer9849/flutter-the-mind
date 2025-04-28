import 'dart:io';

import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  final int port;
  final String host;
  const GameScreen({super.key, required this.port, required this.host});

  

  @override
  // ignore: library_private_types_in_public_api
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {

  int number = -1;

  @override
  void initState() {
    super.initState();
    ServerSocket.bind(widget.host, widget.port).then((server) {
      // Send the text 'show' to the server
      server.listen((Socket socket) {
        socket.write('give me');
        
        // Listen for a reply from the server
        socket.listen((data) {
          // Handle the reply here
          String reply = String.fromCharCodes(data);
          debugPrint('Received reply: $reply');
          number = int.tryParse(reply) ?? -1;
        });
      });
    });
  }


  void show() async {
    ServerSocket? server;
    server = await ServerSocket.bind(widget.host, widget.port);

    // Send the text 'show' to the server
    server.listen((Socket socket) {
      socket.write('show');
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Game'),
        ),
        body: Center(
        child: Column(
          children: [
            const Text(
              'Game in progress...',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              '$number',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: show,
              child: const Text('show')
              )
          ],
        ),
      ),
    );
  }
}