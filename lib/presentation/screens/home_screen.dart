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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.sizeOf(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF22252a),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.only(top: 20, left: 35, right: 35),
              child: Column(
                children: [
                  Text('Información rápida cuando más la necesitas', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),),
                  SizedBox(height: 10),
                  Text('Verifica antecedentes antes de comprar y obtén asistencia inmediata en caso de choque.', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w200),),
                ],
              ),
            ),
            Positioned(
              top: size.height * 0.25,
              left: size.height * -0.1,
              child: Image.asset('assets/images/auto_suzuki.png')
            ),
            Positioned(
              bottom: size.height * 0.03,
              left: size.width * 0.27 ,
              child: SizedBox(
                height: 52,
                width: size.width * 0.5,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    )
                  ),
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 8,
                    children: [
                      Text('Siguiente', style: TextStyle(color: Color(0xFF22252a), fontSize: 16),),
                      Icon(Icons.chevron_right, size: 28,),
                    ],
                  ),
                ),
              ),
            )
          ],
        )
      ),
    );
  }
}