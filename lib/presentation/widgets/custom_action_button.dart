import 'package:flutter/material.dart';

class CustomActionButton extends StatelessWidget {
  final Color color;
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;

  const CustomActionButton({
    super.key,
    required this.color,
    required this.text,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Calculamos si el color de fondo es oscuro (menor a 0.5 de luminosidad)
    final bool isDarkColor = color.computeLuminance() < 0.5;
    
    // Si es oscuro, el texto va en blanco. Si es claro, va en oscuro.
    final Color contentColor = isDarkColor ? Colors.white : const Color(0xFF22252a);

    return Padding(
      padding: const EdgeInsets.only(bottom: 35, left: 35, right: 35),
      child: SizedBox(
        height: 55,
        width: double.infinity,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: onPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: contentColor, // <--- Color dinámico
                    fontSize: 18,
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 8),
                  Icon(icon, color: contentColor, size: 24,), // <--- Color dinámico
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}