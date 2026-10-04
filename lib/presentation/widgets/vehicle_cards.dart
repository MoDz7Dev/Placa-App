import 'package:flutter/material.dart';
import 'package:placa_app/config/theme/app_theme.dart';

/// Datos de una card de vehículo (auto) con precio y dirección.
class VehicleData {
  final String image;
  final String price;
  final String period;
  final String address;

  const VehicleData({
    required this.image,
    required this.price,
    this.period = 'Per hour',
    this.address = '',
  });
}

/// Sección "Find a vehicle for your ride" con los tabs
/// Car / Motorbike / Truck y una lista horizontal de cards de autos.
class VehicleCards extends StatelessWidget {
  final List<VehicleData> vehicles;
  final Color accentColor;

  const VehicleCards({
    super.key,
    required this.vehicles,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado con el filtro a la derecha.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ubica tu vehiculo en la cudad',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.location_pin, color: Colors.white70, size: 20),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Tabs de categorías.
        const SizedBox(height: 12),
        // Lista horizontal de cards.
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 35),
            itemCount: vehicles.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) =>
                _VehicleCard(vehicle: vehicles[index], accentColor: accentColor),
          ),
        ),
      ],
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final VehicleData vehicle;
  final Color accentColor;

  const _VehicleCard({required this.vehicle, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: kSecondaryBlue,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del auto sobre fondo celeste.
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color.from(alpha: 1, red: 1, green: 1, blue: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                vehicle.image,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Precio.
          Row(
            children: [
              Text(
                vehicle.price,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                vehicle.period,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Dirección + botón Ubicar.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 13,
                      color: accentColor,
                    ),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        vehicle.address,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Ubicar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
