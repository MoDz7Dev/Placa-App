import 'package:flutter/material.dart';
import 'package:placa_app/config/theme/app_theme.dart';
import 'package:placa_app/presentation/screens/botones_screen.dart';
import '../widgets/carousel_slider.dart';
import '../widgets/custom_action_button.dart';
import '../widgets/vehicle_cards.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<SlideData> _slides = [
    SlideData(
      image: 'assets/images/auto_suzuki.png',
      title: 'Información rápida cuando más la necesitas',
      subtitle: 'Verifica antecedentes antes de comprar y obtén asistencia inmediata en caso de choque.',
      scale: 1.4,
      color: const Color(0xFF2C5282), // Azul oscuro
      xOffset: 20.0, // <--- Ajustado: Un poquito a la derecha
      yOffset: 0.0,
    ),
    SlideData(
      image: 'assets/images/auto_verde.png',
      title: 'Localiza tu vehículo al instante',
      subtitle: 'Sigue la ubicación de tu auto en tiempo real y mantén el control desde cualquier lugar.',
      scale: 0.5,
      color: kSecondaryBlue, 
      xOffset: -10.0, // <--- Ajustado: Un poquito a la izquierda
      yOffset: 0.0,
      type: SlideContentType.mapRoute, // <--- Slide con cards + mapa animado
      vehicles: const [
        VehicleData(
          image: 'assets/images/auto_suzuki.png',
          price: 'JIMMY 4X4',
          period: 'Susuki',
          address: 'Calle #23',
        ),
        VehicleData(
          image: 'assets/images/auto_verde.png',
          price: 'Rogue',
          period: 'Nissan',
          address: 'Calle #10',
        ),
      ],
    ),
    SlideData(
      image: 'assets/images/auto_blanco.png',
      title: 'Conoce el estado de tu auto',
      subtitle: 'Revisa el historial de mantenimiento y el estado actual de tu vehículo con un solo toque.',
      scale: 1.0, // <--- CAMBIO: Bajado de 0.8 a 0.6 para que se vea más pequeño
      color: const Color(0xFFE0E0E0), 
      xOffset: 0.0, // <--- CAMBIO: Movido a la DERECHA (positivo) para centrarlo
      yOffset: 0.0,
    ),
  ];

  int _currentIndex = 0;

  // true cuando estamos en el último slide del carrusel.
  bool get _isLastSlide => _currentIndex == _slides.length - 1;

  void _onPageChanged(int index, Color color) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Color azulado único de toda la app (tono de fondo del primer slide).
    // Ya no cambia al deslizar: sin "cambio entre tonos de colores".
    const Color appBlue = kPrimaryBlue;

    return Scaffold(
      backgroundColor: kDarkBackground,
      body: SafeArea(
        child: Stack(
          children: [
            // El carrusel ocupa todo el espacio disponible.
            // Ocultamos sus puntitos internos porque los dibujamos abajo.
            Positioned.fill(
              child: CarouselSlider(
                slides: _slides,
                onPageChanged: _onPageChanged,
                showIndicators: false,
              ),
            ),
            // Puntitos indicadores anclados ABAJO de la pantalla.
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentIndex == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? appBlue
                          : Colors.white38,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            // El botón aparece SOLO en el último deslizable y se sube
            // encima de los puntitos cuando aparece.
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                offset: _isLastSlide ? Offset.zero : const Offset(0, 1.2),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _isLastSlide ? 1.0 : 0.0,
                  child: IgnorePointer(
                    ignoring: !_isLastSlide,
                    child: CustomActionButton(
                      color: appBlue,
                      text: 'Comenzar',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OptionsScreen(baseColor: appBlue),
                          ),
                        );
                      },
                    ),
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