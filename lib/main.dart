import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'themes/colors.dart';
import 'screens/host.dart';
import 'screens/game.dart';
import 'screens/help.dart';
import 'settings.dart';
import 'online_server.dart';


// Main entry point of the application
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

// MyApp widget that sets up the MaterialApp
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    

    // Define our custom colors from the provided hex codes
    return MaterialApp(
      title: isEn ? 'THE MIND' : 'مایند',
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

}// TcpPage widget that manages the connection settings
class TcpPage extends StatefulWidget {
  const TcpPage({super.key});

  @override
  State<TcpPage> createState() => _TcpPageState();
}

// State class for TcpPage
class _TcpPageState extends State<TcpPage> with SingleTickerProviderStateMixin {
  ServerSocket? server; // Server socket for hosting
  Socket? socket; // Client socket for connecting
  final List<String> messages = []; // List to hold connection messages
  late AnimationController _animationController; // Animation controller for fade effect
  late Animation<double> _fadeAnimation; // Fade animation

  final TextEditingController ipController = TextEditingController(text: ''); // IP address input
  final TextEditingController portController = TextEditingController(text: '6000'); // Port input

  @override
  void initState() {
    super.initState();
    // Initialize animation controller and fade animation
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

  // Navigate to HostMenuScreen
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
  
  // Connect to the server
  void connectToServer() async {
    String ip = ipController.text;
    int port = int.tryParse(portController.text) ?? 6000;
    
    setState(() {
      messages.add(isEn ? 'Connecting to $ip:$port...' : 'در حال اتصال به سرور...');
    });
    
    try {
      socket = await Socket.connect(ip, port);
      socket?.listen((data) {
        String message = utf8.decode(data);
        setState(() {
          messages.add(isEn ? 'Server: $message' : 'سرور: $message');
        });
      });
      
      setState(() {
        messages.add(isEn ? 'Connected to server.' : 'با موفقیت به سرور متصل شدید.');
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
        messages.add(isEn ? "can't connect to server \n try to check you wifi, the ip address or and the port number \n also check if the server is opened by the host" : "متاسفانه نمیتوانید به سرور متصل شوید \n لطفا از وضعیت وصل بودن وی فای و ای پی و پورت سرور اطمینان حاصل کنید \n همچنین بررسی کنید که سرور باز است یا نه");
      });
    }
  }


  void connectToOnlineServer() async {
    String ip = onlineIP;
    int port = onlinePort;
    
    setState(() {
      messages.add(isEn ? 'Connecting to online server...' : 'در حال اتصال به سرور آنلاین...');
    });
    
    try {
      socket = await Socket.connect(ip, port);
      socket?.listen((data) {
        String message = utf8.decode(data);
        setState(() {
          messages.add(isEn ? 'Server: $message' : 'سرور: $message');
        });
      });
      
      setState(() {
        messages.add(isEn ? 'Connected to server.' : 'با موفقیت به سرور متصل شدید.');
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
        messages.add(isEn ? "can't connect to server \n check your internet connection" : "متاسفانه نمیتوانید به سرور متصل شوید \n چک کنید که اینترنت شما فعال باشد");
      });
      
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Connection failed: ${e.toString()}'),
      //     backgroundColor: const Color(0xFFF72585),
      //     behavior: SnackBarBehavior.floating,
      //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      //     margin: const EdgeInsets.all(10),
      //   ),
      // );
    }
  }

  @override
  void dispose() {
    // Clean up resources
    socket?.destroy();
    server?.close();
    _animationController.dispose();
    ipController.dispose();
    portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    // Build the main UI of TcpPage
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.help),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HelpScreen()),
                );
              }
            ),
            Text(
              isEn ? 'The Mind' : 'مایند',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                bool oldLang = isEn;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                ).then((_) {
                  if (isEn != oldLang) {
                    messages.clear();
                  }
                  setState(() {});
                });
              },
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
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
                    shadowColor:  Colors.black26,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
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
                              textDirection: isEn  ? TextDirection.ltr : TextDirection.rtl,
                              children: [
                                const Icon(
                                  Icons.settings_ethernet,
                                  color: deepPurple,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  isEn ? 'Connect to a server' : 'اتصال به سرور',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: deepPurple,
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
                                    style: TextStyle(
                                      color:  Colors.blue.shade900,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: isEn ? 'IP address' : 'آدرس آی پی',
                                      prefixIcon: const Icon(Icons.computer, color: indigoBlue),
                                      fillColor:  Colors.grey.shade100,
                                      labelStyle: const TextStyle(color: indigoBlue),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextField(
                                    controller: portController,
                                    style: TextStyle(
                                      color:  Colors.blue.shade900,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: isEn ? 'Port' : 'پورت',
                                      prefixIcon: const Icon(Icons.numbers, color:  indigoBlue),
                                      fillColor: Colors.grey.shade100,
                                      labelStyle: const TextStyle(color: indigoBlue),
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
                                    label: Text(
                                      // texts['host'] ?? 'Host',
                                      isEn ? 'Host' : 'میزبان',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: pink,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      elevation: 5,
                                      shadowColor:  pink.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: connectToServer,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: indigoBlue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      elevation: 5,
                                      shadowColor: indigoBlue.withOpacity(0.5),
                                    ),
                                    icon: const Icon(Icons.login),
                                    label: Text(
                                      isEn ? 'join game' : 'اتصال به بازی',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Row(
                            //   children: [
                            //     Expanded(
                            //       child: ElevatedButton.icon(
                            //         onPressed: () {
                            //             ScaffoldMessenger.of(context).showSnackBar(
                            //               SnackBar(
                            //                 content: Center(child: Text(isEn ? 'this is not working yet :( ' : ':( این هنوز کار نمیکنه')),                                        backgroundColor: lightBlue,
                            //                 behavior: SnackBarBehavior.floating,
                            //                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            //                 margin: const EdgeInsets.all(10),
                            //               ),
                            //             );
                            //           },
                            //         style: ElevatedButton.styleFrom(
                            //           backgroundColor: indigoBlue,
                            //           foregroundColor: Colors.white,
                            //           padding: const EdgeInsets.symmetric(vertical: 16),
                            //           elevation: 5,
                            //           shadowColor: indigoBlue.withOpacity(0.5),
                            //         ),
                            //         icon: const Icon(Icons.online_prediction),
                            //         label: Text(
                            //           isEn ? 'online' : 'بازی آنلاین',
                            //           style: const TextStyle(
                            //             fontWeight: FontWeight.bold,
                            //             fontSize: 16,
                            //           ),
                            //         ),
                            //       ),
                            //     ),
                            //   ],
                            // )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Card(
                      elevation: 8,
                      shadowColor: Colors.black26,
                      color: Colors.grey.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              textDirection: isEn  ? TextDirection.ltr : TextDirection.rtl,
                              children: [
                                const Icon(
                                  Icons.message_rounded,
                                  color: pink,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  isEn ? 'connection logs' : 'لاگ های اتصال',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: pink,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Divider(
                              thickness: 1.5,
                              color: Colors.grey.shade300,
                            ),
                            Expanded(
                              child: messages.isEmpty ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 28,
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      isEn ? 'no activity yet' : 'هنوز هیچ فعالیت وجود ندارد',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      isEn ? 'Host or join a game to get started' : 'برای شروع بازی به عنوان سرور یا کلاینت وارد شوید',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ):
                              ListView.builder(
                                itemCount: messages.length,
                                padding: const EdgeInsets.only(top: 8),
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final message = messages[index];
                                  final isServer = message.startsWith('server:');
                                  final isError = message.contains("can't connect to server") || message.contains("متاسفانه نمیتوانید به سرور متصل شوید");
                                  
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: isError
                                            ? brightPink.withOpacity(0.15)
                                            : isServer
                                                ? deepPurple.withOpacity(0.15)
                                                : lightBlue.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isError
                                              ? brightPink.withOpacity(0.3)
                                              : isServer
                                                  ? ( deepPurple).withOpacity(0.3)
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
                                        textDirection: isEn ? TextDirection.ltr : TextDirection.rtl,
                                        children: [
                                          Icon(
                                            isError
                                                ? Icons.error_outline
                                                : Icons.computer,
                                            size: 18,
                                            color: isError
                                                ? brightPink
                                                : isServer
                                                    ?  deepPurple
                                                    : Theme.of(context).colorScheme.primary,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              textDirection: isEn ? TextDirection.ltr : TextDirection.rtl,
                                              message,
                                              style: TextStyle(
                                                fontWeight: isServer || isError ? FontWeight.bold : FontWeight.normal,
                                                color: isError
                                                    ? brightPink
                                                    : isServer
                                                        ?  deepPurple
                                                        : Theme.of(context).colorScheme.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            if (messages.isNotEmpty) 
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                  messages.clear();
                                  });
                                }, 
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[300],
                                  // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  textDirection: isEn ? TextDirection.ltr : TextDirection.rtl,
                                  children: [
                                    Text(isEn ? 'clear logs' : 'پاک کردن لاگ ها'),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.delete_outline),
                                  ],
                                )
                              )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}