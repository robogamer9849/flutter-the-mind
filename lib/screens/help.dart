import 'package:flutter/material.dart';
import '/themes/colors.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎮 THE MIND - TELEPATHY GAME! 🎮',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: lightBlue,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '🌟 LET\'S GET THIS PARTY STARTED! 🌟',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: brightPink,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '👥 Round up your crew - the more players, the more mayhem!',
              style: TextStyle(
                fontSize: 16,
                color: violet,
              ),
            ),
            SizedBox(height: 24),
            Text(
              '🚀 LAUNCH THE GAME:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: blue,
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '1. 📱 Share the app with your squad (Android gang only for now!)',
                    style: TextStyle(fontSize: 16, color: indigoBlue),
                  ),
                  Text(
                    '2. 📶 Everyone hop on the same WiFi',
                    style: TextStyle(fontSize: 16, color: deepPurple),
                  ),
                  Text(
                    '3. 🎯 One brave soul hits \'HOST\'',
                    style: TextStyle(fontSize: 16, color: darkPurple),
                  ),
                  Text(
                    '4. 🎲 Pick your challenge level',
                    style: TextStyle(fontSize: 16, color: purple),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Text(
              'GAMEPLAY:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: magenta,
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• 🎭 Get your secret number',
                    style: TextStyle(fontSize: 16, color: pink),
                  ),
                  Text(
                    '• 🎯 Show if you think yours is lowest',
                    style: TextStyle(fontSize: 16, color: brightPink),
                  ),
                  Text(
                    '• ⭐ Correct = +1 point',
                    style: TextStyle(fontSize: 16, color: lightBlue),
                  ),
                  Text(
                    '• 💥 Wrong = -1 point',
                    style: TextStyle(fontSize: 16, color: blue),
                  ),
                  Text(
                    '• 🎉 Most points wins!',
                    style: TextStyle(fontSize: 16, color: indigoBlue),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
