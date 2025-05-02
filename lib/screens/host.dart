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
  int maxNumber = 100;
  Map<String, int> clients = {};
  Map<String, int> scores = {};

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


  void startServer() async {
    int port = int.tryParse(widget.port) ?? 6000;
    server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    server?.listen((Socket client) {
      client.listen((data) {
        String message = utf8.decode(data);
        debugPrint('Received from client: $message');

        if (message.startsWith("give me")) {
          final random = Random();
          if (!clients.containsKey(client.remoteAddress.address)){
            int randomNumber = random.nextInt(maxNumber + 1);
            debugPrint('Sending random number: $randomNumber');
            clients[client.remoteAddress.address] = randomNumber;
            debugPrint(clients.toString());
            client.write(randomNumber);
          }
          else if(clients.containsKey(client.remoteAddress.address)){
            client.write(clients[client.remoteAddress.address]);
          }
          if (!scores.containsKey(client.remoteAddress.address)){
            scores[client.remoteAddress.address] = 0;
          }
        }

        else if (message.startsWith('show')) {
          if (clients[client.remoteAddress.address] == clients.values.reduce(min)) {
            debugPrint('min number = ${clients.values.reduce(min)}');
            client.write('yes :)');
            scores[client.remoteAddress.address] = scores[client.remoteAddress.address]! + 1;
          }
          else {
            client.write('no  :(');
            scores[client.remoteAddress.address] = scores[client.remoteAddress.address]! - 1;
          }
          clients.remove(client.remoteAddress.address);
        }

        else if (message.startsWith('score')) {
          client.write('${scores[client.remoteAddress.address]}');
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
            const SizedBox(height: 20),
            Text(
              'max number: $maxNumber',
            ),
            Slider(
              value: 100,
              min: 0,
              max: 1000,
              
              label: 'max number',
              onChanged: (double value) {
                debugPrint(value.toString());
                if (maxNumber >= 0) {
                  setState(() {
                    maxNumber = value.toInt();
                  });
                  }
                else {
                  setState(() {
                    maxNumber = 100;
                  });
                }
                debugPrint(maxNumber.toString());
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: clients.length,
                itemBuilder: (context, index) {
                  String clientIp = clients.keys.elementAt(index);
                  return ListTile(
                    title: Text('Client: $clientIp'),
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