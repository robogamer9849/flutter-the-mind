import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:math';

import 'game.dart';

class HostMenuScreen extends StatefulWidget {
  final String port;
  const HostMenuScreen({super.key, required this.port});

  @override
  State<HostMenuScreen> createState() => _HostMenuScreenState();
}

class _HostMenuScreenState extends State<HostMenuScreen> {
  String ip = 'Fetching IP...';

  @override
  void initState() {
    super.initState();
    _getLocalIp();
    startServer();
  }

  Future<void> _getLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list(
          type: InternetAddressType.IPv4, includeLoopback: false);
      if (interfaces.isNotEmpty) {
        // Find the first non-loopback interface with an IP address
        final interface = interfaces.firstWhere(
            (iface) => iface.addresses.isNotEmpty,
            orElse: () => throw Exception('No active network interfaces found'));
        setState(() {
          ip = interface.addresses.first.address;
        });
      } else {
        setState(() {
          ip = 'No network interfaces found';
        });
      }
    } catch (e) {
      setState(() {
        ip = 'Error fetching IP: ${e.toString()}';
      });
    }
  }
  ServerSocket? server;
  List<String> clients = [];


  void startServer() async {
    int port = int.tryParse(widget.port) ?? 6000;
    server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    server?.listen((Socket client) {
      setState(() {
        clients.add(client.remoteAddress.address);
      });
      client.listen((data) {
        String message = utf8.decode(data);
        debugPrint('Received from client: $message');

        if (message.startsWith("give me")) {
          final random = Random();
          int randomNumber = random.nextInt(101);
          client.write(randomNumber);
        }
      });
    });
  }

  @override
  void dispose() {
    server?.close();
    super.dispose();
  }

  void startGame() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(port: int.tryParse(widget.port) ?? 6000, host: ip,),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Host Menu')),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Text(
              ip,
              style: const TextStyle(fontSize: 24),
            ),
            const Text(
              'Waiting for players...',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: clients.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Client: ${clients[index]}'),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: startGame,
              child: const Text('Start Game'),
            ),
          ],
        ),
      ),
    );
  }
}