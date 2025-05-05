import 'dart:io';

import '/themes/colors.dart';
import 'package:flutter/material.dart';
import '/settings.dart';

class GameScreen extends StatefulWidget {
  final int port;
  final String host;
  const GameScreen({super.key, required this.port, required this.host});

  @override
  // ignore: library_private_types_in_public_api
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  int number = -1;
  int score = 0;
  String state = isEn ? 'show' : 'نمایش';
  Socket? clientSocket;
  ServerSocket? server;
  bool isConnected = false;
  String connectionStatus = isEn ? 'Connecting...' : 'در حال اتصال...';
  
  // Animation controller for number reveal
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;



  @override
  void initState() {
    super.initState();
    
    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut)
    );

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeOut),
    );

    
    _setupServer();
  }

  void _setupServer() async {
    try {
      setState(() {
        connectionStatus = isEn ? 'Connecting to ${widget.host}:${widget.port}...' : 'به ${widget.host}:${widget.port} متصل شد...';
        isConnected = false;
      });
      
      clientSocket = await Socket.connect(widget.host, widget.port);
      debugPrint('Connected to server at ${widget.host}:${widget.port}');
      
      setState(() {
        connectionStatus = isEn ? 'Connected' : 'متصل شده';
        isConnected = true;
      });
      
      clientSocket!.write('give me');
      
      clientSocket!.listen((data) {
        String reply = String.fromCharCodes(data);
        debugPrint('Received reply: $reply');
        setState(() {
          number = int.tryParse(reply) ?? -1;
          _animationController..reset()..forward();
          _rotationController..reset()..forward();
        });
      });
    } 
    catch (e) {
      debugPrint('Error connecting to server: $e');
      setState(() {
        connectionStatus = isEn ? 'Connection failed: ${e.toString()}' : 'خطا در اتصال: ${e.toString()}';
        isConnected = false;
      });
    }
  }

  void show() async {
    if (clientSocket != null) {
      try {
        setState(() {
          state = isEn ? 'Checking...' : 'چک کردن...';
        });
        
        clientSocket = await Socket.connect(widget.host, widget.port);
        debugPrint('Connected to server at ${widget.host}:${widget.port}');
        
        clientSocket!.write('show');
        
        clientSocket!.listen((data) {
          String reply = String.fromCharCodes(data);
          debugPrint('Received reply: $reply');
          
          // First UI update
          setState(() {
            state = isEn ? reply : reply == 'yes :)' ? 'آره :)' : 'نه :(';
          });
          
          // Wait and then reset
          Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              state = isEn ? 'show' : 'نمایش';
            });
            _setupServer();
            _updateScore();
          });
        });
      } 
      catch (e) {
        debugPrint('Error connecting to server: $e');
        setState(() {
          state = isEn ? 'Error' : 'خطا';
          connectionStatus = isEn ? 'Connection error: ${e.toString()}' : 'خطا در اتصال: ${e.toString()}';
          isConnected = false;
        });
      }
    }
    else {
      debugPrint('No client connected to send "show" command');
      setState(() {
        connectionStatus = isEn ? 'Not connected' : 'متصل نیست';
        isConnected = false;
      });
      _setupServer(); // Try to reconnect
    }
  }

  void _updateScore() async {
    try {
      clientSocket = await Socket.connect(widget.host, widget.port);
      debugPrint('Connected to server at ${widget.host}:${widget.port}');
      
      clientSocket!.write('score');
      
      clientSocket!.listen((data) {
        String reply = String.fromCharCodes(data);
        debugPrint('Received reply: $reply');
        setState(() {
          score = int.tryParse(reply) ?? 0;
        });
      });
    } 
    catch (e) {
      debugPrint('Error connecting to server: $e');
    }
  }

  @override
  void dispose() {
    clientSocket?.close();
    server?.close();
    _animationController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              lightBlue,
              blue,
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                AppBar(
                  title: Row(
                    children: [
                      Icon(
                        isConnected ? Icons.wifi : Icons.wifi_off,
                        size: 20,
                        color: isConnected ? indigoBlue : brightPink,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.host,
                        style: const TextStyle(
                          color: deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  centerTitle: true,
                  elevation: 2,
                  backgroundColor: Colors.transparent,
                  foregroundColor: purple,
                ),
                const SizedBox(height: 30),
                // Score Card
                Card(
                  elevation: 8,
                  shadowColor: deepPurple.withOpacity(0.4),
                  color: Colors.grey.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Colors.lightBlue, width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.stars,
                              color: magenta,
                              size: 28,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              isEn ? 'Your Score' : 'امتیاز شما',
                              style: const  TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: darkPurple,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          decoration: BoxDecoration(
                            color: score >= 0 ? violet.withOpacity(0.8) : brightPink.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: darkPurple.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            score.toString(),
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Number Display
                Card(
                  elevation: 8,
                  shadowColor: deepPurple.withOpacity(0.4),
                  color: Colors.grey.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Colors.lightBlue, width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.numbers,
                              color: indigoBlue,
                              size: 28,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              isEn ? 'Your Number' : 'عدد شما',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: darkPurple,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: RotationTransition(
                            turns: _rotationAnimation,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [blue, deepPurple],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: darkPurple.withOpacity(0.5),
                                    blurRadius: 15,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                                border: Border.all(color: Colors.white.withOpacity(0.8), width: 3),
                              ),
                              child: Center(
                                child: Text(
                                  number >= 0 ? '$number' : '?',
                                  style: const TextStyle(
                                    fontSize: 56,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isConnected ? lightBlue.withOpacity(0.2) : brightPink.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isConnected ? indigoBlue : brightPink,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            connectionStatus,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isConnected ? indigoBlue : brightPink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Action Button
                SizedBox(
                  width: 220,
                  height: 65,
                  child: ElevatedButton(
                    onPressed: show,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: state == 'yes :)'  || state == 'آره :)'
                          ? Colors.green.shade600
                          : (state == 'no  :(' || state == 'نه :('
                              ? brightPink
                              : deepPurple),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 8,
                      shadowColor: darkPurple.withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      state,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
