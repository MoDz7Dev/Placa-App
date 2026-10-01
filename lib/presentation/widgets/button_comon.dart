import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.sizeIcon,
    this.sizeButton,
    this.backgroundColor = const Color(0xFF21955D),
    this.iconColor = const Color(0xFFFFFFFF),
  });

  final IconData? icon;
  final VoidCallback onPressed;
  final double? sizeIcon;
  final double? sizeButton;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon ?? Icons.arrow_back_ios_new, color: iconColor, size: sizeIcon ?? 18),
      style: IconButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: const CircleBorder(),
        minimumSize: Size.square(sizeButton ?? 44),
        maximumSize: Size.square(sizeButton ?? 44),
      ),
    );
  }
}