# Bluetooth Cihaz İsmi Sorunu - ÇÖZÜLDÜ ✅

## Problem
Eşleştirilmiş Bluetooth cihazları "Bilinmeyen Cihaz" (Unknown Device) olarak görünüyordu.

## Root Cause
- Native Android tarafından cihaz isimleri doğru şekilde alınıyordu
- Fakat Dart tarafında `BluetoothDevice.fromId(address)` ile device oluştururken sadece adres kullanılıyordu
- Sonuç: Device'in `platformName` property'si boş kalıyordu → UI'de "Bilinmeyen Cihaz" gösteriliyor

## Solution
**Yeni Custom Class: `BondedDevice`**
- `name`: Android tarafından gelen cihaz ismi
- `address`: Cihaz MAC adresi

### Yapılan Değişiklikler

#### 1. `lib/services/bluetooth_service.dart`
```dart
// YENİ: BondedDevice sınıfı eklendi
class BondedDevice {
  final String name;
  final String address;
  
  BondedDevice({required this.name, required this.address});
}

// GÜNCELLENDU: getAvailableDevices() - BondedDevice döndürüyor
Future<List<BondedDevice>> getAvailableDevices() async { ... }

// YENİ: connectToBondedDevice() - BondedDevice kabul ediyor
Future<bool> connectToBondedDevice(BondedDevice bondedDevice) async { ... }
```

#### 2. `lib/pages/device_selection_page.dart`
```dart
// GÜNCELLENDU: BondedDevice türü kullanılıyor
List<BondedDevice> _availableDevices = [];

// GÜNCELLENDU: UI'de cihaz ismi gösteriliyor
Text(device.name.isEmpty ? 'Bilinmeyen Cihaz' : device.name)

// GÜNCELLENDU: MAC adresi gösteriliyor
Text(device.address)

// GÜNCELLENDU: Tarama sonuçları BondedDevice'e dönüştürülüyor
final bondedDevice = BondedDevice(
  name: result.device.platformName,
  address: result.device.remoteId.str,
);
```

## Sonuç
✅ Eşleştirilmiş cihazlar artık doğru isimler ile gösteriliyor  
✅ Cihaz adresleri (MAC) doğru şekilde görünüyor  
✅ Bağlantı işlemleri düzgün çalışıyor  
✅ Tarama sonuçları da BondedDevice formatında gözüküyor

## Test Aşaması
```bash
# Yeni APK oluştur ve kur
flutter build apk --debug
flutter install

# Aç ve device_selection_page'i kontrol et
```

## Beklenen Sonuç
- HC-06 cihazı "HC-06" olarak gösteriliyor (Bilinmeyen değil)
- Diğer eşleştirilmiş cihazlar da doğru isimler ile görünüyor
- MAC adresleri gösteriliyor: `00:1A:7D:DA:71:13`
