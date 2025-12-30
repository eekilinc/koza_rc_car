# 🚗 KOZA RC Car - Bluetooth Kontrol Uygulaması

[![Flutter](https://img.shields.io/badge/Flutter-3.10%2B-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0%2B-0175C2?logo=dart)](https://dart.dev)
[![Android](https://img.shields.io/badge/Android-5.0%2B-3DDC84?logo=android)](https://www.android.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

RC araba modelinizi Bluetooth aracılığıyla kontrol etmek için tasarlanmış, zengin özelliklere sahip bir Flutter uygulaması.
<img src="https://github.com/user-attachments/assets/47b4f494-45f7-47d9-bcd2-8123f7d3b06b" width="400" height="600" style="align:center;" />



---

## ✨ Özellikler

### 🎮 Kontrol Sistemi
- **D-Pad Kontrolü**: Yukarı, Aşağı, Sol, Sağ hareketi
- **Analog Joystick**: Hassas ve akıcı hareket kontrolü
- **Instant Mode**: Hızlı reaksiyonlu ateş modu
- **Ek Kontroller**: LED, Ses (Horn), Hız (0-100%)

### 📱 Bluetooth Bağlantısı
- **Classic Bluetooth** desteği (HC-06 modülleri)
- **BLE (Bluetooth Low Energy)** desteği
- **Eşlenmiş Cihazlar**: Bonded devices otomatik tarama
- **Son Bağlanan Cihazlar**: Son 5 cihaza hızlı erişim

### 💡 Bilgilendirme & Rehberlik
- **RC Kontrolü Rehberi**: D-Pad, Joystick, ve her özelliğin açıklaması
- **Bluetooth Eşleştirme Rehberi**: Adım adım klasik ve BLE eşleştirmesi
- **Bluetooth Teknolojileri**: Classic vs BLE karşılaştırması
- **Sinyal Gücü Göstergesi**: Bağlantı kalitesini göster

### 🎨 Kullanıcı Arayüzü
- Modern Material Design
- Türkçe UI
- Responsive layout
- Koyu/Açık mod

---

## � Ekran Görüntüleri

### Ana Sayfa & D-Pad Kontrolü
```
┌─────────────────────────────┐
│   Koza RC Car               │
│   ⊙ Bağlı Değil     [Bağlan]│
│                             │
│   Seçim                     │
│   [D-Pad] Joystick Özellik  │
│                             │
│        ▲                    │
│      ◄ ◆ ►                  │
│        ▼                    │
│                             │
│   Son Komut: Hiçbiri        │
│           [ⓘ]               │
└─────────────────────────────┘
```

- **Bağlı Değil**: Bluetooth bağlantı durumu
- **D-Pad**: 4 yön hareketi
- **Joystick**: Analog kontrol (alternatif)
- **Özellik**: LED, Ses, Hız ayarları
- **Help Button (ⓘ)**: Kontroller hakkında bilgi

---

## �🚀 Hızlı Başlangıç

### 📲 Direkt İndir (QR Code ile)

Cihazında QR okuyucu aç ve tara:

![Download APK QR Code](https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=https://github.com/eekilinc/koza_rc_car/releases/download/v1.0.0/koza_rc_car_v1.0.0.apk)

[📥 APK'yı İndir (47 MB)](https://github.com/eekilinc/koza_rc_car/releases/download/v1.0.0/koza_rc_car_v1.0.0.apk)

---

### Adım 1: Uygulamayı Yükle
```bash
# APK'yı cihazına kur
adb install app-release.apk
```

### Adım 2: Bluetooth Eşleştir
1. Android cihazında **Ayarlar** → **Bluetooth** aç
2. **Benim RC Arabaları Ara** (veya cihaz adını ara)
3. Cihazı seç ve **Eşleştir** butonuna tıkla

### Adım 3: Bağlan ve Kontrol Et
1. Uygulamayı aç
2. Bluetooth modu seç (Classic veya BLE)
3. Cihazını listeden seç ve **Bağlan** tıkla
4. Kontrolü **D-Pad** veya **Joystick** ile yap

---

## 🎮 Kontroller Rehberi

### D-Pad (Yön Tuşları)
```
     ↑
   ←   →
     ↓
```
- Dört yön hareketi
- Sağlam ve güvenilir
- Tam hız kontrolü

### Joystick (Analog)
```
    ↗ ↑ ↖
   → J ←
    ↘ ↓ ↙
```
- Hassas hareket kontrolü
- X ve Y ekseninde bağımsız kontrol
- Smooth ve akıcı

### Instant Mode
- Dokunup bırak = Hızlı ateş
- Hızlı reaksiyonlu
- Single tap işlemi

### Ek Kontroller
- **LED**: Açma/Kapama (🔦)
- **Horn**: Ses/Sinyal (📣)
- **Speed**: Hız ayarı 0-100% (🏎️)

---

## 📱 Gereksinimler

### Yazılım
- **Flutter**: 3.10.0 veya daha yeni
- **Dart**: 3.0.0 veya daha yeni
- **Android SDK**: API 21 (Android 5.0) veya daha yeni

### Donanım
- **Bluetooth Modülü**: HC-06 veya BLE uyumlu modül
- **Android Cihaz**: 5.0 veya daha yeni
- **Bağlantı**: Aktif Bluetooth

---

## 🔧 Teknik Detaylar

### Mimari
```
┌─────────────────┐
│   Flutter UI    │  (Device Selection, RC Controller)
├─────────────────┤
│  Dart Service   │  (Bluetooth Service)
├─────────────────┤
│  Native Android │  (Kotlin - Bluetooth Discovery)
├─────────────────┤
│  Bluetooth API  │  (Classic + BLE)
└─────────────────┘
```

### Bağımlılıklar
- `flutter_blue_plus: ^1.36.8` - Bluetooth kontrolü
- `permission_handler: ^12.0.1` - Sistem izinleri
- `shared_preferences: ^2.3.1` - Cihaz geçmişi

### Dosya Yapısı
```
lib/
├── main.dart
├── pages/
│   ├── device_selection_page.dart
│   ├── rc_car_controller_page.dart
│   └── command_settings_page.dart
├── services/
│   └── bluetooth_service.dart
├── widgets/
│   ├── dpad_controller.dart
│   ├── joystick_controller.dart
│   └── flash_buttons_controller.dart
├── models/
│   └── command_config.dart
└── utils/
    └── logger.dart
```

---

## ❓ Sık Sorulan Sorular

**S: Cihazım Bluetooth bulmuyor?**
A: Bluetooth eşleştirme rehberini aç (ℹ️ buton). Android Ayarlarından manuel eşleştirme yapmanız gerekebilir.

**S: Bağlantı kopuyor?**
A: Sinyal gücü kontrol et. Cihaz çok uzaksa mesafeyi azalt veya modülün güç kaynağını kontrol et.

**S: Classic vs BLE ne farkı?**
A: Uygulamadaki info butonundan bilgi al. HC-06 genellikle Classic kullanır.

---

## 📚 Dokümantasyon

Daha detaylı bilgi için:
- [QUICK_START_GUIDE.md](QUICK_START_GUIDE.md) - Kurulum ve başlangıç
- [FINALIZATION_REPORT.md](FINALIZATION_REPORT.md) - Teknik detaylar
- [TESTING_CHECKLIST.md](TESTING_CHECKLIST.md) - Test senaryoları
- [PROJECT_INDEX.md](PROJECT_INDEX.md) - Dosya referansları

---

## 📄 Lisans

Bu proje MIT lisansı altında yayınlanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakınız.

---

## 🤝 Katkı

Katkılar memnuniyetle karşılanır! Önerilerin veya hata raporlarının için issue açabilirsin.

---

## 👨‍💻 Geliştirici

**KOZA RC Car Project** - 2025

---

**🌟 Beğendiysen yıldız ver!**
