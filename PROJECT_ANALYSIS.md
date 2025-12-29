# RC Araba Kontrol Uygulaması - Proje Analizi ve Kurulum

## 📋 Proje Analizi

### Mevcut Durum
Bu proje, başlangıçta boş bir Flutter şablonundan başlayan, temel sayaç uygulamasına sahipti.

### Gerçekleşen Değişiklikler

#### 1. **Bağımlılıklar Eklendi** (pubspec.yaml)
```yaml
flutter_blue_plus: ^1.36.8   # Bluetooth iletişimi için
permission_handler: ^12.0.1  # İzin yönetimi için
```

#### 2. **Proje Yapısı Oluşturuldu**
```
lib/
├── models/
│   └── command_config.dart          # Komut yapılandırması
├── services/
│   └── bluetooth_service.dart       # Bluetooth yönetimi
├── widgets/
│   ├── dpad_controller.dart         # D-Pad kontrol
│   └── joystick_controller.dart     # Joystick kontrol
└── pages/
    ├── rc_car_controller_page.dart  # Ana kontrol sayfası
    ├── device_selection_page.dart   # Cihaz seçimi
    └── command_settings_page.dart   # Ayarlar
```

#### 3. **Android İzinleri Yapılandırılması**
AndroidManifest.xml'e aşağıdaki izinler eklendi:
- `BLUETOOTH` - Bluetooth erişimi
- `BLUETOOTH_ADMIN` - Bluetooth yönetimi
- `BLUETOOTH_SCAN` - Cihaz taraması
- `BLUETOOTH_CONNECT` - Cihaza bağlanma
- `ACCESS_FINE_LOCATION` - Lokasyon (Bluetooth taraması için gerekli)
- `ACCESS_COARSE_LOCATION` - Yaklaşık lokasyon

## 🎯 Uygulamanın Özellikleri

### 1. **Bluetooth Bağlantısı**
- HC-06 Bluetooth modülü ile cihazlara bağlanma
- Otomatik cihaz taraması
- Bağlantı durumu gösterimi
- Graceful disconnect

### 2. **İki Kontrol Modu**

#### D-Pad Modu
- 4 yön tuşu (Yukarı, Aşağı, Sol, Sağ)
- Tuş basılı tutma algılama
- Görsel geri bildirim

#### Joystick Modu
- Analog joystick kontrolü
- Ölü bölge (Deadzone) desteği
- Aksiyon tespit sistemi
- Smooth kontrol

### 3. **Konfigüre Edilebilir Komutlar**
- İleri (F)
- Geri (B)
- Sol (L)
- Sağ (R)
- Dur (S)

Her komut özelleştirilebilir, Arduino tarafındaki komutlara eşleştirilebilir.

### 4. **Kontrol Takibi**
- Son gönderilen komut görüntüleme
- Toplam gönderilen komut sayısı
- Gerçek zamanlı istatistikler
- Komut referans tablosu

## 🔧 Teknik Detaylar

### Bluetooth Yönetimi (BluetoothServiceManager)
```dart
// Singleton pattern kullanır
- sendCommand(String command) - Komut gönderme
- connectToDevice(BluetoothDevice) - Cihaza bağlanma
- disconnect() - Bağlantı kesme
- scanForDevices() - Cihaz taraması
- isBluetoothAvailable() - Bluetooth kontrolü
```

### Komut Yapılandırması (CommandConfig)
```dart
CommandConfig(
  forward: 'F',
  backward: 'B',
  left: 'L',
  right: 'R',
  stop: 'S',
)
```

Sayısallaştırma da desteklenir (1, 2, 3, vb.) veya özel karakterler (!, @, #, vb.)

### Kontrol Widget'ları
- **DPadController**: Dokunmatik tuş tabı
- **JoystickController**: Analog joystick

Her ikisi de özelleştirilebilir boyut ve responsivlık seçeneklerine sahip.

## 📱 Uygulamayı Çalıştırma

### 1. Bağımlılıkları Yükleme
```bash
cd /workspaces/benim_flutter_projem
flutter pub get
```

### 2. Uygulamayı Çalıştırma
```bash
# Android cihaz üzerinde
flutter run

# Belirli cihaz seçerek
flutter run -d device_id

# Debug modda
flutter run --debug

# Release modda
flutter run --release
```

### 3. Erişilebilecek Sayfalar
1. **RC Car Controller** (Ana sayfa)
   - Bağlantı yönetimi
   - Kontrol modu seçimi
   - D-Pad veya Joystick kontrolü

2. **Device Selection** (Cihaz Seçimi)
   - Taraılan cihazları gösterir
   - Cihaza bağlantı sağlar

3. **Command Settings** (Ayarlar)
   - Komutları özelleştirme
   - Ayarları kaydetme

## 🤖 Arduino Entegrasyonu

### Gerekli Hardware
1. **Arduino (Uno, Nano, Mega, vb.)**
2. **HC-06 Bluetooth Modülü**
3. **Motor Driver (L298N)**
4. **DC Motors (2x)**
5. **Power Supply**

### Bağlantı Şeması

#### HC-06 Bluetooth
```
HC-06 Pin    Arduino Pin
VCC          5V
GND          GND
TX           RX (Pin 0) veya Software Serial (Pin 8)
RX           TX (Pin 1) veya Software Serial (Pin 7)
```

#### L298N Motor Driver
```
L298N Pin    Arduino Pin
IN1          Pin 5
IN2          Pin 6
IN3          Pin 9
IN4          Pin 10
GND          GND
+5V          5V / Ayrı Power Supply
OUT1/OUT2    Motor 1
OUT3/OUT4    Motor 2
```

### Arduino Kodu
Proje klasöründe `arduino_sketch.ino` dosyası bulunur. Bu dosya:
- HC-06 üzerinden komut alır
- Motor pinlerini kontrol eder
- Gelecek komut sayısını serial'e yazdırır

### Temel Komutlar
- **F**: İleri git
- **B**: Geri git
- **L**: Sol dön / sola kayma
- **R**: Sağ dön / sağa kayma
- **S**: Dur

Tüm komutlar case-insensitive'dir.

## 🔍 Sorun Giderme

### Bluetooth Bağlantısı Kurulamıyor
1. **HC-06 Kontrolü**
   - Cihaz açılı mı? (LED yanıp sönüyor mu?)
   - Baud rate 9600 mu?
   - TX/RX kablolama doğru mu?

2. **Android İzinleri**
   - Ayarlar → Uygulamalar → RC Car Controller
   - Bluetooth ve Konum izinleri verilmiş mi?

3. **Bluetooth Modülü Pairing**
   - Cihaz paired mi?
   - Pairing kodu 1234 veya 0000

### Komutlar Gönderiliyor ama Araba Hareket Etmiyor
1. **Arduino Kontrolü**
   - Serial Monitor ile HC-06'dan komut alıyor mu?
   - Motor pinleri doğru yapılandırılmış mı?
   - Motor güçü yeterli mi?

2. **L298N Driver**
   - Tüm kablolar bağlı mı?
   - Power supply yeterli mi?
   - Motor test edildi mi?

### Joystick Kontrolü Garip Davranıyor
- Deadzone ayarını kontrol edin (varsayılan: 0.2)
- Dirençle (resistance) kontrol edin
- Kalibrasyon gerekiyorsa Arduino tarafındaki PWM değerlerini ayarlayın

## 🚀 İleri Özellikler

### Eklenebilecek Özellikler
- [ ] Hız kontrolü (0-255)
- [ ] Kamera feed
- [ ] Sensör okumaları
- [ ] Hareket kaydı ve tekrar
- [ ] Otonom mod
- [ ] Firebase entegrasyonu
- [ ] Çoklu cihaz desteği
- [ ] Gyroscope kontrol
- [ ] Line follower
- [ ] Obstacle avoidance

### Performance Optimizasyonları
- Komut gönderme hızı ayarlanabilir
- Ekran yenileme frekansı optimize edilebilir
- Bluetooth buffer yönetimi

## 📚 Dosya Açıklamaları

### main.dart
- Entry point
- İzin istekleri
- App tema yapılandırması

### models/command_config.dart
- Komut verisi modeli
- JSON seri/deseri
- Varsayılan komutlar

### services/bluetooth_service.dart
- Bluetooth yönetimi (Singleton)
- Cihaz bağlantısı
- Komut gönderimi
- Cihaz taraması

### widgets/dpad_controller.dart
- 4 tuşlu kontrol
- Basılı tutma algılama
- Komut gönderme

### widgets/joystick_controller.dart
- Analog joystick
- Deadzone
- Yön hesaplama

### pages/rc_car_controller_page.dart
- Ana sayfa
- Kontrol modu değişimi
- Bağlantı yönetimi

### pages/device_selection_page.dart
- Cihaz taraması
- Bağlantı kurma
- Cihaz listesi

### pages/command_settings_page.dart
- Komut özelleştirmesi
- Ayarları kaydetme

## 📞 Destek ve Sorular

Eğer sorular veya sorunlar yaşıyorsanız:
1. Serial Monitor ile Arduino çıktısını kontrol edin
2. Flutter logs'u kontrol edin (`flutter logs`)
3. Android LogCat'i kontrol edin
4. HC-06 baud rate'ini doğrulayın (varsayılan: 9600)

## 📄 Lisans
MIT License

---

**Hazırlayan**: Flutter RC Car Kontrol Projesi
**Tarih**: 2024
**Durum**: Aktif Geliştirme
