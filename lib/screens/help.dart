import 'package:flutter/material.dart';
import '/themes/colors.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'How to Play',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        elevation: 0,
        centerTitle: true,
      ),      
      body: Container(
        height: 3000,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
                    darkPurple,
                    purple,
                    violet,
                    magenta,
                    pink,
                  ]
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildSetupSection(),
                const SizedBox(height: 32),
                _buildGameplaySection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // color: lightBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Column(
          children: [
            Text(
              '🎮 THE MIND 🎮',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: lightBlue,
              ),
            ),
            Text(
              'Telepathy Game',
              style: TextStyle(
                fontSize: 20,
                color: brightPink,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),    );
  }

  Widget _buildSetupSection() {
    return Card(
      // color: Colors.transparent,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🚀 Game Setup',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: blue,
              ),
            ),
            const SizedBox(height: 16),
            _buildSetupStep('1', 'Share the app with friends', pink),
            _buildSetupStep('2', 'Connect to the same WiFi', brightPink),
            _buildSetupStep('3', 'One player hosts the game', blue),
            _buildSetupStep('4', 'Choose a difficulty level', indigoBlue),
          ],
        ),
      ),
    );
  }

  Widget _buildSetupStep(String number, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameplaySection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🎮 How to Play',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: magenta,
              ),
            ),
            const SizedBox(height: 16),
            _buildGameplayRule('Get your secret number', pink),
            _buildGameplayRule('Play the lowest number first', brightPink),
            _buildGameplayRule('Correct guess = +1 point', lightBlue),
            _buildGameplayRule('Wrong guess = -1 point', blue),
            _buildGameplayRule('Highest score wins!', indigoBlue),
          ],
        ),
      ),
    );
  }

  Widget _buildGameplayRule(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.play_arrow, color: color),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
