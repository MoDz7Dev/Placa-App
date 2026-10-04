import 'package:camera/camera.dart';
//import 'package:cultiva_plus/presentation/screens/info_plant.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:placa_app/presentation/widgets/button_comon.dart';
import 'package:placa_app/presentation/widgets/button_selected.dart';
import 'package:placa_app/presentation/widgets/cristal_card.dart';
import 'package:placa_app/presentation/widgets/dialog_emergent.dart';   // necesario para File(...)


class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}
/// Pasos del analisis que se muestran bajo la caja de captura.
enum PasoAnalisis { imagen, buscando, analizando, listo } //-> agregar mas si se agrega mas texto

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver, TickerProviderStateMixin {
  // ─── Campos de estado ───────────────────────────────────────────
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  bool _cargando = true;
  String? _error;
  bool _capturando = false;
  CameraDescription? _camaraActual;
  bool _pausado = false;
  bool _inicializando = false;   // evita abrir/cerrar la camara en paralelo
  bool _desmontado = false;      // bloquea reinit si ya salimos de la pantalla
  int _opcionSeleccionada = 0;   // 0 = "Identificar Planta" por defecto
  String? _rutaFoto;      // ruta de la foto capturada (freeze frame)
  bool _analizando = false;   // hay un analisis en curso
  PasoAnalisis _paso = PasoAnalisis.buscando;

    // ─── Animacion del HUD ───
  bool _hudVisible = true;
  late final AnimationController _hudCtrl;
  late final Animation<double> _hudOffset;
  int _analisisId = 0;   // descarta resultados viejos
    // ─── Linea del escaner ───
  late final AnimationController _lineaCtrl;
  late final Animation<double> _lineaAnim;   // 0.0 -> 1.0 (arriba -> abajo)

  // ─── Ciclo de vida ──────────────────────────────────────────────
  @override
    void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 1 = HUD visible, 0 = HUD oculto.
    _hudCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: 1,
    );
    _hudOffset = CurvedAnimation(
      parent: _hudCtrl,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    // Línea del escáner: barre de arriba a abajo en bucle.
    _lineaCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _lineaAnim = CurvedAnimation(
      parent: _lineaCtrl,
      curve: Curves.easeInOut,
    );

    _inicializarCamara();
  }

  @override
  void dispose() {
    _desmontado = true;          // marca antes de liberar: corta reintentos
    WidgetsBinding.instance.removeObserver(this);
    _hudCtrl.dispose();          // siempre antes de super.dispose()
    _lineaCtrl.dispose();        // libera el ticker del escaner
    _liberarController();        // ya hace null + dispose
    super.dispose();
  }

  // Muestra u oculta el HUD. No usa setState: el AnimatedBuilder
  // escucha _hudCtrl y se reconstruye solo.
  void _cambiarHud(bool visible) {
    if (_hudVisible == visible) return;
    _hudVisible = visible;
    if (visible) {
      _hudCtrl.forward();
    } else {
      _hudCtrl.reverse();
    }
  }


  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Si ya estamos saliendo de la pantalla, no reabrimos nada:
    // en MIUI el paused/resumed llega tarde y provocaba un reinit
    // justo cuando el usuario pulsa "atras" -> se congelaba la UI.
    if (_desmontado || !mounted) return;

    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        // La app pierde el foco: liberamos la cámara para no bloquear
        // el recurso mientras MIUI/Android nos suspende.
        if (_camaraActual != null && !_pausado) {
          _pausado = true;
          _liberarController();
          if (mounted) setState(() {});
        }
        break;

      case AppLifecycleState.resumed:
        // Recuperamos el foco: reabrimos con la MISMA cámara,
        // pero solo si no hay ya una apertura en curso.
        if (_pausado && _camaraActual != null && !_inicializando) {
          _pausado = false;
          _reanudarCamara();
        }
        break;
    }
  }

  /// Suelta el controller sin tocar la UI. Se usa desde el ciclo de vida,
  /// donde no podemos esperar ni reconstruir el árbol.
  void _liberarController() {
    final controller = _controller;
    _controller = null;
    controller?.dispose();
  }



  // ─── Lógica de cámara ──────────────────────────────────────────
  Future<void> _inicializarCamara() async {
    if (_inicializando) return;   // ya hay una apertura en curso
    _inicializando = true;
    try {
      // Timeout de seguridad: en dispositivos MIUI availableCameras()
      // puede quedarse esperando indefinidamente y congelar la UI.
      _cameras = await availableCameras().timeout(
        const Duration(seconds: 8),
      );

      if (_desmontado || !mounted) return;

      if (_cameras.isEmpty) {
        setState(() {
          _error = 'No se encontró ninguna cámara en este dispositivo.';
          _cargando = false;
        });
        return;
      }

      // Preferimos la cámara trasera; si no hay, la primera disponible.
      final camaraTrasera = _cameras.firstWhere(
        (camara) => camara.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      await _abrirCamara(camaraTrasera);
    } on CameraException catch (error) {
      if (_desmontado || !mounted) return;
      setState(() {
        _error = _traducirError(error);
        _cargando = false;
      });
    } catch (error) {
      if (_desmontado || !mounted) return;
      setState(() {
        _error = 'Ocurrió un error inesperado al abrir la cámara.';
        _cargando = false;
      });
    } finally {
      _inicializando = false;
    }
  }

  Future<void> _cerrarCamara() async {
    _camaraActual = null;        // limpia la intención: no reabrir
    _pausado = false;
    _liberarController();
  }

  Future<void> _abrirCamara(CameraDescription descripcion) async {
    // Si ya había un controller vivo, lo liberamos antes de crear otro.
    if (_desmontado || !mounted) return;

    final anterior = _controller;
    if (anterior != null) {
      _controller = null;
      anterior.dispose();
    }

    final nuevoController = CameraController(
      descripcion,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      // Timeout: si la cámara no abre en 10s (típico en MIUI cuando otra
      // app retiene el hardware) liberamos y mostramos error en vez de
      // dejar la UI congelada esperando.
      await nuevoController.initialize().timeout(
        const Duration(seconds: 10),
      );
      if (_desmontado || !mounted) {
        nuevoController.dispose();
        return;
      }
      setState(() {
        _controller = nuevoController;
        _camaraActual = descripcion;
        _cargando = false;
        _error = null;
      });
    } on CameraException catch (error) {
      nuevoController.dispose();
      if (_desmontado || !mounted) return;
      setState(() {
        _error = _traducirError(error);
        _cargando = false;
      });
    } catch (error) {
      // Timeout y otros fallos inesperados.
      nuevoController.dispose();
      if (_desmontado || !mounted) return;
      setState(() {
        _error = 'La cámara tardó demasiado en responder. Intenta de nuevo.';
        _cargando = false;
      });
    }
  }

  Future<void> _reanudarCamara() async {
    final descripcion = _camaraActual;
    if (descripcion == null || _desmontado || !mounted) return;

    setState(() => _cargando = true);   // muestra el spinner durante los ~330ms

    try {
      final nuevoController = CameraController(
        descripcion,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await nuevoController.initialize().timeout(
        const Duration(seconds: 10),
      );
      if (_desmontado || !mounted) {
        nuevoController.dispose();
        return;
      }
      setState(() {
        _controller = nuevoController;
        _cargando = false;
        _error = null;
      });
    } on CameraException catch (error) {
      if (_desmontado || !mounted) return;
      setState(() {
        _cargando = false;
        _error = _traducirError(error);
      });
    } catch (error) {
      // Red de seguridad: si initialize() falla por algo que no sea
      // CameraException, no queremos quedarnos en negro sin mensaje.
      if (_desmontado || !mounted) return;
      setState(() {
        _cargando = false;
        _error = 'No se pudo reabrir la cámara. Intenta de nuevo.';
      });
    }
  }

  



  String _traducirError(CameraException error) {
    switch (error.code) {
      case 'CameraAccessDenied':
        return 'Necesitamos tu permiso para usar la cámara.';
      case 'CameraAccessDeniedWithoutPrompt':
        return 'El permiso de cámara está bloqueado. Actívalo en los ajustes del sistema.';
      case 'CameraAccessRestricted':
        return 'El acceso a la cámara está restringido en este dispositivo.';
      case 'AudioAccessDenied':
      case 'AudioAccessDeniedWithoutPrompt':
        return 'Necesitamos tu permiso para usar el micrófono.';
      case 'AudioAccessRestricted':
        return 'El acceso al micrófono está restringido en este dispositivo.';
      default:
        return 'No se pudo iniciar la cámara: ${error.description ?? error.code}';
    }
  }

  Future<void> _tomarFoto() async {
    final controller = _controller;
    if (!mounted || controller == null || !controller.value.isInitialized || _capturando) {
      return;
    }

    setState(() => _capturando = true);

    try {
      final XFile foto = await controller.takePicture();
      if (!mounted) return;
      setState(() => _capturando = false);

      // Congelamos la imagen: al pintar este archivo encima del preview
      // la camara "se detiene" visualmente.
      final idActual = ++_analisisId;

      setState(() {
        _rutaFoto = foto.path;
        _analizando = true;
        _paso = PasoAnalisis.buscando;
      });
      _cambiarHud(false);       // oculta el HUD con animacion
      _lineaCtrl.repeat(reverse: true);

      // Simulacion provisional. Aqui ira la llamada real a la IA.
      _simularAnalisis(idActual);

    } on CameraException catch (error) {
      if (!mounted) return;
      setState(() {
        _capturando = false;
        _error = _traducirError(error);
      });
    }
  }

  /// Simula el analisis con la IA mientras no hay backend.
  /// El id sirve para descartar respuestas de capturas antiguas.
  Future<void> _simularAnalisis(int id) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted || id != _analisisId) return;   // respuesta vieja, se ignora

    setState(() => _paso = PasoAnalisis.analizando);

    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted || id != _analisisId) return;

    _lineaCtrl.stop();
    _lineaCtrl.reset();
    setState(() {
      _paso = PasoAnalisis.listo;
      _analizando = false;
    });
  }

  /// Una fila de la lista de progreso.
  ///   completo  -> check verde
  ///   activo    -> spinner blanco
  ///   pendiente -> circulo gris
  Widget _filaPaso(String titulo, bool completo, bool activo) {
    final Color colorTexto = completo || activo
        ? Colors.white
        : Colors.white.withValues(alpha: 0.45);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: completo
                ? TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.elasticOut,     // rebote de "logrado"
                    builder: (context, v, child) =>
                        Transform.scale(scale: v, child: child),
                    child: const Icon(
                      Icons.check_circle,
                      color: Color(0xFF7CFFB2),
                      size: 22,
                    ),
                  )
                : activo
                    ? const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      )
                    : Icon(
                        Icons.circle_outlined,
                        size: 22,
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
          ),
          const SizedBox(width: 10),
          Text(
            titulo,
            style: TextStyle(
              color: colorTexto,
              fontSize: 18,
              fontWeight: completo ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }



  // ─── UI ────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Vista de la cámara ocupando toda la pantalla.
          if (controller != null && controller.value.isInitialized)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller.value.previewSize!.height,
                  height: controller.value.previewSize!.width,
                  child: CameraPreview(controller),
                ),
              ),
            )
          else
            const Positioned.fill(
              child: Center(
                child: Icon(Icons.photo_camera, size: 70, color: Colors.white24),
              ),
            ),

          // Freeze Frame: tapa la camara en vivo tras disparar.
          if (_rutaFoto != null)
            Positioned.fill(
              child: Image.file(
                File(_rutaFoto!),
                fit: BoxFit.cover,
                gaplessPlayback: true,   // evita el flash blanco al decodificar
              ),
            ),

          // Estado de carga / error.
          if (_cargando || _error != null)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: _cargando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.no_photography,
                                  size: 70, color: Colors.white),
                              const SizedBox(height: 16),
                              Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              const SizedBox(height: 24),
                              FilledButton.icon(
                                onPressed: _reintentar,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reintentar'),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),


          // ─── Progreso del analisis  ───
          if (_rutaFoto != null)
            Positioned(
              bottom: size.height * 0.09,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _filaPaso(
                      'Analizando Imagen',
                      _paso != PasoAnalisis.imagen,
                      _paso == PasoAnalisis.imagen,
                    ),
                    _filaPaso(
                      'Identificando Planta',
                      _paso == PasoAnalisis.analizando || _paso == PasoAnalisis.listo,
                      _paso == PasoAnalisis.buscando,
                    ),
                    _filaPaso(
                      'Analizando planta',
                      _paso == PasoAnalisis.listo,
                      _paso == PasoAnalisis.analizando,
                    ),
                  ],
                ),
              ),
            ),

          // CULTIVA +
          Positioned(
            top: 12,
            left: size.width * 0.34,
            child: SafeArea(
              child: Image.asset('assets/images/cultiva_+_blanco.png', width: size.width * 0.35,)
            ),
          ),

          // CAPTURADOR + ESCANNER
          Positioned(
            bottom: _analizando ? size.height * 0.30 : size.height * 0.30,
            left: size.width * 0.07,
            child: SafeArea(
              child: SizedBox(
                width: size.width * 0.85,
                // Altura de la caja: ajústala si tus esquinas son más
                // altas o bajas (mira cuánto mide el PNG en proporcion).
                height: size.width * 0.90,
                child: Stack(
                  children: [
                    // 1) Las esquinas de la caja.
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/capturador_delgado.png',
                        fit: BoxFit.fill,
                      ),
                    ),

                    // 2) La linea del escaner, recortada a la caja.
                    if (_analizando)
                      Positioned.fill(
                        child: ClipRect(
                          child: AnimatedBuilder(
                            animation: _lineaAnim,
                            builder: (context, child) {
                              // 0.0 = arriba · 1.0 = abajo
                              final y = _lineaAnim.value;
                              return Align(
                                alignment: Alignment(0, y * 2 - 1),
                                child: child,
                              );
                            },
                            child: Container(
                              height: 5,
                              margin: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    const Color(0xFFFBFCFB).withValues(alpha: 0.0),
                                    const Color(0xFFB0F1CB).withValues(alpha: 0.35),
                                    const Color(0xFFFDFFFE),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFDFFFE).withValues(alpha: 0.9),
                                    blurRadius: 18,
                                    spreadRadius: 3,
                                  ),
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
          ),

          // ═══ HUD animado (caja, panel, botones, logo y disparador) ═══
          // Capas de dentro hacia fuera:
          //   AnimatedBuilder -> escucha la animacion
          //   Opacity + Transform.translate -> se desvanece y baja
          //   IgnorePointer -> deja de recibir toques al estar oculto
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _hudOffset,
              builder: (context, child) {
                final t = _hudOffset.value;   // 0 = oculto · 1 = visible
                return Opacity(
                  opacity: t,
                  child: Transform.translate(
                    // El HUD baja un 12% de la pantalla al ocultarse.
                    offset: Offset(0, (1 - t) * size.height * 0.12),
                    child: child,
                  ),
                );
              },
              // El hijo se construye una sola vez y se reutiliza
              // en cada frame de la animacion.
              child: IgnorePointer(
                // CRITICO: sin esto, con el HUD invisible los botones
                // siguen recibiendo pulsaciones.
                ignoring: !_hudVisible,
                child: Stack(
                  children: [
          Positioned(
            bottom: 0,
            left: -30,
            right: -30,
            child: TarjetaCristal(
              child:Container(
                height: size.height * 0.17,
              )
            )
          ),
          // Botón de volver, flotando sobre el preview.
          Positioned(
            top: 15,
            left: 10,
            child: SafeArea(
              child: CustomButton(
                icon: Icons.arrow_back_ios_new,
                backgroundColor: Colors.transparent,
                sizeIcon: 25,
                sizeButton: 55,
                onPressed: () async {
                  final navigator = Navigator.of(context);   // capturado ANTES del await
                  // Cerramos la cámara explícitamente ANTES de navegar
                  await _cerrarCamara();
                  // Ahora sí salimos
                  navigator.maybePop(); 
                },
              ),
            ),
          ),
          Positioned(
            top: 15,
            left: size.width * 0.85,
            child: SafeArea(
              child: CustomButton(
                icon: Icons.info,
                backgroundColor: Colors.transparent,
                sizeIcon: 30,
                sizeButton: 55,
                onPressed: () async {
                  ConsejosScanDialog.show(context);
                },
              ),
            ),
          ),

          // Barra inferior con el disparador.
          if (controller != null && controller.value.isInitialized)
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Encuadra tu planta',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 60),
                      // -----FILA DE OPCIONES ----
                      SizedBox(
                        height: 50,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(), // Rebote estilo IOS
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            spacing: 5,
                            children: [
                              CustomButtonText(text: 'Particular', isSelected: _opcionSeleccionada == 0,onPressed: () => setState(() => _opcionSeleccionada = 0), icon: Icons.fit_screen_rounded,),
                              CustomButtonText(text: 'Servicio Publico', isSelected: _opcionSeleccionada == 1,onPressed: () => setState(() => _opcionSeleccionada = 1), icon: Icons.fit_screen_rounded),
                              CustomButtonText(text: 'Gubernamental', isSelected: _opcionSeleccionada == 2,onPressed: () => setState(() => _opcionSeleccionada = 2), icon: Icons.fit_screen_rounded),
                              CustomButtonText(text: 'Electrico', isSelected: _opcionSeleccionada == 3,onPressed: () => setState(() => _opcionSeleccionada = 3), icon: Icons.fit_screen_rounded),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 55,
                        children: [
                          Column(
                            children: [
                              CustomButton(
                                icon: Icons.photo_library,
                                onPressed: () {},
                                sizeIcon: 34,
                                sizeButton: 50,
                                backgroundColor: Colors.transparent,
                                iconColor: Colors.white,
                              ),
                              Text(
                                'Fotos',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13
                                ),
                              )
                            ],
                          ),
                          IconButton(
                            onPressed: _capturando ? null : _tomarFoto,
                            iconSize: 72,
                            icon: _capturando
                                ? const SizedBox(
                                  width: 70,
                                  height: 70,
                                  child: CircularProgressIndicator(color: Colors.white),
                                )
                                : Image.asset('assets/images/photo_lens.png', height: 70,),
                          ),
                          Column(
                            children: [
                              CustomButton(
                                icon: Icons.flash_on,
                                onPressed: () {},
                                sizeIcon: 34,
                                sizeButton: 50,
                                backgroundColor: Colors.transparent,
                                iconColor: Colors.white,
                              ),
                              Text(
                                'Flash',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      
                    ],
                  ),
                ),
              ),
            ),
                  ],
                ),
              ),
            ),
          ),


        ],
      ),
    );
  }

  Future<void> _reintentar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    await _inicializarCamara();
  }

}
