import 'package:flutter/material.dart';

class Playfield extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return Container(
            color: Colors.black, // Dark background for the playfield
            height: 400, // Set a fixed height for the playfield
            child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 10, // Number of columns
                    childAspectRatio: 1, // Square cells
                ),
                itemBuilder: (context, index) {
                    return Container(
                        margin: EdgeInsets.all(1),
                        color: Colors.grey[800], // Darker color for bricks
                    );
                },
                itemCount: 200, // 20 rows * 10 columns
                physics: NeverScrollableScrollPhysics(), // Disable scrolling
            ),
        );
    }
}
