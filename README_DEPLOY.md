# Jark Tracker — Deploy en otra VPS

Guía para clonar este repo en una VPS Linux (Ubuntu 22.04/24.04) y dejarla
lista para hacer builds de APK Android.

Para builds de iOS necesitás una Mac — eso está documentado en
`README_BUILD_IOS.md`.

---

## 1. Dependencias del sistema

```bash
sudo apt update
sudo apt install -y curl git unzip xz-utils zip libglu1-mesa \
    openjdk-17-jdk openjdk-11-jdk
```

Verificá que tengas al menos **4 GB de RAM** (o RAM+swap combinados). Sin
eso, el Gradle daemon revienta por OOM durante `flutter build`. Si tu VPS
tiene menos:

```bash
sudo fallocate -l 4G /swapfile && sudo chmod 600 /swapfile
sudo mkswap /swapfile && sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

## 2. Flutter SDK

```bash
sudo mkdir -p /opt/flutter-sdk
sudo chown $USER:$USER /opt/flutter-sdk
cd /opt/flutter-sdk
git clone https://github.com/flutter/flutter.git -b stable
export PATH="/opt/flutter-sdk/flutter/bin:$PATH"
echo 'export PATH="/opt/flutter-sdk/flutter/bin:$PATH"' >> ~/.bashrc
flutter doctor
```

## 3. Android SDK (command line tools)

```bash
sudo mkdir -p /opt/android-sdk/cmdline-tools
sudo chown -R $USER:$USER /opt/android-sdk
cd /opt/android-sdk/cmdline-tools
curl -O https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
unzip commandlinetools-linux-*.zip
mv cmdline-tools latest
rm commandlinetools-linux-*.zip

export ANDROID_HOME=/opt/android-sdk
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

# Aceptar licencias e instalar SDK
yes | sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0"
```

Persistí las variables:

```bash
cat >> ~/.bashrc <<'EOF'
export ANDROID_HOME=/opt/android-sdk
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
EOF
```

## 4. Clonar este repo

```bash
git clone https://github.com/cloudium-host/jarktracker.git
cd jarktracker
flutter pub get
```

## 5. Keystore (NO está en el repo)

El keystore real **NO** se sube a git (está en `.gitignore`). Tenés 2 opciones:

### Opción A — usar el mismo keystore Play Store que el server actual
Si vas a publicar APKs **firmados con la misma identidad** (mismo app FAST CAR
en Play Store), copiá el `tenant-fast-car.jks` y su password desde el server
origen vía `scp` (a un path fuera del repo, p. ej. `~/.keystores/`):

```bash
# Desde el server actual:
scp /root/.tenant_keystores/tenant-fast-car.jks usuario@otra-vps:~/.keystores/
scp /root/.tenant_keystores/tenant-fast-car.properties usuario@otra-vps:~/.keystores/
```

Después, en la otra VPS:

```bash
cp android/key.properties.example android/key.properties
# Editá android/key.properties con los valores reales
```

### Opción B — generar un keystore nuevo (app distinta en Play Store)
Si la otra VPS va a publicar una app **diferente** en Play Store:

```bash
keytool -genkey -v -keystore ~/.keystores/upload-key.jks \
    -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Y luego `cp android/key.properties.example android/key.properties` y editalo.

**IMPORTANTE**: si generás un keystore nuevo, vas a tener que crear una app
nueva en Play Console (no podés actualizar la app FAST CAR existente con un
keystore distinto).

## 6. Build APK / AAB

```bash
# Para testing (APK debug, sin firma de release)
flutter build apk --debug

# Para Play Store (AAB firmado con tu keystore)
flutter build appbundle --release
# Resultado en: build/app/outputs/bundle/release/app-release.aab

# APK release standalone (para distribución directa, no Play Store)
flutter build apk --release
# Resultado en: build/app/outputs/flutter-apk/app-release.apk
```

## 7. (Opcional) Cambiar el backend GPS-Wox

Por default la app apunta a `https://app.jarkenterprises.com/api/app/clientlite`.
Si tu otra VPS sirve un GPS-Wox distinto, editá:

```
lib/core/config.dart
```

## 8. (Opcional) Rebrandear para otro tenant

El paquete actual es `com.jarkenterprises.jarktracker`. Para cambiarlo (para
publicar una app distinta en Play Store), usá el comando del Jark Console
(`tenant:build-apk`) o manualmente:

- `android/app/build.gradle` → `applicationId`
- `android/app/src/main/AndroidManifest.xml` → `package` (si está)
- `android/app/src/main/kotlin/...` → mover carpetas + `package` en
  `MainActivity.kt`
- `ios/Runner.xcodeproj/project.pbxproj` → `PRODUCT_BUNDLE_IDENTIFIER`
- `pubspec.yaml` → `name` y `description`
- `lib/core/config.dart` → URL del backend
- Reemplazar `assets/logo.png` con el logo del tenant

---

## Troubleshooting

**`flutter build appbundle` falla con OOM** → activá swap (paso 1).

**`SDK location not found`** → asegurate de tener `ANDROID_HOME` exportada o
crea `android/local.properties` con:
```
sdk.dir=/opt/android-sdk
flutter.sdk=/opt/flutter-sdk/flutter
```

**`Keystore was tampered with, or password was incorrect`** → revisá que
`android/key.properties` apunte al `.jks` correcto y que el password coincida.

**Java version mismatch** → para Flutter usá Java 17:
```bash
sudo update-alternatives --set java /usr/lib/jvm/java-17-openjdk-amd64/bin/java
```
