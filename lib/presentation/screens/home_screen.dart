import 'package:flutter/material.dart';

// 1. CAMBIO: Agregamos la propiedad 'scale' a la clase
class SlideData {
  final String image;
  final String title;
  final String subtitle;
  final double? scale; // <--- Nueva propiedad para controlar el tamaño

  SlideData({
    required this.image,
    required this.title,
    required this.subtitle,
    this.scale, // Por defecto el tamaño es normal (1.0)
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(viewportFraction: 1.0);
  int _currentPage = 0;

  // 2. CAMBIO: Ajustamos la escala de cada auto aquí
  final List<SlideData> _slides = [
    SlideData(
      image: 'assets/images/auto_suzuki.png',
      title: 'Información rápida cuando más la necesitas',
      subtitle: 'Verifica antecedentes antes de comprar y obtén asistencia inmediata en caso de choque.',
      scale: 1.3, // <--- El Jeep amarillo se hará más grande (1.3 = 30% más)
    ),
    SlideData(
      image: 'assets/images/auto_verde.png',
      title: 'Localiza tu vehículo al instante',
      subtitle: 'Sigue la ubicación de tu auto en tiempo real y mantén el control desde cualquier lugar.',
      scale: 0.8, // <--- El Vocho verde se hará más pequeño para que no se salga (0.8 = 20% menos)
    ),
    SlideData(
      image: 'assets/images/auto_blanco.png',
      title: 'Conoce el estado de tu auto',
      subtitle: 'Revisa el historial de mantenimiento y el estado actual de tu vehículo con un solo toque.',
      scale: 1.0, // <--- El Toyota blanco se queda normal
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF22252a),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 30, left: 35, right: 35),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              slide.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              slide.subtitle,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // 3. CAMBIO: Aquí aplicamos la escala y recortamos el desborde
                      Expanded(
                        child: ClipRect( // ClipRect evita que si el auto es muy grande, se salga de su área
                          child: Transform.scale(
                            scale: slide.scale, // Aplicamos la escala de este auto
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: double.infinity,
                              child: Image.asset(
                                slide.image,
                                fit: BoxFit.contain, 
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // --- Puntitos Indicadores (Dots) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.white : Colors.white38,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // --- Botón de abajo ---
            Padding(
              padding: const EdgeInsets.only(bottom: 30, left: 35, right: 35),
              child: SizedBox(
                height: 52,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD9D9D9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: () {
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => const ScanScreen()));
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Get Started',
                        style: TextStyle(
                          color: Color(0xFF22252a),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}