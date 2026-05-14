# Jark Tracker — Build iOS (macOS)

Esta guía asume que ya descargaste el `.zip` del proyecto y tienes una Mac
con Xcode + Apple Developer ID (gratis o de pago).

## 1. Prerrequisitos en tu Mac

```bash
# Instala Flutter (si aún no lo tienes)
# https://docs.flutter.dev/get-started/install/macos
# Resumen:
brew install --cask flutter
# o descomprime manualmente el SDK de:
# https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.24.3-stable.zip

# Asegúrate de que Xcode esté instalado desde el App Store
xcode-select --install
sudo xcodebuild -license accept

# Acepta licencias de Flutter
flutter doctor --android-licenses   # solo si vas a compilar Android también
flutter doctor
```

`flutter doctor` debe mostrar ✓ en **Flutter**, **Xcode** y **iOS**. Si
sale algo rojo para iOS, ejecuta los comandos que te sugiera.

## 2. Descomprime y entra al proyecto

```bash
cd ~/Downloads
unzip jarktracker-src.zip
cd jarktracker
flutter pub get
```

## 3. Instala las gemas de CocoaPods

```bash
cd ios
pod install --repo-update
cd ..
```

(Si da problema por arquitectura en Macs M1/M2/M3, prueba `arch -x86_64 pod install`.)

## 4. Bundle ID y equipo de firma

Abre el proyecto en Xcode:

```bash
open ios/Runner.xcworkspace
```

**IMPORTANTE**: abre `Runner.xcworkspace`, **no** `Runner.xcodeproj`.

En Xcode:

1. Selecciona el target **Runner** → pestaña **Signing & Capabilities**
2. Marca **Automatically manage signing**
3. En **Team**, elige tu Apple ID (gratis o paga)
4. El **Bundle Identifier** está en `com.jarkenterprises.jarktracker`. Si
   con cuenta gratis te da error de "duplicate", agrégale un sufijo único:
   ej. `com.jarkenterprises.jarktracker.hector`

## 5. Probar en el iPad conectado por cable

1. Conecta el iPad con cable USB/Lightning a la Mac
2. Desbloquea el iPad. Cuando salga "Confiar en este ordenador" → acepta
3. En Xcode, arriba al centro, selecciona tu iPad como destino
4. Dale al botón ▶ **Run** (o `⌘R`)
5. La primera vez Xcode compilará ~5 min, luego instalará la app en el iPad
6. En el iPad, abre **Ajustes → General → VPN y gestión de dispositivos**
   → selecciona tu perfil de desarrollador → **Confiar**
7. Abre la app "Jark Tracker" desde la pantalla de inicio del iPad

Si usas la cuenta Apple **gratis**, la app caduca en 7 días y tienes que
volver a compilar. Con cuenta paga ($99/año) dura 1 año y puedes subir a
TestFlight para distribuir a más iPads sin cable.

## 6. Alternativa — Flutter CLI directo

```bash
flutter devices            # confirma que tu iPad sale listado
flutter run -d <device_id> # compila + instala + live reload
```

## 7. Build release para TestFlight / App Store

```bash
flutter build ipa --release
# Resultado: build/ios/ipa/jarktracker.ipa
```

Luego sube con **Transporter** (Mac App Store, gratis):
1. Abre Transporter, arrastra el `.ipa`
2. Sign in con tu Apple ID
3. "Deliver" — sube a App Store Connect
4. Desde App Store Connect, invita beta testers a TestFlight

## Configuración importante

- **Servidor API**: está hardcodeado a `https://app.jarkenterprises.com/api/app/clientlite` en `lib/core/config.dart`. Si cambias de dominio, ajusta ahí.
- **Tema**: navy + rojo, persistido con SharedPreferences.
- **Permisos declarados**: galería de fotos, cámara (para avatar), ubicación (para centrar mapa). Están en `ios/Runner/Info.plist`.

## Troubleshooting

- **"No valid iOS code signing certificates were found"** → agrega tu Apple
  ID en Xcode → Preferences → Accounts
- **Pod install falla** → borra `ios/Pods`, `ios/Podfile.lock` y
  `ios/.symlinks`, luego `flutter clean && flutter pub get && cd ios && pod install`
- **App se cierra al abrir mapa** → revisa que Info.plist tenga
  `NSLocationWhenInUseUsageDescription`

---

Cuando tengas el `.ipa` corriendo, avísame y seguimos con el siguiente
paso (Firebase/FCM, publicación a tiendas, etc).
