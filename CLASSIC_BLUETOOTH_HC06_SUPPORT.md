# Classic Bluetooth (HC-06) Desteği - EKLENDI ✅

## Problem & Çözüm

### Sorun
- HC-06'ya bağlanmıyor
- Yeni Bluetooth cihazı bulamıyor
- Klasik Bluetooth vs BLE karışıklığı

### Neden
HC-06'nın **iki türü** vardır:
1. **HC-06 Klasik** (Bluetooth 2.0/EDR) - Serial Port Profile
2. **HC-06 BLE** (Bluetooth Low Energy)

`flutter_blue_plus` yalnızca **BLE** destekliyor!  
Çoğu HC-06 modülü **Klasik Bluetooth** kullanıyor → Bağlanma başarısız ❌

### Çözüm
**Native Android Kotlin** ile classic Bluetooth desteği eklendi:
- Rfcomm Socket ile doğrudan bağlantı
- Serial Port Profile UUID (00001101-0000-1000-8000-00805F9B34FB)
- HC-06'ya özel implementasyon

---

## Yapılan Değişiklikler

### 1. **MainActivity.kt** - Classic Bluetooth Yönetimi

```kotlin
// HC-06 Serial Port Profile UUID
private val HC06_UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")

// Yeni Method: connectToClassicBluetooth()
// - RfcommSocket oluşturuyor
// - HC-06'ya bağlanıyor
// - Output stream hazırlıyor

// Yeni Method: sendCommand()
// - Native tarafından komut gönderiyor

// Yeni Method: disconnect()
// - Socket'i kapatıyor
```

**MethodChannel işlemleri:**
- `"connectToDevice"` - Adres ile bağlantı
- `"sendCommand"` - Komut gönderme
- `"disconnect"` - Bağlantı kesme
- `"getBondedDevices"` - Eşleştirilmiş cihazlar

### 2. **bluetooth_service.dart** - Dart Wrapper

```dart
// connectToBondedDevice()
// - Native connectToDevice() çağrıyor
// - Başarılı bağlantı dönüyor

// sendCommand()
// - Native sendCommand() kullanıyor
// - Fallback olarak BLE karakteristik yazma

// disconnect()
// - Native disconnect() çağrıyor
```

---

## Bluetooth Bağlantı Akışı

```
┌─────────────────────────────────┐
│  Cihaz Seçimi (device.address)  │
└────────────────┬────────────────┘
                 │
┌────────────────▼────────────────┐
│  connectToBondedDevice() (Dart) │
└────────────────┬────────────────┘
                 │
┌────────────────▼──────────────────────┐
│  platform.invokeMethod("connectToDevice") │
│  (MethodChannel)                       │
└────────────────┬──────────────────────┘
                 │
┌────────────────▼────────────────────┐
│  connectToClassicBluetooth() (Kotlin)│
│  - BluetoothDevice.getRemoteDevice() │
│  - createRfcommSocketToServiceRecord()│
│  - socket.connect()                   │
│  - outputStream = socket.outputStream │
└────────────────┬────────────────────┘
                 │
                 ▼
         ✅ HC-06 Bağlantı
```

---

## Komut Gönderme

```
RC Car Kontrolü
     │
     ▼
sendCommand("F") // İleri
     │
     ▼
platform.invokeMethod("sendCommand", {command: "F"})
     │
     ▼
outputStream.write("F".toByteArray())
outputStream.flush()
     │
     ▼
HC-06 Module → Arduino
     │
     ▼
Motor kontrolü
```

---

## Test Adımları

1. **Cihaz Seç:**
   - Device Selection sayfasında HC-06'yı seç
   - "Bağlanılıyor..." göstermeli

2. **Bağlantı Kontrol:**
   - Logcat'e bak: `D/BluetoothConnect: Successfully connected`
   - "Bağlandı" durumu görmeli

3. **Komut Gönder:**
   - D-Pad'e bas
   - Logcat: `D/BluetoothCommand: Sent: F`
   - HC-06 cihazı yaklaşsa kırmızı LED yanmalı

4. **LED & Kontroller:**
   - LED, Speed, Horn test et
   - Tüm komutlar HC-06'ya gitmeli

---

## Logcat Çıktısı (Beklenen)

```
D/BondedDevices: Found: HC-06 (00:1A:7D:DA:71:13)
D/BluetoothConnect: Connecting to 00:1A:7D:DA:71:13
D/BluetoothConnect: Successfully connected to 00:1A:7D:DA:71:13
D/BluetoothCommand: Sent: F
D/BluetoothCommand: Sent: V100
D/BluetoothCommand: Sent: L1
D/BluetoothConnect: Disconnected
```

---

## Teknik Detaylar

| Parametre | Değer |
|-----------|-------|
| **Protokol** | Classic Bluetooth 2.0 (EDR) |
| **Profile** | Serial Port Profile (SPP) |
| **UUID** | 00001101-0000-1000-8000-00805F9B34FB |
| **Baud Rate** | 9600 (HC-06 default) |
| **Komut Format** | ASCII (F, B, L, R, S, etc.) |

---

## Sorun Giderme

| Sorun | Çözüm |
|-------|-------|
| Bağlantı başarısız | HC-06 açık mı? Bluetooth etkin mi? |
| Komut gönderilmiyor | Bağlantı başarılı mı? `D/BluetoothCommand` log var mı? |
| "Bilinmeyen Cihaz" | Şimdi düzeltildi - cihaz adı gösteriliyor |
| Sadece eşleştirilmiş gösteriyor | Normal - yeni cihazlar tarama sırasında görülür |

---

## Uyumlu HC-06 Modülleri

✅ **Çalışır:**
- HC-06 Bluetooth 2.0/EDR (Klasik)
- Mavi PCB, zil simgesi olan
- JY-MCU Bluetooth

❌ **Çalışmaz (BLE kullanıyor):**
- HM-10 (BLE module)
- CC2541 (BLE module)
- Bazı "HC-06 BLE" varyantları

HC-06 modülün "Bilinmeyen Cihaz" vs doğru isim göstermesi test için ipucu:
- Eğer isim gösterirse → klasik Bluetooth (✅ bu kod çalışır)
- Eğer "Unknown" gösterirse → BLE olabilir (flutter_blue_plus kullan)

---

## Build Status
✅ **APK Başarıyla Derlendi**  
✅ **Kotlin Kodlanması Hatasız**  
✅ **Dart Kodlanması Hatasız**  
✅ **Hazır Dağıtım**

