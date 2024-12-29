import 'package:flutter/material.dart';
import 'package:pandabricks/models/mode_model.dart';
import 'package:pandabricks/logic/modes/modes.dart';

class Score extends StatelessWidget {
    final ModeModel mode;

    const Score({Key? key, required this.mode}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.black,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    Text(
                        Modes.getModeName(mode),
                        style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Fredoka'),
                    ),
                    Text(
                        '0',
                        style: TextStyle(color: Colors.white, fontSize: 24, fontFamily: 'Fredoka'),
                    ),
                    Icon(Icons.pause, color: Colors.white),
                ],
            ),
        );
    }
}
