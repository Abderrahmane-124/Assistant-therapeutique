import 'package:flutter/material.dart';

class TipsBox extends StatelessWidget {
  final String text;

  const TipsBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.lightbulb, size: 18, color: Colors.amber),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}



