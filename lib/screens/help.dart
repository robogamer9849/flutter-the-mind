import 'package:flutter/material.dart';
import '/themes/colors.dart';
import '/settings.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold( 
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
                AppBar(
                  title: Text(
                    isEn ? 'How to Play' : 'آموزش بازی',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  elevation: 0,
                  foregroundColor: lightBlue,
                  centerTitle: true,
                  backgroundColor: Colors.transparent,
                ),      
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
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          children: [
            Text(
              isEn ? '🎮 THE MIND 🎮' : '🎮 مایند 🎮',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: lightBlue,
              ),
            ),
            Text(
              isEn ? 'Telepathy Game' : 'بازی تلپاتی مایند',
              style: const TextStyle(
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
      color: Colors.grey.shade50,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: isEn  ? TextDirection.ltr : TextDirection.rtl,
          children: [
            Text(
              isEn ? '🚀 Game Setup' : '🚀 راه اندازی بازی',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: blue,
              ),
            ),
            const SizedBox(height: 16),
            _buildSetupStep('1', isEn ? 'Share the app with friends' : 'اپلیکیشن را با دوستان به اشتراک بگذارید', pink),
            _buildSetupStep('2', isEn ? 'Connect to the same WiFi' : 'همه یه یه وای فای وصل شین', brightPink),
            _buildSetupStep('3', isEn ? 'One player hosts the game' : 'یکی هاست میشه', blue),
            _buildSetupStep('4', isEn ? 'Choose max number' : 'بزرگ ترین عدد رو انتخاب کنین', indigoBlue),
          ],
        ),
      ),
    );
  }

  Widget _buildSetupStep(String number, String? text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        textDirection: isEn  ? TextDirection.ltr : TextDirection.rtl,
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
            text ?? '',
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
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: isEn  ? TextDirection.ltr : TextDirection.rtl,
          children: [
            Text(
              isEn ? '🎮 How to Play' : '🎮 آموزش خود بازی',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: magenta,
              ),
            ),
            const SizedBox(height: 16),
            _buildGameplayRule(isEn ? 'Get your secret number' : 'عدد مخفیت رو بگیر', pink),
            _buildGameplayRule(isEn ? 'guess if you have the lowest number' : 'حدس بزن کوچیک ترینی یا نه', brightPink),
            _buildGameplayRule(isEn ? 'Correct guess = +1 point' : 'درست گفتی؟ 1 امتیاز بگیر', lightBlue),
            _buildGameplayRule(isEn ? 'Wrong guess = -1 point' : 'غلط گفتی؟ 1 امیازت میره', blue),
            _buildGameplayRule(isEn ? 'Highest score wins!' : 'بیشترین امتیاز برندس', indigoBlue),
          ],
        ),
      ),
    );
  }

  Widget _buildGameplayRule(String? text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        textDirection: isEn  ? TextDirection.ltr : TextDirection.rtl,
        children: [
          Icon(Icons.play_arrow, color: color),
          const SizedBox(width: 12),
          Text(
            text ?? '',
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