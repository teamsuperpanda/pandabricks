import 'package:flutter/material.dart';
import 'package:pandabricks/services/high_score_service.dart';

class ModeCard extends StatefulWidget {
  final void Function() onTap;
  final String mode;

  const ModeCard({super.key, required this.onTap, required this.mode});

  @override
  State<ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<ModeCard> {
  int? highScore;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final score = await HighScoreService.getHighScore(widget.mode);
    if (score > 0) {
      setState(() {
        highScore = score;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String getDescription() {
      switch (widget.mode) {
        case 'Easy':
          return 'Relaxed gameplay with constant speed.';
        case 'Normal':
          return 'Classic mode that gradually speeds up.';
        case 'Bamboo Blitz':
          return 'Fast-paced with special bricks and board flips.';
        default:
          return '';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => widget.onTap(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              color: widget.mode == 'Easy'
                  ? Colors.green
                  : widget.mode == 'Normal'
                      ? Colors.blue
                      : Colors.orange,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${widget.mode} Mode',
                          style: const TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (highScore != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  highScore.toString(),
                                  style: const TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      getDescription(),
                      style: const TextStyle(
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
