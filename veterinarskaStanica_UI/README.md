# 🐾 4Paw Veterinary Clinic - UI Applications

Ovaj folder sadrži sve korisničke interfejse za 4Paw Veterinary Clinic sistem, organizovane po uzoru na [Iron-Vault](https://github.com/vedad-keskin/Iron-Vault/tree/main/IronVault/UI/ironvault_desktop) arhitekturu.

## 📁 Struktura projekta

```
veterinarskaStanica_UI/
├── veterinarska_shared/          # 📦 Dijeljene komponente
│   ├── lib/
│   │   ├── models/               # Modeli podataka
│   │   ├── services/             # API klijent i servisi
│   │   └── veterinarska_shared.dart
│   └── pubspec.yaml
├── veterinarska_desktop/         # 🖥️ Desktop aplikacija
│   ├── lib/
│   │   └── main.dart
│   └── pubspec.yaml
└── veterinarska_mobile/          # 📱 Mobile aplikacija
    ├── lib/
    │   ├── screens/
    │   │   ├── auth/              # Prijava i registracija
    │   │   ├── home/              # Početna stranica
    │   │   ├── pets/              # Upravljanje ljubimcima
    │   │   ├── appointments/      # Termini
    │   │   └── profile/           # Profil korisnika
    │   └── main.dart
    ├── android/
    ├── ios/
    └── pubspec.yaml
```

## 🎯 Aplikacije

### 📦 Veterinarska Shared
**Dijeljene komponente za sve aplikacije**
- **Modeli:** User, Pet, Appointment, Auth
- **Servisi:** ApiClient, AuthService, ServiceLocator
- **Dependency:** Koristi se od strane desktop i mobile aplikacija

### 🖥️ Veterinarska Desktop
**Desktop aplikacija za veterinare i administratore**
- **Platforma:** Windows, Linux, macOS
- **Korisnici:** Veterinari, Administratori, Recepcioner
- **Funkcionalnosti:**
  - Upravljanje pacijentima
  - Pregled svih termina
  - Finansijski izvještaji
  - Administracija sistema

### 📱 Veterinarska Mobile
**Mobilna aplikacija za vlasnike ljubimaca**
- **Platforma:** Android, iOS
- **Korisnici:** Vlasnici ljubimaca (PetOwner)
- **Funkcionalnosti:**
  - Registracija i prijava
  - Dodavanje i upravljanje ljubimcima
  - Zakazivanje termina
  - Pregled istorije termina
  - Upravljanje profilom

## 🚀 Pokretanje aplikacija

### Shared biblioteka
```bash
cd veterinarska_shared
flutter pub get
flutter packages pub run build_runner build
```

### Desktop aplikacija
```bash
cd veterinarska_desktop
flutter pub get
flutter run -d windows  # ili linux/macos
```

### Mobile aplikacija
```bash
cd veterinarska_mobile
flutter pub get
flutter run -d android  # ili ios
```

## 🔧 Razvoj

### Dodavanje novih modela u shared
1. Kreirajte model u `veterinarska_shared/lib/models/`
2. Dodajte export u `veterinarska_shared/lib/veterinarska_shared.dart`
3. Pokrenite code generation:
   ```bash
   cd veterinarska_shared
   flutter packages pub run build_runner build
   ```

### Dodavanje novih screen-ova
**Desktop:**
- Dodajte u `veterinarska_desktop/lib/screens/`
- Integrirajte u sidebar navigaciju

**Mobile:**
- Dodajte u `veterinarska_mobile/lib/screens/`
- Integrirajte u bottom navigation ili kao nove stranice

## 📋 Funkcionalnosti po aplikaciji

### Desktop aplikacija
- ✅ Login screen za veterinare/admin
- ✅ Sidebar navigacija
- ✅ Dashboard
- ✅ Window management
- 🔄 Upravljanje pacijentima (u razvoju)
- 🔄 Kalendar termina (u razvoju)
- 🔄 Finansijski izvještaji (u razvoju)

### Mobile aplikacija
- ✅ Login screen za pet owner-e
- ✅ Registracija novih korisnika
- ✅ Bottom navigation
- ✅ Dashboard sa quick actions
- ✅ Dodavanje i upravljanje ljubimcima
- ✅ Zakazivanje termina
- ✅ Pregled termina (nadolazeći i prošli)
- ✅ Profil korisnika sa statistikama
- ✅ Otkazivanje termina

## 🔗 Backend integracija

Sve aplikacije koriste isti backend API:
- **URL:** `http://localhost:5160/api`
- **Autentifikacija:** JWT tokens
- **Client Type:** Desktop/Mobile (za različite dozvole)

### API Endpoints
- `POST /auth/login` - Prijava
- `POST /auth/register` - Registracija (mobile)
- `GET /pets/owner/{id}` - Ljubimci korisnika
- `POST /pets` - Dodavanje ljubimca
- `GET /appointments/user/{id}` - Termini korisnika
- `POST /appointments` - Zakazivanje termina

## 🎨 Design sistem

### Boje
- **Primarna:** `#2E7D32` (zelena)
- **Sekundarna:** `#4CAF50`
- **Greška:** `#F44336`
- **Upozorenje:** `#FF9800`

### Tipografija
- **Material Design 3**
- **Roboto font family**

## 📱 Mobilne funkcionalnosti

Mobilna aplikacija koristi napredne Flutter funkcionalnosti:
- **Image Picker** - Za slike ljubimaca
- **Permission Handler** - Za dozvole
- **Local Auth** - Biometrijska autentifikacija
- **Geolocator** - Lokacija veterinarske ambulante

## 🔄 Buduće funkcionalnosti

### Desktop
- Detaljni kalendar termina
- Medicinski zapisi
- Izvještaji i statistike
- Upravljanje korisnicima
- Backup i restore

### Mobile
- Push notifikacije
- Chat sa veterinarom
- Podsetnici za termine
- Mapa do ambulante
- Offline mode
- Biometrijska prijava

## 🛠️ Tehnologije

- **Flutter 3.9.2+**
- **Dart 3.0+**
- **Provider** - State management
- **Dio** - HTTP client
- **Shared Preferences** - Local storage
- **JSON Annotation** - Serialization

## 📞 Podrška

Za pitanja o razvoju kontaktirajte razvojni tim ili kreirajte issue u repository-ju.










