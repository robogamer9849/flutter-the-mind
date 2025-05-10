import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:math';

import '/themes/colors.dart';
import '/settings.dart';

import 'game.dart';

class HostMenuScreen extends StatefulWidget {
  final String port;
  const HostMenuScreen({super.key, required this.port});

  @override
  State<HostMenuScreen> createState() => _HostMenuScreenState();
}

class _HostMenuScreenState extends State<HostMenuScreen> {
  String ip = isEn ? 'Fetching IP...' : 'دریافت آی ءي...';
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
          ip = isEn ? 'No network interfaces found' : 'هیچ سرور شبکه فعالی یافت نشد';
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
        title: Text(
          isEn ? 'Game Host' : 'هاست بازی', 
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: lightBlue,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: darkPurple,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                IconButton(
              icon: const Icon(Icons.settings, color: lightBlue,),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                ).then((_) {
                  setState(() {});
                });
              }
            ),
                const SizedBox(width: 10,),
                Icon(
                  isServerRunning ? Icons.cloud_done : Icons.cloud_off,
                  color: isServerRunning ? lightBlue : brightPink,
                ),
              ]
            )
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              darkPurple,
              deepPurple,
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
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: indigoBlue, width: 2),
                ),
                color: Colors.white.withOpacity(0.9),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.router,
                            color: indigoBlue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isEn ? 'Server Information' : 'اطلاعات سرور',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: deepPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: indigoBlue),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.computer, size: 20, color: blue),
                          const SizedBox(width: 8),
                          Text(
                            isEn ? 'IP:' : 'آی پی:',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: deepPurple,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: lightBlue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: blue),
                              ),
                              child: Text(
                                ip,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: deepPurple,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.numbers, size: 20, color: blue),
                          const SizedBox(width: 8),
                          Text(
                            isEn ? 'Port:' : 'پورت:',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: deepPurple,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: lightBlue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: blue),
                            ),
                            child: Text(
                              widget.port,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: deepPurple,
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
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: magenta, width: 2),
                ),
                color: Colors.white.withOpacity(0.9),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.settings,
                            color: magenta,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isEn ? 'Game Settings' : 'تنظیمات بازی',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: purple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: magenta),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isEn ? 'Maximum Number:' : 'حداکثر عدد:',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: purple,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: pink.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: magenta),
                            ),
                            child: Text(
                              maxNumber.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: purple,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: magenta,
                          inactiveTrackColor: pink.withOpacity(0.3),
                          thumbColor: brightPink,
                          overlayColor: magenta.withOpacity(0.2),
                          valueIndicatorColor: violet,
                          valueIndicatorTextStyle: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        child: Slider(
                          value: maxNumber.toDouble(),
                          min: 100,
                          max: 1000,
                          divisions: 9,
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
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: blue, width: 2),
                  ),
                  color: Colors.white.withOpacity(0.9),
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
                                const Icon(
                                  Icons.people,
                                  color: indigoBlue,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isEn ? 'Connected Players' : 'کاربران متصل',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: deepPurple,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: lightBlue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: blue),
                              ),
                              child: Text(
                                isEn ? '${clients.length} players' : '${clients.length} :بازیکنان ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: deepPurple,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: indigoBlue),
                        Expanded(
                          child: clients.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.people_outline,
                                        size: 48,
                                        color: deepPurple.withOpacity(0.5),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        isEn ? 'No players connected yet' : 'هیچ بازیکنی متصل نیست',
                                        style: TextStyle(
                                          color: deepPurple.withOpacity(0.5),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: clients.length,
                                  itemBuilder: (context, index) {
                                    String clientIp = clients.keys.elementAt(index);
                                    // int? clientNumber = clients[clientIp];
                                    int? clientScore = scores[clientIp] ?? 0;
                                    
                                    return Card(
                                      margin: const EdgeInsets.symmetric(vertical: 4),
                                      color: lightBlue.withOpacity(0.1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: const BorderSide(color: blue, width: 1),
                                      ),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: indigoBlue,
                                          child: Text(
                                            '${index + 1}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          isEn ? 'Player: $clientIp' : 'بازیکن: $clientIp',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: deepPurple,
                                          ),
                                        ),
                                        subtitle: Text(
                                          isEn ? 'Number: you cant see the number!!' : 'شماره: شما نمی توانید شماره را ببینید!!',
                                          style: const TextStyle(
                                            color: purple,
                                          ),
                                        ),
                                        trailing: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: lightBlue.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: blue),
                                          ),
                                          child: Text(
                                            isEn ? 'Score: $clientScore' : 'امتیاز: $clientScore',
                                            style: const TextStyle(
                                              color: deepPurple,
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: brightPink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  isEn ? 'START GAME' : 'شروع بازی',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}