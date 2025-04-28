import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'screens/host.dart';
import 'screens/game.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'TCP Flutter Demo',
      home: TcpPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TcpPage extends StatefulWidget {
  const TcpPage({super.key});

  @override
  State<TcpPage> createState() => _TcpPageState();
}

class _TcpPageState extends State<TcpPage> {
  ServerSocket? server;
  Socket? socket;
  final List<String> messages = [];

  final TextEditingController ipController = TextEditingController(text: '0.0.0.0');
  final TextEditingController portController = TextEditingController(text: '6000');
  final TextEditingController messageController = TextEditingController();

  void goToHost() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HostMenuScreen(port: portController.text)),
    );
  }
  void connectToServer() async {
    String ip = ipController.text;
    int port = int.tryParse(portController.text) ?? 6000;
    socket = await Socket.connect(ip, port);
    socket?.listen((data) {
      String message = utf8.decode(data);
      setState(() {
        messages.add('Server: $message');
      });
    });
    setState(() {
      messages.add('Connected to server.');
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GameScreen(port: int.tryParse(portController.text) ?? 6000, host: ipController.text,)),
    );
  }

  @override
  void dispose() {
    socket?.destroy();
    server?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TCP Socket Demo')),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: ipController,
                    decoration: const InputDecoration(labelText: 'IP Address'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: portController,
                    decoration: const InputDecoration(labelText: 'Port'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: goToHost,
                  child: const Text('Host Server'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: connectToServer,
                  child: const Text('Join Server'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: messages.map((m) => Text(m)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}