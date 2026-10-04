import 'package:flutter/material.dart';

class CustomButtonText extends StatelessWidget {
  const CustomButtonText({
    super.key,
    this.icon = Icons.eco,
    this.iconColor = const Color(0xFFFFFFFF),
    this.backgroundColor = const Color(0xFF21955D),
    this.shadowColor = const Color(0xFF000000),
    required this.text,
    required this.isSelected,
    required this.onPressed,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color shadowColor;
  final String text;
  final bool isSelected;
  final VoidCallback onPressed;
  

  @override
  Widget build(BuildContext context) {

    // Cuolores al seleccionar el boton
    final Color fondo = isSelected
        ? backgroundColor                 
        : Colors.transparent; 

    final Color texto = isSelected
        ? Colors.white
        : Colors.white.withValues(alpha: 0.75);

    final Color sombra = isSelected
        ? shadowColor
        : Colors.transparent;

    return SizedBox(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          //elevation: isSelected ? 6 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)
          ),
          backgroundColor: fondo,
          shadowColor: sombra
        ),
        child: Row(
          spacing: 2,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon , size: 22, color: iconColor,),
            Text(text , style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: texto),)
          ],
        ),
      ),
    );
  }
}