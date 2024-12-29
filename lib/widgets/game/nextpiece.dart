import 'package:flutter/material.dart';

class NextPiece extends StatelessWidget {
    const NextPiece({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return Container(
            width: 100, // Set a fixed width for the next piece box
            height: 100, // Set a fixed height for the next piece box
            decoration: BoxDecoration(
                color: Colors.orange, // Color representing the next piece
                borderRadius: BorderRadius.circular(10), // Rounded corners
                border: Border.all(color: Colors.white, width: 2), // White border
            ),
            // No text or additional content for now
        );
    }
}
