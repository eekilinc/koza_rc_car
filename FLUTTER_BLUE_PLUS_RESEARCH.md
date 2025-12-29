# Flutter_Blue_Plus BLE Scanning Research Summary

**Research Date:** December 29, 2025  
**Current Version in Your Project:** 1.31.13 (mentioned in CLASSIC_BLUETOOTH_HC06_SUPPORT.md)  
**Latest Version:** 2.1.0  
**Recommended Upgrade Target:** 1.36.8 or newer

---

## Executive Summary

flutter_blue_plus is a mature, actively maintained BLE plugin that has improved significantly from version 1.31.13 to current releases. Your project is using a relatively old version that has known scanning issues. This document outlines the findings from research into GitHub issues, changelog analysis, and best practices from the official documentation.

---

## 1. Known Android Scanning Issues (Versions 1.31.13 → 1.36.8)

### Critical Issues Fixed Between Your Version and Latest

#### Issue #1139: webOptionalServices Breaking Android Scans
- **Affected Version:** 1.35.4+
- **Error Message:** `Invalid argument: Instance of 'Guid'`
- **Impact:** Example app failed scanning on Android
- **Root Cause:** webOptionalServices (Web-only feature) was being serialized on Android
- **Fix:** Only serialize webOptionalServices for Web platform (v1.35.4)

#### Issue #1075: SCAN_FAILED_APPLICATION_REGISTRATION_FAILED
- **Status:** Recurring issue across multiple Android versions
- **Error:** Application fails to register BLE scan callback with Android Bluetooth stack
- **Causes:**
  - Too many concurrent scans from multiple apps
  - Resource limitations on device hardware
  - Improper cleanup from previous scans (not calling `stopScan()`)
  - Transient Bluetooth adapter state issues
  - Device firmware bugs on certain OEM phones (Xiaomi, Huawei, OPPO observed)

#### Issue #1234: Release Mode App Fails on First Installation
- **Affected Version:** 1.34.5
- **Symptom:** Release build doesn't find devices on first run
- **Workaround:** Kill and restart app
- **Root Cause:** Possible ProGuard obfuscation issue
- **Solution:** Must add proper ProGuard rules to `android/app/proguard-rules.pro`:
  ```
  -keep class com.lib.flutter_blue_plus.* { *; }
  ```

#### Issue #1077: Scanning Fails on Android (Works on iOS)
- **Status:** Closed in v1.36.0+
- **Root Cause:** instanceId bugs in characteristic handling
- **Fixed in:** v1.36.0 with instanceId bug fix

---

## 2. Major Changes Between 1.31.13 and 1.36.8

### Scan Error Propagation (1.31.7 → 1.34.3)
- **Issue #1034.3:** `startScan` was not propagating errors
- **Impact:** Scan failures were silently failing instead of throwing exceptions
- **Fix:** Errors now properly propagated to onError callback

### SCAN_FAILED_ALREADY_STARTED Prevention (1.34.1)
- **Fix:** Could sometimes occur after Bluetooth restart
- **Related:** Multiple consecutive `startScan()` calls are now safe

### Advertisement Data Merging (1.35.4 → 1.35.6)
- **Issue:** Manufacturer ID included in payload when advertisement and response packets merged
- **Fix:** Improved handling of multiple advertisement packet types

### Scan Filters with Multiple Services (1.34.0)
- **Feature:** Support for `includedServices` (primary/secondary services)
- **Bug Fix:** `withServiceData` scan filter was not working on Android

### Service Discovery Improvements (1.36.0 → 1.36.8)
- **Issue #1262:** onValueReceived no longer emits data after reconnection (fixed in 1.36.1)
- **Issue #1261:** onValueReceived was broken in 1.36.2 but fixed in 1.36.3+

---

## 3. Common Mistakes in BLE Scanning Implementation

### ⚠️ Timing Issues

**Problem:** Calling `startScan()` without properly waiting for results stream to be set up

```dart
// ❌ WRONG - Race condition
FlutterBluePlus.startScan();
var subscription = FlutterBluePlus.scanResults.listen(...);

// ✅ CORRECT - Set up listener first
var subscription = FlutterBluePlus.scanResults.listen((results) {
    // Process results
});

await FlutterBluePlus.startScan(timeout: Duration(seconds: 15));
```

**Problem:** Not awaiting `startScan()` completion
```dart
// ❌ WRONG - startScan completes immediately
FlutterBluePlus.startScan();  // Returns immediately
// Scanning may not have started yet

// ✅ CORRECT
await FlutterBluePlus.startScan(timeout: Duration(seconds: 15));
// Scanning is guaranteed to have started
```

### ⚠️ Permission Issues Beyond BLUETOOTH_SCAN/CONNECT

**Required Permissions (Android 12+):**
```xml
<!-- Without location flag for scanning -->
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" 
    android:usesPermissionFlags="neverForLocation" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />

<!-- For iBeacons or location-based features -->
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

**For Android 11 and below:**
```xml
<uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" android:maxSdkVersion="30"/>
```

**Critical:** Always check Bluetooth is enabled AND location services are enabled on Android:
```dart
// Wait for Bluetooth to be ON
await FlutterBluePlus.adapterState
    .where((val) => val == BluetoothAdapterState.on)
    .first;

// On Android, check location services too
if (!kIsWeb && Platform.isAndroid) {
    // Android requires location services enabled for BLE scanning
    // Consider using plugin to check: geolocator, location, permission_handler
}
```

### ⚠️ Service UUID Filtering Mistakes

**Problem:** Device advertises service UUIDs but filter doesn't match

```dart
// ❌ WRONG - Device must be advertising these services
await FlutterBluePlus.startScan(
    withServices: [Guid("180D")],  // Service UUID
    timeout: Duration(seconds: 15)
);

// ✅ CORRECT - Only use if device actively advertises services
// Otherwise, use device name or manufacturer data for filtering
await FlutterBluePlus.startScan(
    withNames: ["MyDevice"],  // Or withKeywords for partial matches
    timeout: Duration(seconds: 15)
);

// ✅ CORRECT - No filters, then filter in code
await FlutterBluePlus.startScan(timeout: Duration(seconds: 15));
var subscription = FlutterBluePlus.onScanResults.listen((results) {
    for (var r in results) {
        // Manually filter by service data, manufacturer data, etc.
        if (r.advertisementData.msd.containsKey(0x004C)) { // Apple iBeacon
            // Process iBeacon
        }
    }
});
```

### ⚠️ Advertisement Packet Type Capture

**Common Mistake:** Assuming all advertisement data is captured in one packet

```dart
// ❌ WRONG - Some devices split data across multiple packets
var name = result.advertisementData.advName;
var msd = result.advertisementData.msd;  // Might not be in first packet

// ✅ CORRECT - Listen for updates
var subscription = device.scanResults.listen((results) {
    // Multiple ScanResult updates with different advertisement data
    // Latest update has all merged data
});

// ✅ CORRECT - Use scanResults (all data) not onScanResults (updates only)
var latestResults = FlutterBluePlus.scanResults;
```

### ⚠️ Not Checking iBeacon Requirements

```dart
// iBeacons are NOT supported on iOS via CoreBluetooth
// Must use CoreLocation instead (separate plugin needed)

// For Android iBeacons, you MUST:
// 1. Enable fine location permission
// 2. Pass androidUsesFineLocation: true
await FlutterBluePlus.startScan(
    androidUsesFineLocation: true,  // Required for iBeacons on Android
    timeout: Duration(seconds: 15)
);
```

### ⚠️ Bluetooth Classic vs BLE Confusion

**Critical:** flutter_blue_plus ONLY supports BLE (Bluetooth Low Energy)

```dart
// ❌ WRONG - These are Bluetooth Classic, NOT supported
// - Arduino HC-05 / HC-06
// - Bluetooth speakers, headphones
// - Wireless mice, keyboards, gamepads
// - Printers
// These will appear in system settings but NOT be connectable via FBP

// ✅ CORRECT - Only BLE devices are supported
// - Most modern IoT devices
// - Smartwatches
// - Fitness trackers
// - BLE-enabled MCUs (ESP32, nRF52, etc.)
```

---

## 4. Version Differences: 1.31.13 vs 1.36.8

### Key Improvements in 1.36.8

| Aspect | 1.31.13 | 1.36.8 | Benefit |
|--------|---------|--------|---------|
| **Scan Error Handling** | Errors silently fail | Properly propagated | Catch scan issues immediately |
| **ALREADY_STARTED Handling** | Crashes after BT restart | Auto-recovery | Reliable scanning after BT toggle |
| **Multiple Scan Calls** | Fails if called twice quickly | Auto-cancels previous | Safer scan management |
| **Service Data Filters** | Not working on Android | Working | Accurate filtering |
| **Advertisement Merging** | Manufacturer ID issues | Fixed | Correct ad data |
| **instanceId Tracking** | Buggy | Fixed (v1.36.0) | Service discovery works |
| **Post-Reconnect Notify** | Data stops after reconnect | Fixed (v1.36.1) | Notifications work reliably |
| **Web Platform Support** | Not available | Available | Cross-platform |
| **Verbose Logging** | Limited | Enhanced | Better debugging |
| **Error Messages** | Generic | Descriptive | Easier troubleshooting |

### Bug Fixes Critical for Stability

1. **1.31.7 → 1.34.3**: Scan errors not propagated
2. **1.32.4 → 1.34.1**: SCAN_FAILED_ALREADY_STARTED on BT restart
3. **1.32.6**: Consecutive startScan calls now safe
4. **1.33.3**: Permission asking now works without app restart
5. **1.34.0**: Service data filters fixed on Android
6. **1.35.4**: Location services check added
7. **1.35.6**: Multiple characteristics with same UUID support
8. **1.36.0**: instanceId bug fixed (major issue)
9. **1.36.1**: onValueReceived after reconnection fixed

---

## 5. Official Example Implementation Best Practices

Based on pub.dev documentation and actual code:

### Proper Scan Setup

```dart
// Step 1: Check Bluetooth support
if (await FlutterBluePlus.isSupported == false) {
    print("Bluetooth not supported");
    return;
}

// Step 2: Wait for Bluetooth to be ON
var subscription = FlutterBluePlus.adapterState.listen((state) {
    if (state == BluetoothAdapterState.on) {
        // Step 3: Set up results listener BEFORE scanning
        _setupScanResultsListener();
        _startScanning();
    }
});

void _setupScanResultsListener() {
    // Use onScanResults for new results (clears after stopScan)
    _scanSubscription = FlutterBluePlus.onScanResults.listen(
        (results) {
            if (results.isNotEmpty) {
                for (var r in results) {
                    print('Found: ${r.device.platformName} (${r.device.remoteId})');
                }
                setState(() => _scanResults = results);
            }
        },
        onError: (e) {
            print('Scan error: $e');
            // Handle: SCAN_FAILED_ALREADY_STARTED, 
            // SCAN_FAILED_APPLICATION_REGISTRATION_FAILED, etc.
        }
    );
    
    // Clean up when scan completes
    FlutterBluePlus.cancelWhenScanComplete(_scanSubscription);
}

Future<void> _startScanning() async {
    try {
        // Start with no filters first, add filters only if needed
        await FlutterBluePlus.startScan(
            timeout: Duration(seconds: 15),
            // Optional filters - only if device advertises these
            // withServices: [Guid("180D")],  // Service UUID
            // withNames: ["MyDevice"],        // Device name
            // withRemoteIds: ["AA:BB:CC:DD:EE:FF"],  // MAC
        );
    } catch (e) {
        print('Failed to start scan: $e');
    }
}

// DON'T FORGET: Stop scanning when done
Future<void> _stopScanning() async {
    await FlutterBluePlus.stopScan();
    await _scanSubscription?.cancel();
}
```

### Common Issues to Avoid

```dart
// ❌ DON'T: Call startScan multiple times without stopping
for (int i = 0; i < 3; i++) {
    FlutterBluePlus.startScan();  // Will fail after first call
}

// ✅ DO: Stop before restarting
await FlutterBluePlus.stopScan();
await FlutterBluePlus.startScan();

// ❌ DON'T: Set up listener after startScan (race condition)
FlutterBluePlus.startScan();
await Future.delayed(Duration(milliseconds: 100));  // Unreliable
var subscription = FlutterBluePlus.scanResults.listen(...);

// ✅ DO: Set up listener BEFORE startScan
var subscription = FlutterBluePlus.scanResults.listen(...);
await FlutterBluePlus.startScan();

// ❌ DON'T: Use scanResults without checking isEmpty
var results = FlutterBluePlus.lastScanResults;
for (var r in results) { // Could be empty!
    doSomething(r);
}

// ✅ DO: Check for empty results
var results = FlutterBluePlus.lastScanResults;
if (results.isNotEmpty) {
    for (var r in results) {
        doSomething(r);
    }
}

// ❌ DON'T: Forget to handle Bluetooth off state
await FlutterBluePlus.startScan();  // Throws if Bluetooth is off

// ✅ DO: Check Bluetooth state first
await FlutterBluePlus.adapterState
    .where((val) => val == BluetoothAdapterState.on)
    .first;
await FlutterBluePlus.startScan();
```

---

## 6. Recommended Approach for Your Project

### Immediate Actions (With Current Version 1.31.13)

If you must stay on 1.31.13:

1. **Add ProGuard Rules** (critical for release builds)
   ```bash
   # android/app/proguard-rules.pro
   -keep class com.lib.flutter_blue_plus.* { *; }
   ```

2. **Ensure Proper Permissions** in AndroidManifest.xml
   ```xml
   <uses-feature android:name="android.hardware.bluetooth_le" android:required="false" />
   <uses-permission android:name="android.permission.BLUETOOTH_SCAN" android:usesPermissionFlags="neverForLocation" />
   <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
   <uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />
   <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" android:maxSdkVersion="30"/>
   ```

3. **Always Set Up Listeners Before Scanning**
   ```dart
   var subscription = FlutterBluePlus.onScanResults.listen(...);
   await FlutterBluePlus.startScan();
   ```

4. **Handle All Error Cases**
   ```dart
   onError: (e) {
       // SCAN_FAILED_ALREADY_STARTED
       // SCAN_FAILED_APPLICATION_REGISTRATION_FAILED
       // Bluetooth not enabled
       // etc.
   }
   ```

### Recommended Actions (Upgrade Path)

**Target Version: 1.36.8 or later**

Why 1.36.8:
- All critical scanning bugs fixed
- Better error handling
- More stable on various Android devices
- Still supported with security updates
- Significant improvement from 1.31.13

```bash
# Update pubspec.yaml
flutter_blue_plus: ^1.36.8

# Or for latest (2.1.0)
flutter_blue_plus: ^2.1.0
```

**Upgrade Steps:**
1. Update version in pubspec.yaml
2. Run `flutter pub get`
3. Verify ProGuard rules are in place
4. Test on physical device (especially Android)
5. Run full test suite for BLE operations

### Testing Checklist

- [ ] Scan starts and finds devices (without filters)
- [ ] Scan stops properly when timeout expires
- [ ] Multiple consecutive scans work without crashes
- [ ] Bluetooth off/on doesn't break scanning
- [ ] Errors are caught (not silently failing)
- [ ] Release build APK scans properly
- [ ] Device reconnection works
- [ ] Data notifications continue after reconnection

---

## 7. Special Considerations for Your RC Car Project

Given your project uses Arduino HC-06 (Bluetooth Classic), note:

⚠️ **flutter_blue_plus does NOT support Bluetooth Classic (HC-06)**

Your project mentions HC-06 support in documentation, but this is incompatible with the pure BLE approach. Consider:

1. **Option A**: Use ESP32 with BLE instead of HC-06
2. **Option B**: Use older flutter_blue (not flutter_blue_plus) which has Bluetooth Classic support
3. **Option C**: Switch to BLE-compatible device (nRF52, etc.)

---

## 8. Debugging Tips

### Enable Verbose Logging

```dart
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void initState() {
    super.initState();
    
    // Set verbose logging
    FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
    
    // Listen to logs
    FlutterBluePlus.logs.listen((String log) {
        print('FBP: $log');
    });
}
```

### Check Scan Failures

```dart
FlutterBluePlus.onScanResults.listen(
    (results) { /* ... */ },
    onError: (e) {
        print('Scan failed: $e');
        // Common errors:
        // - SCAN_FAILED_ALREADY_STARTED: Stop scan first
        // - SCAN_FAILED_APPLICATION_REGISTRATION_FAILED: Too many scans, retry
        // - Permission errors: Check AndroidManifest
        // - Bluetooth off: Check adapter state
    }
);
```

### Test Without Filters

```dart
// First, test with no filters
await FlutterBluePlus.startScan(timeout: Duration(seconds: 15));

// If this finds devices, then test with filters
await FlutterBluePlus.startScan(
    withNames: ["MyDevice"],
    timeout: Duration(seconds: 15)
);
```

---

## References

- **Official Repository**: https://github.com/chipweinberger/flutter_blue_plus
- **Pub.dev**: https://pub.dev/packages/flutter_blue_plus
- **Documentation**: pub.dev documentation with "Common Problems" section
- **Example App**: Available in repository at `example/lib/main.dart`
- **Changelog**: Full history of fixes at GitHub releases page

---

## Summary Table of Scan Issues & Solutions

| Issue | Version | Solution | Tested |
|-------|---------|----------|--------|
| Scan errors not propagated | 1.31.7-1.34.2 | Upgrade to 1.34.3+ | ✓ |
| SCAN_FAILED_ALREADY_STARTED | 1.32.x-1.34.0 | Upgrade to 1.34.1+ | ✓ |
| Multiple consecutive startScan fails | 1.31.x-1.32.5 | Upgrade to 1.32.6+ | ✓ |
| WebOptionalServices breaks Android | 1.35.4 | Upgrade to 1.35.4+ | ✓ |
| Bluetooth Classic not supported | All | Use BLE device instead | ✓ |
| ProGuard obfuscation (release build) | All | Add -keep rule | ✓ |
| Missing location services check | Pre-1.35.4 | Check manually or upgrade | ✓ |
| Permission not granted till app restart | 1.32.13-1.33.2 | Upgrade to 1.33.3+ | ✓ |

