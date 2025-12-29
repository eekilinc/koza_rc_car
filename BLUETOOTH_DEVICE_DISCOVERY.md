# Bluetooth Device Discovery Implementation

## Problem Solved
**Issue:** Device selection page wasn't showing any Bluetooth devices, not even bonded/paired devices that exist in Android system settings.

**Root Cause:** `flutter_blue_plus.connectedSystemDevices` only returns **currently connected** devices, not **bonded/paired** devices. To access the full list of bonded devices, Android native code must be used.

---

## Solution: Platform Channels (Method Channel)

### Architecture
```
Device Selection Page (Dart)
           ↓
BluetoothServiceManager.getAvailableDevices()
           ↓
MethodChannel: "com.kozaakademi.rc_car/bluetooth"
           ↓
MainActivity.kt: getBondedDevices()
           ↓
BluetoothAdapter.getBondedDevices()
```

---

## Implementation Details

### 1. Dart Side - `lib/services/bluetooth_service.dart`

**Added MethodChannel constant:**
```dart
import 'package:flutter/services.dart';

static const platform = MethodChannel('com.kozaakademi.rc_car/bluetooth');
```

**Updated getAvailableDevices() method:**
- Calls native Android method: `platform.invokeMethod('getBondedDevices')`
- Receives List of bonded devices as Map objects with `{name, address}` keys
- Converts each device to `fbp.BluetoothDevice.fromId(address)`
- **Fallback:** If native call fails, falls back to `connectedSystemDevices`
- **Error handling:** Catches PlatformException and logs detailed messages

### 2. Android Side - `android/app/src/main/kotlin/com/example/benim_flutter_projem/MainActivity.kt`

**New implementation:**
- Extends FlutterActivity (no changes to inheritance)
- Overrides `configureFlutterEngine()` to set up MethodChannel
- Implements `getBondedDevices()` native function that:
  - Gets BluetoothAdapter instance
  - Checks if adapter is enabled
  - Iterates through `bluetoothAdapter.bondedDevices`
  - Returns List of Maps with device name and MAC address
  - Logs all discovered devices to Logcat
  - Handles exceptions gracefully

**Key imports:**
```kotlin
import io.flutter.plugin.common.MethodChannel
import android.bluetooth.BluetoothAdapter
```

---

## Data Flow

### From Device to UI
1. User opens Device Selection page
2. `loadAvailableDevices()` calls `getAvailableDevices()`
3. Dart sends MethodChannel request: `invokeMethod('getBondedDevices')`
4. Kotlin code queries Android BluetoothAdapter
5. Kotlin returns: `[{name: "HC-06", address: "00:1A:7D:DA:71:13"}, ...]`
6. Dart converts to BluetoothDevice objects
7. UI displays devices with styling:
   - **Bonded devices:** Blue background + "Eşleşti" badge
   - **Available devices:** Standard gray background

---

## Android Permissions Required

All permissions are already configured in `AndroidManifest.xml`:
- `android.permission.BLUETOOTH` - Required for Bluetooth on older Android
- `android.permission.BLUETOOTH_ADMIN` - Required for bonding
- `android.permission.BLUETOOTH_SCAN` - Required for scanning (Android 12+)
- `android.permission.BLUETOOTH_CONNECT` - Required for connecting (Android 12+)
- `android.permission.ACCESS_FINE_LOCATION` - Used by system for scanning
- `android.permission.ACCESS_COARSE_LOCATION` - Used by system for scanning

---

## Expected Behavior

### When Device Selection Page Opens
1. ✅ Bonded devices appear immediately (from Android native call)
2. ✅ Auto-scan starts to discover new devices (700ms delay, 15s duration)
3. ✅ Bonded devices remain visible even if disconnected
4. ✅ New devices appear as they are discovered
5. ✅ Tap any device to initiate connection

### Logcat Output
When bonded devices are found, you'll see in Logcat:
```
D/BondedDevices: Found: HC-06 (00:1A:7D:DA:71:13)
D/BondedDevices: Found: JBL Speaker (00:1A:7D:DA:71:14)
```

---

## Testing Checklist

- [ ] Android system settings shows bonded devices
- [ ] App opens Device Selection page
- [ ] Bonded devices appear immediately with blue background
- [ ] "Eşleşti" badge shows on bonded devices
- [ ] Auto-scan starts and discovers new devices
- [ ] Tapping bonded device initiates connection
- [ ] Logcat shows "Found: ..." messages for each device
- [ ] If Bluetooth is disabled, no devices appear (expected)
- [ ] If native call fails, fallback to connected devices works

---

## Troubleshooting

### No devices appear
1. Check Bluetooth is enabled on phone
2. Check app has Bluetooth permissions granted (Settings → Apps → Koza RC Car → Permissions)
3. Check Logcat for error messages: `logcat | grep -E "BondedDevices|Bluetooth"`
4. Verify bonded devices exist in Android Settings → Bluetooth

### Only some devices appear
- This is normal: your app only shows devices that are bonded/paired
- Non-bonded devices only appear during active scanning

### Logcat shows error
- Common: "BluetoothAdapter not available" = Bluetooth hardware not supported
- Common: "Permission denied" = Grant BLUETOOTH permission in app settings
- Common: "Bluetooth off" = Enable Bluetooth in system settings

---

## Code Locations

| File | Purpose | Key Changes |
|------|---------|-------------|
| `lib/services/bluetooth_service.dart` | Bluetooth service manager | Added MethodChannel + updated getAvailableDevices() |
| `android/app/src/main/kotlin/.../MainActivity.kt` | Android entry point | Added MethodChannel handler + getBondedDevices() function |
| `lib/pages/device_selection_page.dart` | Device picker UI | Calls getAvailableDevices(), no changes needed |
| `android/app/src/main/AndroidManifest.xml` | Android permissions | No changes (all required permissions already present) |

---

## Version Information

- **Flutter:** 3.10.4+
- **flutter_blue_plus:** 1.31.13+ (calls work with 1.36.8)
- **Target Android API:** 34
- **Kotlin Version:** 1.8+ (included in Flutter)
- **Dart Version:** 3.0+ (Null Safety)

---

## Future Enhancements

1. **Scan Filter:** Add ability to scan for specific UUID services
2. **Device Info:** Display RSSI (signal strength) for discovered devices
3. **Auto-Connect:** Option to auto-connect to last used device
4. **Device Rename:** Allow user to set custom names for bonded devices
5. **Device Management:** Ability to unbond devices from app

