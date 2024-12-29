import 'package:flutter/material.dart';

class Controls extends StatelessWidget {
  const Controls({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black, // Background color for the controls
      padding:
          const EdgeInsets.symmetric(vertical: 8.0), // Reduced vertical padding
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ControlButton(icon: Icons.arrow_left),
          ControlButton(icon: Icons.arrow_drop_down),
          ControlButton(icon: Icons.arrow_right),
          ControlButton(icon: Icons.rotate_right),
        ],
      ),
    );
  }
}

class ControlButton extends StatelessWidget {
  final IconData icon;

  const ControlButton({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Handle button press
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[800], // Darker button color
          shape: BoxShape.circle, // Circular button shape
          boxShadow: [
            BoxShadow(
              color: Colors.white
                  .withOpacity(0.5), // Change glow effect color to white
              spreadRadius: 5,
              blurRadius: 15,
              offset: const Offset(0, 3), // Changes position of shadow
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20), // Padding inside the button
          child: Icon(
            icon,
            size: 30,
            color: Colors.white, // Change icon color to white
          ),
        ),
      ),
    );
  }
}
