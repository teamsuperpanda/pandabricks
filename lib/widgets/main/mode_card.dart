import 'package:flutter/material.dart';

class ModeCard extends StatelessWidget {
  final void Function() onTap;
  final String mode;

  const ModeCard({super.key, required this.onTap, required this.mode});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => onTap(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              color: mode == 'Easy' ? Colors.green : mode == 'Normal' ? Colors.blue : Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$mode Mode',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      mode == 'Easy' ? 'A relaxed mode for beginners.' :
                      mode == 'Normal' ? 'A balanced mode for average players.' :
                      'A fast-paced mode for experts.',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
