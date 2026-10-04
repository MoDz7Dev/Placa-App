import 'package:flutter/material.dart';

class ConsejosScanDialog extends StatelessWidget {
  const ConsejosScanDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Colors.black54, // Fondo oscuro semitransparente
      builder: (context) => const ConsejosScanDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Indicador / Flechita superior (puntero hacia el botón de info si deseas)
            const Text(
              'Consejos para fotos',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E37), // Verde oscuro similar a tu tema
              ),
            ),
            const SizedBox(height: 18),

            // Ítem 1
            const _ConsejoItem(
              icon: Icons.crop_free,
              title: 'Coloca la planta en el ',
              highlightText: 'centro',
              subtitle: ' del marco para obtener mejores resultados.',
            ),
            const SizedBox(height: 16),

            // Ítem 2
            const _ConsejoItem(
              icon: Icons.local_florist_outlined,
              title: 'Si la planta es demasiado grande, toma una foto de sus ',
              highlightText: 'hojas o flores',
              subtitle: '.',
            ),
            const SizedBox(height: 16),

            // Ítem 3
            const _ConsejoItem(
              icon: Icons.wb_sunny_outlined,
              title: 'Asegúrate de que la planta esté ',
              highlightText: 'bien iluminada',
              subtitle: ' y la imagen no esté borrosa.',
            ),
            const SizedBox(height: 16),

            // Ítem 4
            const _ConsejoItem(
              icon: Icons.filter_1_outlined,
              title: 'Para un reconocimiento más preciso, asegúrate de que la foto muestre ',
              highlightText: 'una sola planta',
              subtitle: '.',
            ),
            const SizedBox(height: 24),

            // Botón Entendido / Cerrar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF21955D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Entendido',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget privado auxiliar para cada renglón de consejo
class _ConsejoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String highlightText;
  final String subtitle;

  const _ConsejoItem({
    required this.icon,
    required this.title,
    required this.highlightText,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 36, color: const Color(0xFF21955D)),
        const SizedBox(width: 16),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.1),
              children: [
                TextSpan(text: title),
                TextSpan(
                  text: highlightText,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E37)),
                ),
                TextSpan(text: subtitle),
              ],
            ),
          ),
        ),
      ],
    );
  }
}