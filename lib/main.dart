
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:placa_app/config/theme/app_theme.dart';
import 'package:placa_app/presentation/screens/home_screen.dart';
import 'package:placa_app/presentation/widgets/app_shell.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Bloquea la rotación: solo vertical
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    // DeviceOrientation.portraitDown,  // descomenta si quieres permitir boca abajo
  ]);
  
  // Hace que la app dibuje detrás de las barras superior e inferior
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // Configura los colores de las barras del sistema
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      // Barra de estado superior (batería, hora, wifi)
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // Íconos oscuros (negro)

      // Barra de navegación inferior (botones o barra de gestos)
      systemNavigationBarColor: Colors.white, // transparente
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark, 
      systemNavigationBarContrastEnforced: false,
    ),
    
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSystemBars(
        child: MaterialApp(
        theme: AppTheme().theme(),
        debugShowCheckedModeBanner: false,
        home: const HomeScreen(),
      ),
    );
  }
}