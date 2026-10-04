# PlacApp

App Flutter (MVP) para **identificar vehiculos* y **obtener datos**.

> Versión inicial: la identificación usa datos de ejemplo (todavía sin cámara, sin IA y sin API).

## Requisitos

- **Flutter 3.47.5 (stable) / Dart 3.13.4** — comprobar con `flutter --version`.
  El `pubspec.yaml` pide `sdk: ^3.13.3`; con un Flutter anterior, `flutter pub get` fallará con *version solving failed*.
- **Android SDK 36** para ejecutar en Android, **o Chrome** para ejecutar en web.
- **JDK 17** (p. ej. Temurin) con la variable `JAVA_HOME` definida — **imprescindible para compilar/ejecutar en Android** (Gradle lo necesita).
  Comprueba con `flutter doctor`: la línea *Android toolchain* debe aparecer en verde. Si no, apunta Flutter a tu JDK con
  `flutter config --jdk-dir=/ruta/al/jdk` y exporta `JAVA_HOME`.
- Visual Studio **no** es necesario (solo haría falta para Windows desktop, que este proyecto no incluye).

## Puesta en marcha

```bash
# 1. Clonar el repositorio
git clone https://github.com/MoDz7Dev/Placa-App.git
cd Placa_App           # la carpeta que contiene pubspec.yaml

# 2. Descargar dependencias (OBLIGATORIO la primera vez)
flutter pub get

# 3. Ejecutar
flutter run -d chrome      # en el navegador
flutter run                # en el dispositivo o emulador conectado
```

### ¿Por qué es obligatorio `flutter pub get`?

La carpeta `.dart_tool/` (que contiene `package_config.json`) **no se versiona**: está en el `.gitignore`
porque guarda rutas absolutas de tu máquina. La genera `flutter pub get`.

Sin ella, el analizador **no puede resolver** `package:flutter/...` ni tu propio `package:cultiva_plus/...`,
y en VS Code aparecen cientos de errores falsos del tipo
`Target of URI doesn't exist: 'package:flutter/material.dart'`, `Undefined class 'Widget'`, etc.

### Importante al abrir el proyecto en VS Code

Abre como raíz del workspace **la carpeta que contiene `pubspec.yaml`**, no una carpeta padre.
El analysis server solo activa el proyecto Flutter cuando encuentra el `pubspec.yaml`.

## Trabajo con el repositorio remoto (Git)

Flujo de trabajo basado en ramas: trabajamos sobre una rama temporal (`feature/...`) y
la integramos contra la rama **`develop`** (no se sube directo a `main`).

### 1) Empezar actualizado

```bash
git fetch --all
git checkout develop
git pull origin develop
```

### 2) Crear la rama de trabajo

```bash
git checkout -b feature/login     # reemplaza feature/login por el nombre de tu rama
```

### 3) Trabajar y hacer commits pequeños

```bash
git add .
git commit -m "agrego pantalla de login"
git add .
git commit -m "conecto formulario"
```

### 4) Subir la rama al remoto

```bash
git push -u origin feature/login   # -u vincula la rama local con la remota
```

### 5) Integrar la rama en `develop` (merge)

```bash
# Moverse a develop y actualizarla
git checkout develop
git pull origin develop

# Integrar tu rama
git merge feature/login

# Subir develop actualizada al remoto
git push origin develop

# Opcional: eliminar la rama de trabajo, local y remota
git branch -d feature/login            # la rama ya está integrada
git push origin --delete feature/login
```

> 💡 Hacer el merge a `develop` unifica el trabajo sobre la rama de integración.
> Si el equipo lo prefiere, en lugar de `git merge` se puede abrir un Pull Request
> **desde** `feature/...` **hacia** `develop`.

### Solución de problemas (comandos Git)

| Comando | Acción | Ejemplo |
| --- | --- | --- |
| `git status` | Muestra el estado del repositorio: archivos modificados, nuevos y el estado del commit | `git status` |
| `git add .` | Prepara cambios para el commit | `git add .` |
| `git commit -m "mensaje"` | Guarda los cambios preparados con un mensaje | `git commit -m "agrego pantalla de login"` |
| `git push -u origin rama` | Sube la rama al remoto y la vincula | `git push -u origin feature/login` |
| `git push` | Sube los commits de la rama ya vinculada | `git push` |
| `git pull origin main` | Trae y fusiona la rama `main` del remoto | `git pull origin main` |
| `git pull` | Trae y fusiona la rama remota vinculada | `git pull` |
| `git checkout -b rama` | Crea una rama nueva y se cambia a ella | `git checkout -b feature/login` |
| `git checkout rama` | Se cambia a una rama existente | `git checkout develop` |
| `git branch` | Lista las ramas locales | `git branch` |
| `git branch -a` | Lista ramas locales y remotas | `git branch -a` |
| `git fetch --all` | Descarga el estado de todas las ramas del remoto (sin fusionar) | `git fetch --all` |
| `git merge rama` | Integra `rama` en la rama actual | `git merge feature/login` |
| `git branch -d rama` | Elimina una rama local ya fusionada | `git branch -d feature/login` |
| `git branch -D rama` | Elimina una rama local aunque no esté fusionada | `git branch -D feature/obsoleta` |
| `git push origin --delete rama` | Elimina una rama en el remoto | `git push origin --delete feature/login` |

**Otros comandos útiles**

| Comando | Acción | Ejemplo |
| --- | --- | --- |
| `git log --oneline` | Muestra el historial de commits abreviado | `git log --oneline` |
| `git diff` | Muestra los cambios sin preparar | `git diff` |
| `git stash` | Guarda temporalmente los cambios sin commitear | `git stash` |
| `git stash pop` | Restaura los cambios guardados con `stash` | `git stash pop` |
| `git clone <url>` | Copia un repositorio remoto a tu máquina | `git clone https://github.com/MoDz7Dev/Cultiva-Plus.git` |

### Al momento de Cambios del Icono de la Aplicacion:
```bash
# Instalar Dependencia Flutter Launcher Icons 0.14.4 y correr script para cargado de icono
flutter pub get
dart run flutter_launcher_icons

# Verificar instalacion del icono (Si sale hora y fecha reciente se cambio el icono)
Get-ChildItem 'd:\Proyectos_App\cultiva_plus\android\app\src\main\res' -Recurse -Filter '*.png' | Select-Object Name, Length, LastWriteTime

# Limpia todo el build
flutter clean

# Reinstala dependencias
flutter pub get

# DESINSTALA la app del dispositivo/emulador (si no funciona de manera manual)
adb uninstall com.example.cultiva_plus

# Vuelve a instalar
flutter run

```

## Solución de problemas

| Síntoma | Causa | Solución |
| --- | --- | --- |
| `Target of URI doesn't exist: 'package:flutter/material.dart'` | Falta `flutter pub get` | `flutter pub get` y en VS Code `Ctrl+Shift+P` → **Dart: Restart Analysis Server** |
| `Undefined class 'Widget'`, `'Scaffold'`, `'BuildContext'`, muchos `undefined_method` | Cascada del error anterior (el import sin resolver arrastra todo) | Igual que arriba |
| `The URI 'package:flutter_lints/flutter.yaml' ... can't be found` (en `analysis_options.yaml`) | `flutter_lints` aún no está resuelto | Igual que arriba |
| `version solving failed ... requires SDK version ^3.13.3` | Flutter/Dart más antiguo que el exigido | `flutter upgrade` o bajar la restricción en `pubspec.yaml` |
| `Unable to locate gradlew script` al compilar Android | Faltan `gradlew`, `gradlew.bat` y `gradle-wrapper.jar` (están ignorados en `android/.gitignore`, es normal) | Usa siempre `flutter run`/`flutter build`: el tool de Flutter los regenera. No ejecutes `gradlew` a mano |
| La terminal compila pero VS Code sigue en rojo | El analysis server quedó apuntando a la carpeta equivocada | Reabrir la carpeta del `pubspec.yaml` y ejecutar **Dart: Restart Analysis Server** |
| `ERROR: JAVA_HOME is not set and no 'java' command could be found` al `flutter run` / `flutter build apk` | No hay JDK instalado o `JAVA_HOME` no está definido | Instala un JDK 17, exporta `export JAVA_HOME=/ruta/al/jdk` y/o ejecuta `flutter config --jdk-dir=/ruta/al/jdk`; verifica con `flutter doctor` |
| `Cannot find Chrome executable at google-chrome` en `flutter doctor` | El ejecutable de Chrome no está en el `PATH` | `export CHROME_EXECUTABLE=/ruta/a/chrome` (p. ej. `/opt/google/chrome/chrome`) y volver a ejecutar `flutter run -d chrome` |

## Estructura del proyecto

```
lib/
  main.dart                                        # punto de entrada (MaterialApp + tema)
  config/theme/app_theme.dart                      # tema Material 3 (seed de color)
  presentation/screens/home_screen.dart            # pantalla de bienvenida
  presentation/screens/scan_screen.dart            # "escanear planta" (placeholder)
  presentation/screens/planta_detail_screen.dart   # detalle de planta con datos de ejemplo
test/
  widget_test.dart                                 # tests de widget
android/  ios/  web/                               # proyectos nativos
backend/                                           # reservado para el API (vacío por ahora)
```

## Navegación actual

`HomeScreen` → `ScanScreen` → `PlantaDetailScreen`, con `Navigator.push` y `MaterialPageRoute`.

## Reglas para contribuir

- **Nunca** subir `.dart_tool/`, `build/` ni `.flutter-plugins-dependencies` (ya están en `.gitignore`).
- `pubspec.lock` **sí** se versiona (es una app, no un paquete).
- Antes de hacer commit: `flutter analyze` sin errores y `flutter test` en verde.
- Usar ramas (`fix/...`, `feat/...`) y abrir Pull Request en lugar de subir directo a `main`.

## Pendientes conocidos

- `test/widget_test.dart`: sigue siendo el test plantilla del contador, por lo que **falla**. Hay que reescribirlo para probar la pantalla de inicio, la navegación a `ScanScreen` y el detalle de planta.
- `backend/`: la carpeta existe solo con `.gitkeep` y `requirements.txt` está vacío; falta el código del API.
- Identificación de autos: por ahora son datos de ejemplo (sin cámara, sin IA y sin API).

## Recursos

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter documentation](https://docs.flutter.dev/)
