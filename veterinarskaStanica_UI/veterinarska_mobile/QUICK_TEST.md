# 🚀 Brzi Test Stripe Payment

## Ako aplikacija nije još spremna
**Sačekaj još 5-10 minuta!** Prvi build traje dugo.

## Ako aplikacija JE spremna na emulatoru:

### 1️⃣ Prijavi se
- Email: `petowner@example.com` (ili bilo koji postojeći nalog)
- Password: Proveri database!

### 2️⃣ Brzi test
- Idi na **Termini** (donji menu)
- Klikni **+** (gore desno)
- Izaberi **pet**
- Izaberi **service** 
- Izaberi **veterinarian**
- Izaberi **date/time**
- Klikni **"Zakaži termin"**

### 3️⃣ Stripe Payment
Kada se pojavi dijalog:
- Klikni **"Plati sada"** (zelena dugmad)

### 4️⃣ Unesi billing info
- **Ime**: Test User
- **Email**: test@test.com  
- **Adresa**: Test Street 123
- **Pin**: 12345
- **Grad**: Sarajevo
- **Država**: Bosna i Hercegovina
- Klikni **"Proceed to Payment"**

### 5️⃣ Test kartica
```
Kartica: 4242 4242 4242 4242
Datum: 12/34
CVC: 123
```

### 6️⃣ Success! ✅
Videćeš QR kod i confirmation karticu!

---

## ⚡ Ubrzaj sledeći put

```bash
# Koristi --release za brže build-ove
flutter run --release

# Ili hot restart
flutter run
# Zatim u app: press 'r' u terminalu
```

## 🐛 Troubleshooting

### "STRIPE_SECRET_KEY not found"
- Proveri da `.env` postoji u `veterinarska_mobile/` folderu
- Proveri da su keys ispravni

### "Payment failed"
- Proveri da su Stripe keys pravi test keys
- Check console za error

### Aplikacija se pokreće jako sporo
- Prvi put = 15-20 minuta (NORMALNO!)
- Sledeći put = 30-60 sekundi
- Koristi `flutter run --profile` za brže





