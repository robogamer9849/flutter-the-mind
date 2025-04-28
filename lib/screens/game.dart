// screens/game.dart

import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  final int number;
  const GameScreen({super.key, required this.number});

  @override
  // ignore: library_private_types_in_public_api
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game'),
      ),
      body: Center(
      child: Column(
        children: [
          const Text(
            'Game in progress...',
            style: TextStyle(fontSize: 24),
          ),
          Text(
            "${widget.number}",
          )
        ],
      ),
      )
    );
  }
}