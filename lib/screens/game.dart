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
  Socket? clientSocket;
  ServerSocket? server;

  @override
  void initState() {
    super.initState();
    _setupServer();
  }

  void _setupServer() async {
    try {
      clientSocket = await Socket.connect(widget.host, widget.port);
      debugPrint('Connected to server at ${widget.host}:${widget.port}');
      
      clientSocket!.write('give me');
      
      clientSocket!.listen((data) {
        String reply = String.fromCharCodes(data);
        debugPrint('Received reply: $reply');
        setState(() {
          number = int.tryParse(reply) ?? -1;
        });
      });
    } catch (e) {
      debugPrint('Error connecting to server: $e');
    }
    }

  void show() {
    if (clientSocket != null) {
      clientSocket!.write('show');
    } else {
      debugPrint('No client connected to send "show" command');
    }
  }
  


  @override
  void dispose() {
    clientSocket?.close();
    server?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
