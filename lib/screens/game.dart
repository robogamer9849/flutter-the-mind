import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

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
  String state = 'show';
  Socket? clientSocket;
  ServerSocket? server;
  bool isConnected = false;
  String connectionStatus = 'Connecting...';
  
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
        connectionStatus = 'Connecting to ${widget.host}:${widget.port}...';
        isConnected = false;
      });
      
      clientSocket = await Socket.connect(widget.host, widget.port);
      debugPrint('Connected to server at ${widget.host}:${widget.port}');
      
      setState(() {
        connectionStatus = 'Connected';
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
        connectionStatus = 'Connection failed: ${e.toString()}';
        isConnected = false;
      });
    }
  }

  void show() async {
    if (clientSocket != null) {
      try {
        setState(() {
          state = 'Checking...';
        });
        
        clientSocket = await Socket.connect(widget.host, widget.port);
        debugPrint('Connected to server at ${widget.host}:${widget.port}');
        
        clientSocket!.write('show');
        
        clientSocket!.listen((data) {
          String reply = String.fromCharCodes(data);
          debugPrint('Received reply: $reply');
          
          // First UI update
          setState(() {
            state = reply;
          });
          
          // Wait and then reset
          Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              state = 'show';
            });
            _setupServer();
            _updateScore();
          });
        });
      } 
      catch (e) {
        debugPrint('Error connecting to server: $e');
        setState(() {
          state = 'Error';
          connectionStatus = 'Connection error: ${e.toString()}';
          isConnected = false;
        });
      }
    }
    else {
      debugPrint('No client connected to send "show" command');
      setState(() {
        connectionStatus = 'Not connected';
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
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              isConnected ? Icons.wifi : Icons.wifi_off,
              size: 20,
              color: isConnected 
                  ? Theme.of(context).colorScheme.primary 
                  : Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            Text(widget.host),
          ],
        ),
        centerTitle: true,
        elevation: 0,
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Score Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.stars,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Your Score',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: score >= 0 
                                ? Theme.of(context).colorScheme.primaryContainer 
                                : Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            score.toString(),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: score >= 0 
                                  ? Theme.of(context).colorScheme.onPrimaryContainer 
                                  : Theme.of(context).colorScheme.onErrorContainer,
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
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.numbers,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Your Number',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: RotationTransition(
                            turns: _rotationAnimation,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondaryContainer,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).shadowColor.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  number >= 0 ? '$number' : '?',
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          connectionStatus,
                          style: TextStyle(
                            color: isConnected 
                                ? Theme.of(context).colorScheme.primary 
                                : Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Action Button
                SizedBox(
                  width: 200,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: show,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: state == 'yes :)' 
                          ? Colors.green 
                          : (state == 'no  :(' 
                              ? Colors.red 
                              : Theme.of(context).colorScheme.primary),
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      state,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
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
