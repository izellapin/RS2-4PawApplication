# 🔗 Frontend-Backend Integracija - 4Paw Veterinarska Stanica

## 📋 Šta je implementirano

### ✅ **Kompletno implementirano:**
1. **HTTP API Klijent** (`lib/services/api_client.dart`)
   - Dio HTTP klijent sa automatskim token management-om
   - Interceptors za dodavanje auth token-a
   - Error handling sa custom ApiError
   - Retry logic za 401 errors (token refresh)

2. **Authentication Service** (`lib/services/auth_service.dart`)
   - Čuvanje auth podataka u SharedPreferences
   - Auto-restore korisnika pri pokretanju aplikacije
   - Token expiration provera
   - Permission i role checking

3. **Modeli** (`lib/models/`)
   - User model sa JSON serialization
   - AuthResponse i LoginRequest modeli
   - ApiError model za error handling

4. **Dependency Injection** (`lib/services/service_locator.dart`)
   - Centralizovano upravljanje servisima
   - Proper initialization order

5. **UI Integracija**
   - Login screen povezan sa API-jem
   - Splash screen za loading
   - Automatic navigation based na auth state
   - Logout sa confirmation dialog

## 🚀 Kako pokrenuti integraciju

### 1. **Pokretanje Backend-a**
```bash
cd veterinarskaStanicaBackend
docker-compose up -d
```

Backend će biti dostupan na: `http://localhost:5160`

### 2. **Pokretanje Frontend-a**
```bash
cd veterinarskaStanicaFrontend
flutter pub get
flutter run -d windows
```

## 🔑 **Test korisnici (iz backend seeder-a)**

Možete kreirati test korisnike kroz backend API ili koristiti postojeće:

### Admin korisnik:
- **Email:** `admin@4paw.com`
- **Password:** `admin123`
- **Role:** Admin

### Veterinar korisnik:
- **Email:** `vet@4paw.com`
- **Password:** `vet123`
- **Role:** Veterinarian

## 🔧 **Konfiguracija**

### API Base URL
Trenutno je hardkodovan u `lib/services/api_client.dart`:
```dart
static const String baseUrl = 'http://localhost:5160/api';
```

Za production, treba kreirati environment config.

## 📱 **Kako koristiti**

1. **Pokretanje aplikacije:**
   - Aplikacija će se pokrenuti sa splash screen-om
   - Automatski će proveriti da li je korisnik već ulogovan
   - Ako jeste, vodi direktno na dashboard
   - Ako nije, prikazuje login screen

2. **Login:**
   - Unesite email adresu i lozinku
   - Kliknite "Prijavite se"
   - Pri uspešnom login-u, automatski prelazi na dashboard
   - Pri grešci, prikazuje error poruku

3. **Dashboard:**
   - Različit sadržaj za Admin vs Veterinar
   - Sidebar navigacija (trenutno samo Dashboard radi)
   - Logout dugme sa confirmation dialog-om

## 🛠️ **Sledeći koraci za razvoj**

### Prioritet 1: Implementacija stranica
```bash
# Kreirati screens folder
mkdir lib/screens
mkdir lib/screens/users
mkdir lib/screens/services
mkdir lib/screens/appointments
```

### Prioritet 2: State Management
- Implementirati BLoC pattern za complex state
- Dodati loading states za sve API pozive
- Error handling sa retry logic

### Prioritet 3: Dodatne funkcionalnosti
- File upload za slike
- Real-time notifications
- Offline support
- Caching sa Hive/SQLite

## 🐛 **Poznati problemi**

1. **Refresh Token Circular Dependency:**
   - AuthService i ApiClient imaju circular dependency
   - Trenutno refresh token nije implementiran
   - Rešenje: Refactor-ovati architekturu

2. **Error Handling:**
   - Treba dodati global error handler
   - Retry logic za network errors
   - User-friendly error messages

## 📁 **Struktura fajlova**

```
lib/
├── main.dart                    # Main app entry point
├── models/                      # Data models
│   ├── user.dart
│   ├── auth.dart
│   └── *.g.dart                # Generated JSON serialization
├── services/                    # Business logic services
│   ├── api_client.dart         # HTTP client
│   ├── auth_service.dart       # Authentication
│   └── service_locator.dart    # Dependency injection
└── screens/                     # UI screens (to be created)
```

## 🔍 **Debug informacije**

Aplikacija loguje važne informacije u debug konzolu:
- API requests/responses
- Authentication events
- Error messages
- Service initialization

Za debug mode, koristite:
```bash
flutter run -d windows --debug
```

## 📞 **Support**

Ako imate probleme sa integracijom:
1. Proverite da li je backend pokrenut na `localhost:5160`
2. Proverite debug konzolu za error poruke
3. Testirajte API endpoints direktno kroz Swagger UI: `http://localhost:5160/swagger`

