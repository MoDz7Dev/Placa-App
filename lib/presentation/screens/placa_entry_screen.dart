import 'package:flutter/material.dart';
import '../widgets/custom_action_button.dart';

class PlateEntryScreen extends StatefulWidget {
  final Color baseColor; 

  const PlateEntryScreen({super.key, required this.baseColor});

  @override
  State<PlateEntryScreen> createState() => _PlateEntryScreenState();
}

class _PlateEntryScreenState extends State<PlateEntryScreen> {
  final TextEditingController _plateController = TextEditingController();
  
  String _selectedCriterio = 'PLACA PTA';

  final List<String> _criterios = [
    'PLACA PTA',
    'POLIZA',
    'PLACA ANTERIOR',
    'COPO',
  ];

  // Función para cambiar el texto de ayuda (hint) según el criterio
  String get _hintText {
    switch (_selectedCriterio) {
      case 'PLACA PTA':
        return 'Ej: ABC123';
      case 'POLIZA':
        return 'Ej: POL-123456';
      case 'PLACA ANTERIOR':
        return 'Ej: XYZ789';
      case 'COPO':
        return 'Ej: 12345678';
      default:
        return 'Ingresa el valor';
    }
  }

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculamos el espacio que ocupa el teclado para que no tape el campo
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: Color.lerp(const Color(0xFF22252a), widget.baseColor, 0.15),
        child: SafeArea(
          child: Column(
            children: [
              // --- AppBar personalizada ---
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Ingresar Placa',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // --- Formulario ---
              Expanded(
                child: SingleChildScrollView(
                  // Esto ayuda a que al hacer scroll se cierre el teclado
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  // Agregamos el bottomInset para que el teclado no tape el campo
                  padding: EdgeInsets.only(
                    left: 35, 
                    right: 35, 
                    top: 20, 
                    bottom: bottomInset + 20, 
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ingresa los datos\nde tu auto',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Dropdown de Criterio
                      const Text(
                        'Criterio',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2D33),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCriterio,
                            dropdownColor: const Color(0xFF2A2D33),
                            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                            isExpanded: true,
                            // Limitamos la altura del menú para que no se salga de la pantalla
                            menuMaxHeight: 250, 
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                            items: _criterios.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedCriterio = newValue!;
                                // Limpiamos el campo cuando cambian el criterio
                                _plateController.clear();
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Campo de texto DINÁMICO
                      Text(
                        _selectedCriterio, // <--- CAMBIA DINÁMICAMENTE
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _plateController,
                        textCapitalization: TextCapitalization.characters, 
                        style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2),
                        decoration: InputDecoration(
                          hintText: _hintText, // <--- CAMBIA DINÁMICAMENTE
                          hintStyle: const TextStyle(color: Colors.white30),
                          filled: true,
                          fillColor: const Color(0xFF2A2D33),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: widget.baseColor, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- Botón de Buscar ---
              CustomActionButton(
                color: widget.baseColor,
                text: 'Buscar',
                icon: Icons.search,
                onPressed: () {
                  //print('Buscando: ${_plateController.text} con criterio: $_selectedCriterio');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}