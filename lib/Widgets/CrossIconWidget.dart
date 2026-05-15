import 'package:flutter/material.dart';

class CrossIconWidget extends StatelessWidget {
  final VoidCallback onClose; // Callback for when the icon is clicked

  const CrossIconWidget({Key? key, required this.onClose}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.close),
      color: Colors.red, // You can customize the color
      onPressed: onClose, // Call the onClose callback when clicked
      tooltip: 'Close', // Tooltip for accessibility
    );
  }
}
