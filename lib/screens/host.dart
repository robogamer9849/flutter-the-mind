import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:math';

import '/themes/colors.dart';
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
  bool isServerRunning = false;

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
    try {
      server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
      setState(() {
        isServerRunning = true;
      });
      
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
              
              // Update UI when a new client connects
              setState(() {});
            }
            else if(clients.containsKey(client.remoteAddress.address)){
              client.write(clients[client.remoteAddress.address]);
            }
            if (!scores.containsKey(client.remoteAddress.address)){
              scores[client.remoteAddress.address] = 0;
              // Update UI when a new score is added
              setState(() {});
            }
          }

          else if (message.startsWith('show')) {
            if (clients[client.remoteAddress.address] == clients.values.reduce(min)) {
              debugPrint('min number = ${clients.values.reduce(min)}');
              client.write('yes :)');
              scores[client.remoteAddress.address] = (scores[client.remoteAddress.address] ?? 0) + 1;
              // Update UI when scores change
              setState(() {});
            }
            else {
              client.write('no  :(');
              scores[client.remoteAddress.address] = (scores[client.remoteAddress.address] ?? 0) - 1;
              // Update UI when scores change
              setState(() {});
            }
            clients.remove(client.remoteAddress.address);
          }

          else if (message.startsWith('score')) {
            client.write('${scores[client.remoteAddress.address]}');
          }
        });
      });
    } catch (e) {
      setState(() {
        isServerRunning = false;
        ip = 'Server error: ${e.toString()}';
      });
    }
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
        builder: (context) => GameScreen(port: int.tryParse(widget.port) ?? 6000, host: ip),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Host'),
        centerTitle: true,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(
              isServerRunning ? Icons.cloud_done : Icons.cloud_off,
              color: isServerRunning 
                  ? Theme.of(context).colorScheme.primary 
                  : Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withOpacity(0.8),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Server Info Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.router,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Server Information',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.computer, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Server IP:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                ip,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.numbers, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Port:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.port,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Game Settings Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.settings,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Game Settings',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Maximum Number:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              maxNumber.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Theme.of(context).colorScheme.primary,
                          inactiveTrackColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          thumbColor: Theme.of(context).colorScheme.primary,
                          overlayColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          valueIndicatorColor: Theme.of(context).colorScheme.primary,
                          valueIndicatorTextStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        child: Slider(
                          value: maxNumber.toDouble(),
                          min: 0,
                          max: 1000,
                          divisions: 100,
                          label: maxNumber.toString(),
                          onChanged: (double value) {
                            debugPrint(value.toString());
                            if (value >= 0) {
                              setState(() {
                                maxNumber = value.toInt();
                              });
                            } else {
                              setState(() {
                                maxNumber = 100;
                              });
                            }
                            debugPrint(maxNumber.toString());
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Connected Clients Card
              Expanded(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.people,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Connected Players',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '${clients.length} players',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        Expanded(
                          child: clients.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.people_outline,
                                        size: 48,
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No players connected yet',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: clients.length,
                                  itemBuilder: (context, index) {
                                    String clientIp = clients.keys.elementAt(index);
                                    int? clientNumber = clients[clientIp];
                                    int? clientScore = scores[clientIp] ?? 0;
                                    
                                    return Card(
                                      margin: const EdgeInsets.symmetric(vertical: 4),
                                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: Theme.of(context).colorScheme.primary,
                                          child: Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.onPrimary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          'Player: $clientIp',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text('Number: $clientNumber'),
                                        trailing: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.primaryContainer,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            'Score: $clientScore',
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: startGame,
                child: const Text('Start Game'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}