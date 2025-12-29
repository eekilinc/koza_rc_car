# Hızlı Başlangıç Rehberi

## 1️⃣ İlk Kurulum (5 dakika)

### Android Cihazda Hazırlık
```bash
# Proje klasöründe
cd /workspaces/benim_flutter_projem

# Bağımlılıkları yükle
flutter pub get

# Çalıştır
flutter run
```

## 2️⃣ Arduino Kurulumu

### Gerekli Malzemeleri Hazırlayın:
- Arduino Uno/Nano
- HC-06 Bluetooth Modülü
- L298N Motor Driver
- 2x DC Motor
- 2x Tekerlek
- Robot Şasi
- 5V Power Supply (Motor için)

### Arduino Kodu Yükle:
1. Arduino IDE'yi aç
2. `arduino_sketch.ino` dosyasını aç
3. Kodu Arduino'ya yükle
4. Serial Monitor'u aç (9600 baud)

### Kablolama (L298N):
```
L298N       Arduino
IN1    -->  Pin 5
IN2    -->  Pin 6
IN3    -->  Pin 9
IN4    -->  Pin 10
GND    -->  GND
```

### Kablolama (HC-06):
```
HC-06       Arduino
VCC    -->  5V
GND    -->  GND
TX     -->  Pin 8 (Software Serial RX)
RX     -->  Pin 7 (Software Serial TX)
```

## 3️⃣ Uygulamayı Kullanma

### Adım 1: Bluetooth Cihazını Seç
1. "Connect" butonuna tıkla
2. "Scan" düğmesine basarak cihazları tara
3. HC-06'yı seç ve bağlan
4. Yeşil gösterge görünecektir

### Adım 2: Kontrol Modunu Seç
- **D-Pad**: Tuş tabı kontrolü için
- **Joystick**: Smooth analog kontrol için

### Adım 3: Arabayı Kontrol Et
- **D-Pad Modu**:
  - ▲ = İleri git
  - ▼ = Geri git
  - ◄ = Sol dön
  - ► = Sağ dön

- **Joystick Modu**:
  - Joystick'i hareket ettir
  - Otomatic direction detection

### Adım 4: Ayarları Özelleştir (İsteğe Bağlı)
1. ⚙️ butonuna tıkla
2. Her komut için karakter ayarla
3. "Save" butonuna basınız

## 🐛 Hızlı Sorun Çözme

| Sorun | Çözüm |
|-------|-------|
| Bluetooth bulamıyor | HC-06'nın açık olduğunu kontrol et |
| Bağlantı başarısız | Pairing kodunu dene (1234 veya 0000) |
| Komutlar gönderiliyor ama hareket yok | Motor pinlerini ve güçü kontrol et |
| Joystick garip | Deadzone'u ayarla veya joystick'i kalibre et |
| Serial Monitor'da komut yok | TX/RX kablolarını ters bağladığını kontrol et |

## 📝 Komut Referansı

**Varsayılan Komutlar:**
```
F veya f  → İleri git
B veya b  → Geri git
L veya l  → Sol dön
R veya r  → Sağ dön
S veya s  → Dur
```

**Özel Komutlar (Arduino tarafında tanımlı):**
Arduino kodu üzerinde kendi komutlarını ekleyebilirsin:
```cpp
case 'x':  // Özel komut
  // Özel aksiyon
  break;
```

## 💡 İpuçları

1. **Motor Hızı**: Arduino'da `motorSpeed` değişkenini değiştir (0-255)
2. **Joystick Deadzone**: `JoystickController` widget'ında `deadzone` parametresi
3. **Komut Taraması**: Last Command sekmesinde gönderilen komutları görebilirsin
4. **Debug**: Serial Monitor'u açık tut ve uygulamayı çalıştır

## 🎓 Öğrenme Kaynakları

- [Flutter Documentation](https://flutter.dev/docs)
- [Flutter Blue Plus](https://pub.dev/packages/flutter_blue_plus)
- [Arduino Motor Control](https://www.arduino.cc/en/Tutorial/DC%20Motor%20Control)
- [HC-06 Documentation](https://www.instructables.com/HC-06-Bluetooth-Module-with-Arduino/)

## 🚀 Sonraki Adımlar

1. **Hız Kontrolü Ekle**
   - Joystick'ten hız değeri okuyarak PWM ayarla

2. **Sensör Entegrasyonu**
   - Ultrasonic sensör
   - IR sensör
   - Çizgi takip sensörü

3. **Kamera Ekleme**
   - USB Kamera
   - ESP32-CAM

4. **Otonom Mod**
   - Önceden tanımlı yolları kaydet ve oynat

---

**Başarılar!** 🎉

Herhangi bir sorun için SETUP_GUIDE.md ve PROJECT_ANALYSIS.md dosyalarını kontrol et.
