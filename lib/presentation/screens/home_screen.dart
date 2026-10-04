import 'package:flutter/material.dart';
import 'scan_screen.dart'; // <--- NUEVO: Importación agregada

class SlideData {
  final String image;
  final String title;
  final String subtitle;
  final double scale;
  final Color color; 
  final double xOffset; 

  SlideData({
    required this.image,
    required this.title,
    required this.subtitle,
    this.scale = 1.0,
    required this.color, 
    this.xOffset = 0.0, 
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

  final List<SlideData> _slides = [
    SlideData(
      image: 'assets/images/auto_suzuki.png',
      title: 'Información rápida cuando más la necesitas',
      subtitle: 'Verifica antecedentes antes de comprar y obtén asistencia inmediata en caso de choque.',
      scale: 1.4, 
      color: const Color(0xFF2C5282), 
      xOffset: 0.0, 
    ),
    SlideData(
      image: 'assets/images/auto_verde.png',
      title: 'Localiza tu vehículo al instante',
      subtitle: 'Sigue la ubicación de tu auto en tiempo real y mantén el control desde cualquier lugar.',
      scale: 0.9, 
      color: const Color(0xFF7CB342), 
      xOffset: 0.0, 
    ),
    SlideData(
      image: 'assets/images/auto_blanco.png',
      title: 'Conoce el estado de tu auto',
      subtitle: 'Revisa el historial de mantenimiento y el estado actual de tu vehículo con un solo toque.',
      scale: 1.2, 
      color: const Color(0xFFE0E0E0), 
      xOffset: 60.0, 
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = _slides[_currentPage].color;

    return Scaffold(
      backgroundColor: const Color(0xFF22252a),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: Color.lerp(const Color(0xFF22252a), currentColor, 0.15),
        child: SafeArea(
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
                        
                        Expanded(
                          child: ClipRect(
                            child: Transform.translate( 
                              offset: Offset(slide.xOffset, 0), 
                              child: Transform.scale(
                                scale: slide.scale,
                                alignment: Alignment.center,
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Image.asset(
                                    slide.image,
                                    fit: BoxFit.fitWidth, 
                                  ),
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
                      color: _currentPage == index ? currentColor : Colors.white38,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.only(bottom: 30, left: 35, right: 35),
                child: SizedBox(
                  height: 55, 
                  width: double.infinity,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    decoration: BoxDecoration(
                      color: currentColor, 
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: currentColor.withValues(alpha: 0.3), 
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
                      // --- CAMBIO AQUÍ: Navegación al ScanScreen ---
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ScanScreen()),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '¡Estoy listo!', 
                            style: TextStyle(
                              color: Color(0xFF22252a), 
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, color: Color(0xFF22252a)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}