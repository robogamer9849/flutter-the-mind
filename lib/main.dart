import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'themes/colors.dart';
import 'screens/host.dart';
import 'screens/game.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define our custom colors from the provided hex codes

    return MaterialApp(
      title: 'The Mind',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.light,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: deepPurple,
          brightness: Brightness.light,
          primary: deepPurple,
          secondary: brightPink,
          tertiary: lightBlue,
          surface: Colors.white,
          background: Colors.grey.shade50,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          hintStyle: const TextStyle(fontWeight: FontWeight.w300),
        ),
        cardTheme: CardTheme(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          shadowColor: Colors.black38,
        ),
        fontFamily: 'Poppins',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: deepPurple,
          brightness: Brightness.dark,
          primary: indigoBlue,
          secondary: brightPink,
          tertiary: lightBlue,
          surface: const Color(0xFF1E1E2E),
          background: const Color(0xFF121212),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          hintStyle: const TextStyle(fontWeight: FontWeight.w300),
        ),
        cardTheme: CardTheme(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          shadowColor: Colors.black54,
        ),
        fontFamily: 'Poppins',
      ),
      themeMode: ThemeMode.system,
      home: const TcpPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TcpPage extends StatefulWidget {
  const TcpPage({super.key});

  @override
  State<TcpPage> createState() => _TcpPageState();
}

class _TcpPageState extends State<TcpPage> with SingleTickerProviderStateMixin {
  ServerSocket? server;
  Socket? socket;
  final List<String> messages = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final TextEditingController ipController = TextEditingController(text: '0.0.0.0');
  final TextEditingController portController = TextEditingController(text: '6000');
  final TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  void goToHost() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
          HostMenuScreen(port: portController.text),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
      ),
    );
  }
  
  void connectToServer() async {
    String ip = ipController.text;
    int port = int.tryParse(portController.text) ?? 6000;
    
    setState(() {
      messages.add('Connecting to $ip:$port...');
    });
    
    try {
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
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => 
            GameScreen(port: port, host: ip),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
        ),
      );
    } catch (e) {
      setState(() {
        messages.add('Connection failed: ${e.toString()}');
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection failed: ${e.toString()}'),
          backgroundColor: const Color(0xFFF72585),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(10),
        ),
      );
    }
  }

  @override
  void dispose() {
    socket?.destroy();
    server?.close();
    _animationController.dispose();
    ipController.dispose();
    portController.dispose();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Define our custom colors from the provided hex codes
    const Color lightBlue = Color(0xFF4CC9F0);
    const Color blue = Color(0xFF4895EF);
    const Color indigoBlue = Color(0xFF4361EE);
    const Color deepPurple = Color(0xFF3F37C9);
    const Color darkPurple = Color(0xFF3A0CA3);
    const Color purple = Color(0xFF480CA8);
    const Color violet = Color(0xFF560BAD);
    const Color magenta = Color(0xFF7209B7);
    const Color pink = Color(0xFFB5179E);
    const Color brightPink = Color(0xFFF72585);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'THE MIND',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    darkPurple,
                    purple,
                    violet,
                    magenta,
                    pink,
                  ]
                : [
                    lightBlue,
                    blue,
                    indigoBlue,
                    deepPurple,
                    purple,
                  ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 8,
                    shadowColor: isDarkMode ? Colors.black54 : Colors.black26,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDarkMode
                              ? [
                                  Colors.grey.shade900,
                                  Colors.grey.shade800,
                                ]
                              : [
                                  Colors.white,
                                  Colors.grey.shade50,
                                ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.settings_ethernet,
                                  color: isDarkMode ? lightBlue : deepPurple,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Connection Settings',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? lightBlue : deepPurple,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: ipController,
                                    decoration: InputDecoration(
                                      labelText: 'IP Address',
                                      prefixIcon: Icon(Icons.computer, color: isDarkMode ? blue : indigoBlue),
                                      fillColor: isDarkMode 
                                          ? Colors.grey.shade800 
                                          : Colors.grey.shade100,
                                      labelStyle: TextStyle(color: isDarkMode ? blue : indigoBlue),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextField(
                                    controller: portController,
                                    decoration: InputDecoration(
                                      labelText: 'Port',
                                      prefixIcon: Icon(Icons.numbers, color: isDarkMode ? blue : indigoBlue),
                                      fillColor: isDarkMode 
                                          ? Colors.grey.shade800 
                                          : Colors.grey.shade100,
                                      labelStyle: TextStyle(color: isDarkMode ? blue : indigoBlue),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: goToHost,
                                    icon: const Icon(Icons.router),
                                    label: const Text(
                                      'Host Game',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isDarkMode ? brightPink : pink,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      elevation: 5,
                                      shadowColor: isDarkMode ? brightPink.withOpacity(0.5) : pink.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: connectToServer,
                                    icon: const Icon(Icons.login),
                                    label: const Text(
                                      'Join Game',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Card(
                      elevation: 8,
                      shadowColor: isDarkMode ? Colors.black54 : Colors.black26,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.message_rounded,
                                  color: isDarkMode ? brightPink : pink,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Connection Log',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? brightPink : pink,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Divider(
                              thickness: 1.5,
                              color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                            ),
                            Expanded(
                              child: messages.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            size: 48,
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No connection activity yet',
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Host or join a game to get started',
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: messages.length,
                                      padding: const EdgeInsets.only(top: 8),
                                      physics: const BouncingScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        final message = messages[index];
                                        final isServer = message.startsWith('Server:');
                                        final isError = message.contains('failed');
                                        
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                            decoration: BoxDecoration(
                                              color: isError
                                                  ? brightPink.withOpacity(0.15)
                                                  : isServer
                                                      ? (isDarkMode ? indigoBlue : deepPurple).withOpacity(0.15)
                                                      : isDarkMode
                                                          ? Colors.grey.shade800.withOpacity(0.7)
                                                          : Colors.grey.shade200.withOpacity(0.7),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isError
                                                    ? brightPink.withOpacity(0.3)
                                                    : isServer
                                                        ? (isDarkMode ? indigoBlue : deepPurple).withOpacity(0.3)
                                                        : Colors.transparent,
                                                width: 1,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.05),
                                                  blurRadius: 5,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  isError
                                                      ? Icons.error_outline
                                                      : isServer
                                                          ? Icons.computer
                                                          : Icons.info_outline,
                                                  size: 18,
                                                  color: isError
                                                      ? brightPink
                                                      : isServer
                                                          ? (isDarkMode ? indigoBlue : deepPurple)
                                                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    message,
                                                    style: TextStyle(
                                                      fontWeight: isServer || isError ? FontWeight.bold : FontWeight.normal,
                                                      color: isError
                                                          ? brightPink
                                                          : isServer
                                                              ? (isDarkMode ? indigoBlue : deepPurple)
                                                              : null,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                                  ),
                                                ),
                                              ],
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}