import 'package:flutter/material.dart';
import 'package:pandabricks/theme.dart';

class Score extends StatelessWidget {
    final String mode;

    const Score({Key? key, required this.mode}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        Color modeColor = AppTheme.modeColors[mode] ?? Colors.white;

        return Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.black,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    Text(
                        mode.toUpperCase(),
                        style: TextStyle(
                            color: modeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Fredoka',
                        ),
                    ),
                    Text(
                        '0',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontFamily: 'Fredoka',
                        ),
                    ),
                    IconButton(
                        icon: Icon(Icons.pause, color: Colors.white),
                        onPressed: () {
                            // No logic for now
                        },
                        color: Colors.blue,
                    ),
                ],
            ),
        );
    }
}
