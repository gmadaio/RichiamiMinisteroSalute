# Richiami Alimentari IT — Guida Completa Flutter

## 1. Creazione progetto e avvio locale

```bash
# 1. Crea un nuovo progetto Flutter
flutter create richiami_alimentari_it
cd richiami_alimentari_it

# 2. Sostituisci pubspec.yaml, analysis_options.yaml e la cartella lib/ con i file estratti dall'archivio ZIP

# 3. Scarica le dipendenze
flutter pub get

# 4. Verifica la configurazione
flutter analyze

# 5. Avvia su emulatore Android / Simulatore iOS
flutter run
```

### Configurazione URL Launcher (obbligatoria su Android 11+ e iOS)

In `android/app/src/main/AndroidManifest.xml`, aggiungi dentro `<manifest>`:

```xml
<queries>
  <intent>
    <action android:name="android.intent.action.VIEW" />
    <data android:scheme="https" />
  </intent>
</queries>
```

In `ios/Runner/Info.plist`, aggiungi:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>https</string>
</array>
```

---

## 2. Collegamento a un backend / feed JSON reale

L'app utilizza `RecallApiService` in `lib/services/recall_api_service.dart`.
Per collegarla a un feed JSON esterno aggiornato automaticamente (es. uno script Node.js/Python su Cloud Run, GitHub Actions o Cloudflare Worker che effettua il parsing RSS/HTML pubblico da `salute.gov.it`):

1. Esponi un endpoint HTTPS che restituisca un array JSON (oppure `{ "items": [...] }`) con questa struttura per ogni record:

```json
[
  {
    "id": "ms-2026-0142",
    "publicationDate": "2026-11-22T09:00:00Z",
    "productName": "Salame Felino IGP Stagionato",
    "brand": "Antichi Sapori Parmensi",
    "manufacturer": "Salumificio Val Parma S.r.l.",
    "lotNumbers": ["L261114A", "L261115B"],
    "expirationDate": "18/02/2027 (TMC)",
    "packagingUnit": "450 g",
    "reason": "Rilevata presenza di Listeria monocytogenes.",
    "riskCategory": "microbiologico",
    "instructions": "Non consumare il prodotto e restituirlo al punto vendita.",
    "officialSourceUrl": "https://www.salute.gov.it/...",
    "imageUrl": null
  }
]
```

2. In `lib/providers/recall_providers.dart`, aggiorna il provider:

```dart
final recallApiServiceProvider = Provider<RecallApiService>((ref) {
  return RecallApiService(
    feedUrl: 'https://tuo-server.it/api/richiami.json',
    useMockData: false,
  );
});
```

---

## 3. Build e pubblicazione su Google Play e App Store

### Android (Google Play Console)
```bash
# Configura la firma in android/key.properties e android/app/build.gradle.kts
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS (App Store Connect — richiede macOS e Xcode)
```bash
# Imposta Bundle Identifier e Team di firma in ios/Runner.xcworkspace
flutter build ipa --release
# Output: build/ios/ipa/richiami_alimentari_it.ipa
# Carica tramite Xcode Organizer oppure Apple Transporter
```
