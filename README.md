# Gasolineras más baratas

App Flutter que busca las gasolineras más cercanas (por GPS o eligiendo tu
provincia), compara precios por tipo de combustible usando datos oficiales
del Gobierno, y te lleva hasta la que elijas con navegación paso a paso
dentro de la propia app.

## De dónde salen los datos

- **Precios de carburantes**: API REST pública y gratuita del Ministerio
  para la Transición Ecológica y el Reto Demográfico (Geoportal de Precios
  de Carburantes). No necesita API key. Se actualiza varias veces al día.
- **Mapa**: teselas de [MapTiler](https://www.maptiler.com/) (tiene plan
  gratuito, hace falta una API key propia).
- **Cálculo de rutas y navegación turn-by-turn**:
  [OpenRouteService](https://openrouteservice.org/dev/) (también con plan
  gratuito y API key propia).

  Ambos sustituyen a los servicios de demo con los que empezó este
  proyecto (teselas de OpenStreetMap directas y el servidor de pruebas de
  OSRM), que sus propias políticas de uso prohíben para apps publicadas
  con tráfico real. Las claves van en `lib/config/api_keys.dart` (no se
  sube a git — ver ese archivo para instrucciones de cómo conseguirlas).
  Si la app crece mucho, ambos proveedores tienen planes de pago para más
  volumen.

## Cómo montar el proyecto

Este proyecto te lo entrego como el código Dart de la app (`lib/`,
`pubspec.yaml`) porque el andamiaje de Android/iOS (Gradle, Xcode, etc.)
lo genera automáticamente Flutter con tu versión instalada — así evitamos
que un archivo de plataforma desactualizado te rompa el build.

1. Asegúrate de tener Flutter instalado (`flutter --version`). Si no lo
   tienes: https://docs.flutter.dev/get-started/install
2. Crea un proyecto nuevo vacío al lado de esta carpeta:
   ```
   flutter create fuel_finder
   ```
3. Copia (sobrescribiendo) estos archivos de esta entrega dentro del
   proyecto que acaba de crear `flutter create`:
   - `lib/` (todo el contenido, sustituye al `lib/main.dart` de plantilla)
   - `pubspec.yaml` (sustituye al generado)
4. Añade los permisos de ubicación:
   - Copia el contenido de `platform_snippets/AndroidManifest_additions.xml`
     dentro de `android/app/src/main/AndroidManifest.xml` (justo antes de
     `<application>`, dentro de `<manifest>`).
   - Copia el contenido de `platform_snippets/Info_plist_additions.xml`
     dentro de `ios/Runner/Info.plist` (dentro del `<dict>` principal). Solo
     hace falta si vas a compilar para iPhone.
5. Instala las dependencias:
   ```
   flutter pub get
   ```
6. Conecta un móvil o arranca un emulador, y ejecuta:
   ```
   flutter run
   ```

### Si el build de Android falla por `minSdkVersion`

`geolocator` necesita Android API 21 o superior. Las plantillas recientes
de `flutter create` ya vienen así por defecto, pero si te da un error de
`minSdkVersion`, ábre `android/app/build.gradle` (o `build.gradle.kts`) y
sube `minSdk`/`minSdkVersion` a 21 o más.

## Cómo funciona la app (resumen del código)

- `lib/models/` — `GasStation` (parsea el JSON de la API oficial, incluida
  la rareza de que los decimales vienen con coma en vez de punto),
  `FuelType` (los combustibles que se comparan) y `Province` (las 52
  provincias con su código INE, para la búsqueda manual).
- `lib/services/fuel_price_service.dart` — descarga las gasolineras de
  toda España una vez (se cachea en memoria 20 min), y luego filtra por
  cercanía (fórmula de Haversine, con radio que se va ampliando si hay
  pocos resultados) o por provincia.
- `lib/services/location_service.dart` — permisos y lectura del GPS, tanto
  puntual como en stream continuo para la navegación.
- `lib/services/routing_service.dart` — pide la ruta a OpenRouteService,
  que ya devuelve las instrucciones en español directamente.
- `lib/screens/home_screen.dart` — elegir ubicación GPS o provincia.
- `lib/screens/results_screen.dart` — mapa/lista de gasolineras, chips
  para cambiar de combustible, ordenadas de más barata a más cara.
- `lib/screens/navigation_screen.dart` — navegación turn-by-turn: dibuja
  la ruta, sigue tu posición, avanza de instrucción automáticamente al
  acercarte a cada giro, avisa si te sales de la ruta y te deja
  recalcular, y detecta la llegada.

## Cosas que se han simplificado a propósito (ideas para seguir)

Esto es una base sólida y realista, no una copia 1:1 de Google Maps — eso
llevaría meses. Quedan fuera de este primer corte, por si quieres
ampliarlo más adelante:

- Instrucciones por voz (habría que añadir `flutter_tts`).
- Recalculo automático de ruta al desviarte (ahora mismo te avisa y tú
  decides si recalcular, para no gastar de más las peticiones gratuitas
  de OpenRouteService).
- Tráfico en tiempo real (OpenRouteService no lo ofrece en su plan
  gratuito; Google/Mapbox de pago sí).
- Guardar gasolineras favoritas o histórico de precios (se podría añadir
  con `shared_preferences` o una base de datos local).
