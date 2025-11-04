# Stripe Payment Integration Setup

## 📋 Preduvjeti

1. Kreirajte nalog na [Stripe Dashboard](https://dashboard.stripe.com/register)
2. Dobavite API keys iz Stripe Dashboard-a

## 🔑 Dobavljanje Stripe Keys

1. Idite na [Stripe Dashboard](https://dashboard.stripe.com/)
2. Kliknite na **Developers** > **API Keys**
3. Kopirajte **Secret key** i **Publishable key**
4. Zatim kopirajte `.env.example` u `.env` fajl:

```bash
cp .env.example .env
```

5. Dodajte vaše Stripe keys u `.env` fajl:

```env
STRIPE_SECRET_KEY=sk_test_your_secret_key_here
STRIPE_PUBLISHABLE_KEY=pk_test_your_publishable_key_here
API_BASE_URL=http://localhost:5160
```

## 📱 Instalacija

```bash
flutter pub get
```

## 🚀 Kako funkcioniše

### 1. Korisnik zakazuje termin
- PetOwner bira ljubimca, uslugu, veterinara, datum i vrijeme
- Klikne **"Zakaži termin"**

### 2. Dijalog za plaćanje
- Korisnik dobija dijalog: **"Želite li da platite sada?"**
- Opcije:
  - **Plati kasnije** - termin je zakazan, ali plaćanje kasnije
  - **Plati sada** - otvara Stripe payment screen

### 3. Stripe Payment Screen
- Unos billing informacija
- **"Proceed to Payment"** dugme
- Stripe payment sheet se otvara
- Unos kartice i potvrda plaćanja

### 4. Uspešna potvrda
- Prikazuje QR kod za termin
- Prikazuje confirmation karticu
- Korisnik može da vidi termini

## 💳 Test kartice

Za testiranje u development modu:

- **Uspješna transakcija**: 4242 4242 4242 4242
- **Potrebno 3D Secure**: 4000 0027 6000 3184
- **Nedovoljno sredstava**: 4000 0000 0000 9995

**Validan datum**: Bilo koji budući datum (npr. 12/34)
**CVC**: Bilo koji 3 broja (npr. 123)
**ZIP Code**: Bilo koji 5 brojeva (npr. 12345)

## 🔒 Security

- **STRIPE_SECRET_KEY** se NIKADA ne pushuje na Git
- `.env` fajl je u `.gitignore`
- Secret key se koristi SAMO za backend API pozive
- Publishable key je OK da bude javna

## 📦 Dependencies

- `flutter_stripe: ^11.1.0` - Stripe Flutter SDK
- `qr_flutter: ^4.1.0` - QR kod generisanje
- `flutter_dotenv: ^5.1.0` - Environment variables
- `http: ^1.2.0` - HTTP requests

## 🎨 UI Komponente

### StripePaymentScreen
- Lijevi gradient background
- Billing informacije forma
- Stripe payment sheet integration
- Success screen sa QR kodom

### BookAppointmentScreen
- Dijalog nakon uspešne rezervacije
- Opcije: "Plati kasnije" ili "Plati sada"
- Navigacija na payment screen

## 🔄 Workflow

```
User → Book Appointment → Success Dialog → 
[Pay Now] → Stripe Screen → Enter Card → 
Payment Success → QR Code → View Appointments
```

## ⚠️ Troubleshooting

### Problem: "STRIPE_SECRET_KEY not found"
**Rješenje**: Provjerite da `.env` fajl postoji i da ima ispravne keys

### Problem: "Payment failed"
**Rješenje**: Provjerite da su Stripe keys ispravni i da je API URL tačan

### Problem: QR kod ne generiše
**Rješenje**: Provjerite da je `qr_flutter` pravilno instaliran

## 📝 API Endpoints

Payment se obavlja direktno sa Stripe API-jem:
- `POST /v1/customers` - Kreiranje customer-a
- `POST /v1/ephemeral_keys` - Kreiranje ephemeral key-a
- `POST /v1/payment_intents` - Kreiranje payment intent-a

Nisu potrebni backend endpoints!







