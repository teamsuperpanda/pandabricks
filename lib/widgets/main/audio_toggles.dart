import 'package:flutter/material.dart';

class AudioToggles extends StatelessWidget {
  const AudioToggles({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0), // Same padding as ModeCard
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0), // Padding around the content
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black, // Set background color to black
                borderRadius: BorderRadius.circular(15), // Rounded corners
              ),
              child: Padding( // Added padding inside the container
                padding: const EdgeInsets.all(12.0), // Inner padding for content
                child: GestureDetector( // Make the entire area tappable
                  onTap: () {
                    // Handle toggle change for background music
                    // You can implement state management here to toggle the switch
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Background Music',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Fredoka', // Use custom font
                          color: Colors.white, // White text color
                        ),
                      ),
                      Switch(
                        value: true, // Replace with your state management logic
                        onChanged: (value) {
                          // Handle toggle change for background music
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0), // Padding around the content
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black, // Set background color to black
                borderRadius: BorderRadius.circular(15), // Rounded corners
              ),
              child: Padding( // Added padding inside the container
                padding: const EdgeInsets.all(12.0), // Inner padding for content
                child: GestureDetector( // Make the entire area tappable
                  onTap: () {
                    // Handle toggle change for sound effects
                    // You can implement state management here to toggle the switch
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sound Effects',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Fredoka', // Use custom font
                          color: Colors.white, // White text color
                        ),
                      ),
                      Switch(
                        value: true, // Replace with your state management logic
                        onChanged: (value) {
                          // Handle toggle change for sound effects
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
