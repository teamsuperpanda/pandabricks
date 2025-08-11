import 'package:flutter/material.dart';
import 'package:pandabricks/widgets/home/glass_morphism_card.dart';

class TimerDisplay extends StatelessWidget {
  final Duration timeRemaining;

  const TimerDisplay({super.key, required this.timeRemaining});

  @override
  Widget build(BuildContext context) {
    final minutes = timeRemaining.inMinutes;
    final seconds = timeRemaining.inSeconds % 60;
    final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    
    // Change color based on remaining time
    Color timeColor = Colors.white;
    if (timeRemaining.inSeconds <= 30) {
      timeColor = Colors.redAccent;
    } else if (timeRemaining.inSeconds <= 60) {
      timeColor = Colors.orangeAccent;
    }

    return GlassMorphismCard(
      child: AspectRatio(
        aspectRatio: 1,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.timer,
                color: timeColor,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                timeString,
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 20,
                  color: timeColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
