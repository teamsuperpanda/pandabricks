import 'package:flutter/material.dart';
import 'package:pandabricks/services/high_score_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ModeCard extends StatefulWidget {
  final void Function() onTap;
  final String mode;

  const ModeCard({super.key, required this.onTap, required this.mode});

  @override
  State<ModeCard> createState() => ModeCardState();
}

class ModeCardState extends State<ModeCard> {
  int? highScore;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final score = await HighScoreService.getHighScore(widget.mode);
    if (mounted) {
      setState(() {
        highScore = score;
      });
    }
  }

  Future<void> refreshHighScore() async {
    await _loadHighScore();
  }

  String getTitle() {
    final l10n = AppLocalizations.of(context)!;
    switch (widget.mode) {
      case 'Easy':
        return l10n.easyMode;
      case 'Normal':
        return l10n.normalMode;
      case 'Bamboo Blitz':
        return l10n.blitzMode;
      default:
        return widget.mode;
    }
  }

  String getDescription() {
    final l10n = AppLocalizations.of(context)!;
    switch (widget.mode) {
      case 'Easy':
        return l10n.easyModeDescription;
      case 'Normal':
        return l10n.normalModeDescription;
      case 'Bamboo Blitz':
        return l10n.blitzModeDescription;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          getTitle(),
                          style: const TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (highScore != null && highScore! > 0)
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                highScore!.toString(),
                                style: const TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
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
                      textAlign: TextAlign.left,
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
