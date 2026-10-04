import 'package:flutter/material.dart';

import 'map_route_animation.dart';
import 'vehicle_cards.dart';

/// Tipo de contenido que muestra un slide.
/// - [image]: una imagen de asset (comportamiento original).
/// - [mapRoute]: bloque con cards de vehículos + mapa animado con recorrido.
enum SlideContentType { image, mapRoute }

class SlideData {
  final String image;
  final String title;
  final String subtitle;
  final double scale;
  final Color color;
  final double xOffset;
  final double yOffset;
  final SlideContentType type;

  /// Lista de vehículos a mostrar cuando [type] es [SlideContentType.mapRoute].
  final List<VehicleData> vehicles;

  SlideData({
    required this.image,
    required this.title,
    required this.subtitle,
    this.scale = 1.0,
    required this.color,
    this.xOffset = 0.0,
    this.yOffset = 0.0,
    this.type = SlideContentType.image,
    this.vehicles = const [],
  });
}

class CarouselSlider extends StatefulWidget {
  final List<SlideData> slides;
  final Function(int index, Color color) onPageChanged;

  /// Si es false, los puntitos indicadores internos no se dibujan
  /// (útil cuando el layout padre se encarga de posicionarlos).
  final bool showIndicators;

  const CarouselSlider({
    super.key,
    required this.slides,
    required this.onPageChanged,
    this.showIndicators = true,
  });

  @override
  State<CarouselSlider> createState() => _CarouselSliderState();
}

class _CarouselSliderState extends State<CarouselSlider> {
  final PageController _pageController = PageController(viewportFraction: 1.0);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              widget.onPageChanged(index, widget.slides[index].color);
            },
            itemCount: widget.slides.length,
            itemBuilder: (context, index) {
              final slide = widget.slides[index];
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
                  if (slide.type == SlideContentType.mapRoute) ...[
                    // 1) Cards de vehículos arriba (debajo del título).
                    VehicleCards(
                      vehicles: slide.vehicles,
                      accentColor: slide.color,
                    ),
                    const SizedBox(height: 14),
                    // 2) El mapa ocupa SOLO el espacio restante -> más pequeño.
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 35,
                          right: 35,
                          bottom: 10,
                        ),
                        child: AnimatedBuilder(
                          animation: _pageController,
                          builder: (context, _) {
                            double page = 0;
                            if (_pageController.hasClients &&
                                _pageController.position.haveDimensions) {
                              page = _pageController.page ?? 0;
                            } else {
                              page = _currentPage.toDouble();
                            }
                            // Progreso 0..1 basado en las páginas recorridas
                            // sobre el total de slides.
                            final progress =
                                (page / (widget.slides.length - 1))
                                    .clamp(0.0, 1.0);
                            return MapRouteAnimation(progress: progress);
                          },
                        ),
                      ),
                    ),
                  ] else
                    Expanded(
                      child: ClipRect(
                        child: Transform.translate(
                          offset: Offset(slide.xOffset, slide.yOffset),
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
        // Puntitos indicadores
        if (widget.showIndicators) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.slides.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? widget.slides[_currentPage].color
                      : Colors.white38,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20), // <--- ESPACIO para que no se pegue al botón
        ],
      ],
    );
  }
}