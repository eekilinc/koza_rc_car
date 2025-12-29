# RC Car Bluetooth Controller

Flutter uygulaması HC-06 Bluetooth modülü üzerinden Arduino tabanlı uzaktan kontrollü araba kontrolü için.

## Özellikler

- **Bluetooth Bağlantısı**: HC-06 Bluetooth modülü ile Arduino'ya gerçek zamanlı bağlantı
- **İki Kontrol Modu**: 
  - D-Pad (Yön Tuşları)
  - Joystick (Analog Joystick)
- **Konfigüre Edilebilir Komutlar**: 
  - İleri (F)
  - Geri (B)
  - Sol (L)
  - Sağ (R)
  - Dur (S)
- **Canlı Komut İzleme**: Son gönderilen komutları ve toplam komut sayısını görüntüleme
- **Komut Ayarları**: Arayüzden kontrol komutlarını özelleştirme

## Proje Yapısı

```
lib/
├── main.dart                          # Ana entry point
├── models/
│   └── command_config.dart            # Komut konfigürasyonu modeli
├── services/
│   └── bluetooth_service.dart         # Bluetooth iletişim servisi
├── widgets/
│   ├── dpad_controller.dart           # D-Pad kontrol widget'ı
│   └── joystick_controller.dart       # Joystick kontrol widget'ı
└── pages/
    ├── rc_car_controller_page.dart    # Ana kontrol sayfası
    ├── device_selection_page.dart     # Cihaz seçim sayfası
    └── command_settings_page.dart     # Komut ayarları sayfası

arduino_sketch.ino                     # Arduino için örnek kod
```

## Gereksinimler

### Flutter Paketleri
- `flutter_blue_plus`: Bluetooth iletişimi
- `permission_handler`: İzin yönetimi

### Android İzinleri
```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### Hardware Gereksinimleri

#### HC-06 Bluetooth Modülü Bağlantısı:
```
HC-06       Arduino
-----       -------
VCC    -->  5V
GND    -->  GND
TX     -->  RX (Pin 0) veya Software Serial (Pin 8)
RX     -->  TX (Pin 1) veya Software Serial (Pin 7)
```

#### Motor Driver (L298N) Bağlantısı:
```
L298N       Arduino
-----       -------
IN1    -->  Pin 5
IN2    -->  Pin 6
IN3    -->  Pin 9
IN4    -->  Pin 10
GND    -->  GND
+5V    -->  5V (veya ayrı güç kaynağı)
```

## Kurulum

### 1. Projeyi Klonlayın
```bash
cd /workspaces/benim_flutter_projem
flutter pub get
```

### 2. Android Ayarları

AndroidManifest.xml dosyası zaten Bluetooth izinleri içerecek şekilde yapılandırılmıştır.

### 3. Uygulamayı Çalıştırın
```bash
flutter run
```

## Kullanım

### 1. Cihaza Bağlanma
- **Connect** butonuna tıklayın
- Eşleştirilmiş HC-06 cihazları listesinden seçin
- Veya **Scan** düğmesini kullanarak yeni cihazları tarayın
- Bağlantı kurulduktan sonra yeşil gösterge görünecektir

### 2. Kontrol Modu Seçimi
- **D-Pad**: Dört yön tuşu ile kontrol
- **Joystick**: Analog joystick ile kontrol

### 3. Araç Kontrolü
- **D-Pad Modu**: 
  - ▲ = İleri
  - ▼ = Geri
  - ◄ = Sol
  - ► = Sağ
  
- **Joystick Modu**:
  - Joystick'i hareket ettirerek yön seçin
  - Merkezde ölü bölge (deadzone) vardır
  - Kontrol noktasından geri çekerken otomatik dur

### 4. Komut Ayarları
- ⚙️ **Ayarlar** butonuna tıklayın
- Her komut için özel karakterler tanımlayın
- **Kaydet** butonuna tıklayın

## Arduino Kodu (Örnek)

`arduino_sketch.ino` dosyasında tam bir örnek kod bulunmaktadır.

### Temel Komutlar:
```cpp
'F' veya 'f' -> İleri git
'B' veya 'b' -> Geri git
'L' veya 'l' -> Sol dön
'R' veya 'r' -> Sağ dön
'S' veya 's' -> Dur
```

### Arduino Kodu Yükleme:
1. Arduino IDE'yi açın
2. `arduino_sketch.ino` dosyasını Arduino IDE'de açın
3. Doğru board ve port seçin
4. **Upload** butonuna tıklayın

## HC-06 Bluetooth Modülü Konfigürasyonu

### Varsayılan Ayarlar:
- **Baud Rate**: 9600
- **Varsayılan Pairing Kodu**: 1234 veya 0000

### AT Komutları (İsteğe Bağlı):
```
AT+BAUD4     -> 9600 baud rate ayarla
AT+NAME      -> Cihaz adını göster
AT+PSWD      -> Pairing kodunu göster
AT+VERSION   -> Firmware sürümünü göster
```

**Not**: AT komutları kullanmak için cihaz başlatıldıktan sonra (LED yanıp sönüyorken) gönderilmelidir.

## Sorun Giderme

### Bluetooth Bağlantısı Kurulamıyor
1. HC-06 modülünü kontrol edin (LED yanıp sönüyor mu?)
2. Arduino seri haberleşme pinlerini kontrol edin
3. HC-06 baud rate'ini kontrol edin (9600)
4. Cihaz izinlerini kontrol edin: Ayarlar -> Uygulamalar -> RC Car -> İzinler

### Komutlar Gönderilmiyor
1. Bluetooth bağlantısının kurulu olduğunu kontrol edin (yeşil gösterge)
2. Arduino'da Serial Monitor ile komutları kontrol edin
3. Komut konfigürasyonunu kontrol edin (Ayarlar)

### Arduino Komutları Alıyor ama Hareket Etmiyor
1. Motor bağlantılarını kontrol edin
2. Motor güç kaynağını kontrol edin
3. Motor driver'ın (L298N) doğru konfigüre edildiğini kontrol edin
4. Arduino pinlerinin doğru olduğunu kontrol edin

## Geliştirme Fikirleri

- [ ] Hız kontrol (1-9 seviyeleri)
- [ ] Kamera feed ekranı
- [ ] Sensör okumaları (mesafe, sıcaklık, vb.)
- [ ] Hareket geçmişi kaydı
- [ ] Otonom mod (önceden kaydedilmiş yolları tekrarlama)
- [ ] Çoklu cihaz desteği
- [ ] Firebase entegrasyonu (bulut kaydı)
- [ ] Dokunmatik pad kontrolü
- [ ] Gyroscope kontrol
- [ ] Motor hız ölçümü (RPM)

## Lisans

MIT License

## Yazar

Uzaktan kontrollü araba Bluetooth projesi

## İletişim

Herhangi bir soru veya öneriye açığız.

---

**Not**: Bu proje eğitim amaçlıdır. Ticari kullanım için gerekli tüm güvenlik testlerini yapınız.
