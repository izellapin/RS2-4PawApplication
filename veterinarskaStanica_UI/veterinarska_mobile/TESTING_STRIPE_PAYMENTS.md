# 🧪 Kako da testirate Stripe Payment na frontendu

## ✅ Status implementacije
- ✅ Stripe Payment Screen kreiran
- ✅ Integracija sa booking flow-om
- ✅ QR kod generisanje nakon uspešnog plaćanja
- ✅ Sve UI komponente implementirane

## 📝 Koraci za testiranje

### 1. Kreirajte Stripe nalog (ako već nemate)
1. Idite na [Stripe Dashboard](https://dashboard.stripe.com/register)
2. Registrujte se sa email-om i passwordom
3. Stripe će vam automatski dati test mode

### 2. Dobavite Stripe test keys
1. U Stripe Dashboard, idite na **Developers** > **API Keys**
2. Kopirajte vaše test keys:
   - **Publishable key** (počinje sa `pk_test_`)
   - **Secret key** (počinje sa `sk_test_`)

### 3. Kreirajte `.env` fajl
U folderu `veterinarskaStanica_UI/veterinarska_mobile/` kreirajte `.env` fajl:

```bash
# Stripe Payment Configuration
STRIPE_SECRET_KEY=sk_test_YOUR_ACTUAL_SECRET_KEY_HERE
STRIPE_PUBLISHABLE_KEY=pk_test_YOUR_ACTUAL_PUBLISHABLE_KEY_HERE

# Backend API URL
API_BASE_URL=http://localhost:5160
```

**Primer:**
```
STRIPE_SECRET_KEY=sk_test_51ABC123DEF456GHI789...
STRIPE_PUBLISHABLE_KEY=pk_test_51XYZ789ABC123DEF456...

API_BASE_URL=http://localhost:5160
```

### 4. Pokrenite aplikaciju
```bash
cd veterinarskaStanica_UI/veterinarska_mobile
flutter pub get
flutter run
```

### 5. Testirajte payment flow

#### Korak 1: Login
- Prijavite se u aplikaciju sa postojećim nalogom

#### Korak 2: Zakažite termin
1. Idite na **Pocetna** ili **Ljubimci**
2. Dodajte ljubimca ako nemate (ikonica kućice sa +)
3. Idite na **Termini** i kliknite **+** za novo zakazivanje
4. Izaberite:
   - Pet
   - Service
   - Veterinarian
   - Date i Time
   - Reason
5. Kliknite **"Zakaži termin"**

#### Korak 3: Payment dijalog
- Nakon uspešnog zakazivanja, pojaviće se dijalog:
  - **"Plati kasnije"** - termin je zakazan bez plaćanja
  - **"Plati sada"** - idi na Stripe payment screen

#### Korak 4: Stripe Payment Screen
1. Kliknite **"Plati sada"**
2. Unesite billing informacije:
   - **Ime**: Bilo koji naziv
   - **Email**: test@example.com
   - **Adresa**: Bilo koja adresa
   - **Pin Code**: 12345
   - **Grad**: Sarajevo
   - **Država**: Bosna i Hercegovina
3. Kliknite **"Proceed to Payment"**

#### Korak 5: Payment Sheet
Stripe payment sheet će se otvoriti. Unesite test karticu:

**Test kartica:**
- **Kartica**: 4242 4242 4242 4242
- **Datum**: 12/34 (ili bilo koji budući datum)
- **CVC**: 123 (ili bilo koji 3 broja)
- **ZIP**: 12345

#### Korak 6: Uspešna transakcija
- Kliknite **"Pay"** u payment sheet-u
- Nakon uspešnog plaćanja:
  - ✅ QR kod se prikazuje
  - ✅ Confirmation kartica sa detaljima
  - ✅ Možete da viewajete zakazane termine

## 💳 Stripe test kartice

### Uspješna transakcija
```
Kartica: 4242 4242 4242 4242
Datum: bilo koji budući (npr. 12/34)
CVC: bilo koji 3 broja (npr. 123)
```

### Potrebno 3D Secure
```
Kartica: 4000 0027 6000 3184
```

### Nedovoljno sredstava
```
Kartica: 4000 0000 0000 9995
```

### Karta odbijena
```
Kartica: 4000 0000 0000 3238
```

## 🔍 Troubleshooting

### Problem: `.env` file not found
**Rješenje:**
1. Proverite da ste kreirali `.env` fajl u `veterinarska_mobile/` folderu
2. Uverite se da je fajl kreiran (nije samo renamed)
3. Pokrenite `flutter clean` i `flutter pub get`

### Problem: `STRIPE_SECRET_KEY not found`
**Rješenje:**
1. Proverite da je `.env` fajl u pravom folderu
2. Proverite da su keys uneseni bez greške
3. Proverite da koristite test keys (počinju sa `sk_test_` i `pk_test_`)

### Problem: Payment sheet se ne otvara
**Rješenje:**
1. Proverite da su Stripe keys ispravni
2. Proverite internet konekciju
3. Pogledajte konzolu za error poruke

### Problem: `PlatformException` error
**Rješenje:**
- Stripe keys nisu ispravni
- API URL nije ispravan
- Check console za detail error

## 📱 Features koje su implementirane

### ✅ Implementirano
- Billing form sa validacijom
- Stripe payment sheet integration
- Customer creation
- Payment intent creation
- Success screen sa QR kodom
- Confirmation kartica sa detaljima
- Navigacija iz booking flow-a

### ⚠️ Napomena
- **Sigurnosna preporuka**: Trenutna implementacija koristi STRIPE_SECRET_KEY direktno sa frontenda, što NIJE preporučeno za produkcionu verziju
- Za produkciju, trebalo bi da se koristi backend server za payment intent kreiranje
- Za trenutno testiranje, ovo je OK

## 🎯 Workflow

```
1. Korisnik zakazuje termin
   ↓
2. Dialog: "Želite li da platite sada?"
   ↓
3a. "Plati kasnije" → Termin zakazan bez plaćanja
   ↓
3b. "Plati sada" → Stripe Payment Screen
   ↓
4. Unos billing informacija
   ↓
5. Klik "Proceed to Payment"
   ↓
6. Stripe payment sheet se otvara
   ↓
7. Unos kartice (test kartica)
   ↓
8. Klik "Pay"
   ↓
9. Success! QR kod i confirmation
   ↓
10. View Appointments
```

## 📞 Testiranje sa drugim nalozima
Možete kreirati više korisnika i testirati sa različitim pet owners i veterinarians.

**Default test credentials:**
- Email: petowner@example.com
- Password: TestPass123!

---

## ✅ Finalni Checklist
- [ ] Kreiran `.env` fajl sa Stripe keys
- [ ] Stripe keys su test mode (počinju sa `sk_test_` i `pk_test_`)
- [ ] Aplikacija pokrenuta (`flutter run`)
- [ ] Prijavljeni ste u aplikaciju
- [ ] Ima te barem jednog ljubimca
- [ ] Zakazali ste termin
- [ ] Odabrali "Plati sada"
- [ ] Uneli billing informacije
- [ ] Uneli test karticu (4242...)
- [ ] Vidite QR kod nakon plaćanja

---

**Srećno sa testiranjem!** 🎉





