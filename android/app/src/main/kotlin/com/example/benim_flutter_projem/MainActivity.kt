package com.example.benim_flutter_projem

import android.annotation.SuppressLint
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothSocket
import android.bluetooth.le.ScanCallback
import android.bluetooth.le.ScanResult
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.bluetooth.BluetoothDevice
import android.os.Build
import java.io.OutputStream
import java.util.UUID

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.kozaakademi.rc_car/bluetooth"
    
    // HC-06 Serial Port Profile UUID
    private val HC06_UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")
    
    private var bluetoothSocket: BluetoothSocket? = null
    private var outputStream: OutputStream? = null
    private var methodChannel: MethodChannel? = null
    private var isScanning = false
    private var discoveryBroadcastReceiver: BroadcastReceiver? = null
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel!!.setMethodCallHandler { call, result ->
                when (call.method) {
                    "getBondedDevices" -> {
                        try {
                            val devices = getBondedDevices()
                            result.success(devices)
                        } catch (e: Exception) {
                            result.error("ERROR", "Failed to get bonded devices", e.message)
                        }
                    }
                    "startScan" -> {
                        try {
                            startScan()
                            result.success(true)
                        } catch (e: Exception) {
                            android.util.Log.e("MethodChannel", "startScan exception: ${e.message}", e)
                            result.error("SCAN_ERROR", "Failed to start scan: ${e.message}", e.toString())
                        }
                    }
                    "stopScan" -> {
                        try {
                            stopScan()
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("ERROR", "Failed to stop scan", e.message)
                        }
                    }
                    "connectToDevice" -> {
                        try {
                            val address = call.argument<String>("address")
                            if (address != null) {
                                // Run connection in background thread to avoid blocking UI
                                Thread {
                                    val success = connectToClassicBluetooth(address)
                                    result.success(success)
                                }.start()
                            } else {
                                result.error("ERROR", "Address is null", null)
                            }
                        } catch (e: Exception) {
                            result.error("ERROR", "Connection failed", e.message)
                        }
                    }
                    "sendCommand" -> {
                        try {
                            val command = call.argument<String>("command")
                            android.util.Log.d("BluetoothCommand", "sendCommand called with: $command, outputStream: $outputStream, socket: $bluetoothSocket")
                            if (command != null && outputStream != null) {
                                outputStream!!.write(command.toByteArray())
                                outputStream!!.flush()
                                // HC-06 needs time to process each command
                                Thread.sleep(50)
                                android.util.Log.d("BluetoothCommand", "✓ Sent: $command")
                                result.success(true)
                            } else {
                                android.util.Log.e("BluetoothCommand", "✗ Not connected - outputStream: $outputStream, command: $command")
                                result.success(false)
                            }
                        } catch (e: Exception) {
                            android.util.Log.e("BluetoothCommand", "✗ Exception: ${e.message}", e)
                            result.success(false)
                        }
                    }
                    "disconnect" -> {
                        try {
                            disconnectBluetooth()
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("ERROR", "Disconnect failed", e.message)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
    
    private fun getBondedDevices(): List<Map<String, String>> {
        val devices = mutableListOf<Map<String, String>>()
        try {
            val bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
            if (bluetoothAdapter != null && bluetoothAdapter.isEnabled) {
                val bondedDevices = bluetoothAdapter.bondedDevices
                for (device in bondedDevices) {
                    // Get device type (CLASSIC, BLE, or DUAL)
                    val deviceType = when (device.type) {
                        1 -> "CLASSIC"  // BluetoothDevice.DEVICE_TYPE_CLASSIC
                        2 -> "BLE"      // BluetoothDevice.DEVICE_TYPE_LE
                        3 -> "DUAL"     // BluetoothDevice.DEVICE_TYPE_DUAL
                        else -> "UNKNOWN"
                    }
                    
                    val deviceMap = mapOf(
                        "name" to (device.name ?: "Unknown"),
                        "address" to device.address,
                        "type" to deviceType
                    )
                    devices.add(deviceMap)
                    android.util.Log.d("BondedDevices", "Found: ${device.name} (${device.address}) Type: $deviceType")
                }
            }
        } catch (e: Exception) {
            android.util.Log.e("BondedDevices", "Error getting bonded devices", e)
        }
        return devices
    }
    
    @SuppressLint("MissingPermission")
    private fun startScan() {
        android.util.Log.e("BleScan_CRITICAL", "⚠️ STARTSCAN CALLED! THIS IS AN ERROR LEVEL LOG TO ENSURE VISIBILITY")
        System.err.println("🔴🔴🔴 KOTLIN startScan() METHOD EXECUTED 🔴🔴🔴")
        System.out.println("🟢🟢🟢 KOTLIN startScan() METHOD EXECUTED 🟢🟢🟢")
        
        android.util.Log.d("BleScan", "════════════════════════════════════")
        android.util.Log.d("BleScan", "🔵 STARTSCAN CALLED - Entry point reached!")
        android.util.Log.d("BleScan", "════════════════════════════════════")
        
        if (isScanning) {
            android.util.Log.d("BleScan", "⚠️ Already scanning, ignoring startScan request")
            return
        }
        
        isScanning = true
        
        // Start both Classic Discovery AND BLE Scan in parallel
        android.util.Log.d("BleScan", "🔵 Starting BOTH Classic Discovery + BLE Scan...")
        
        // Run on main thread to ensure UI updates work properly
        runOnUiThread {
            startClassicDiscovery()
            startBleScanning()
        }
    }
    
    @SuppressLint("MissingPermission")
    private fun startClassicDiscovery() {
        android.util.Log.d("BleScan", "═══════ CLASSIC DISCOVERY START ═══════")
        
        try {
            val bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
            if (bluetoothAdapter == null) {
                android.util.Log.e("BleScan", "❌ Bluetooth adapter is NULL!")
                return
            }
            
            if (!bluetoothAdapter.isEnabled) {
                android.util.Log.e("BleScan", "❌ Bluetooth is DISABLED!")
                return
            }
            
            android.util.Log.d("BleScan", "✓ Bluetooth OK")
            
            // Register for discovery broadcasts
            val discoveryIntentFilter = IntentFilter().apply {
                addAction(BluetoothDevice.ACTION_FOUND)
                addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED)
            }
            
            android.util.Log.d("BleScan", "Creating BroadcastReceiver for Classic Discovery...")
            
            discoveryBroadcastReceiver = object : BroadcastReceiver() {
                override fun onReceive(context: Context?, intent: Intent?) {
                    val action = intent?.action
                    android.util.Log.d("BleScan", "📡📡📡 Broadcast Received! Action: $action")
                    
                    when (action) {
                        BluetoothDevice.ACTION_FOUND -> {
                            try {
                                val device: BluetoothDevice? = 
                                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                                        intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE, BluetoothDevice::class.java)
                                    } else {
                                        @Suppress("DEPRECATION")
                                        intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
                                    }
                                
                                val rssi: Short = intent.getShortExtra(BluetoothDevice.EXTRA_RSSI, Short.MIN_VALUE)
                                
                                if (device != null) {
                                    val deviceName = device.name ?: "Unknown"
                                    val deviceAddress = device.address
                                    val deviceTypeStr = when(device.type) {
                                        1 -> "CLASSIC"
                                        2 -> "BLE"
                                        3 -> "DUAL"
                                        else -> "UNKNOWN"
                                    }
                                    
                                    android.util.Log.d("BleScan", "✅ Found: $deviceName ($deviceAddress) Type: $deviceTypeStr RSSI: $rssi")
                                    
                                    val deviceInfo = mapOf(
                                        "name" to deviceName,
                                        "address" to deviceAddress,
                                        "type" to deviceTypeStr,
                                        "rssi" to rssi.toInt()
                                    )
                                    
                                    runOnUiThread {
                                        try {
                                            android.util.Log.d("BleScan", "  → Sending to Dart: onDeviceFound")
                                            methodChannel?.invokeMethod("onDeviceFound", deviceInfo)
                                        } catch (e: Exception) {
                                            android.util.Log.e("BleScan", "  ❌ Error invoking Dart: ${e.message}")
                                        }
                                    }
                                } else {
                                    android.util.Log.w("BleScan", "⚠️ Device is NULL in ACTION_FOUND")
                                }
                            } catch (e: Exception) {
                                android.util.Log.e("BleScan", "❌ Exception processing ACTION_FOUND: ${e.message}", e)
                            }
                        }
                        
                        BluetoothAdapter.ACTION_DISCOVERY_FINISHED -> {
                            android.util.Log.d("BleScan", "✅ DISCOVERY_FINISHED received")
                            isScanning = false
                            
                            try {
                                if (discoveryBroadcastReceiver != null) {
                                    unregisterReceiver(this)
                                    android.util.Log.d("BleScan", "  ✓ Receiver unregistered")
                                }
                            } catch (e: Exception) {
                                android.util.Log.e("BleScan", "  ❌ Error unregistering: ${e.message}")
                            }
                            
                            runOnUiThread {
                                try {
                                    android.util.Log.d("BleScan", "  → Sending to Dart: onScanFinished")
                                    methodChannel?.invokeMethod("onScanFinished", null)
                                } catch (e: Exception) {
                                    android.util.Log.e("BleScan", "  ❌ Error invoking Dart: ${e.message}")
                                }
                            }
                        }
                        
                        else -> android.util.Log.w("BleScan", "⚠️ Unknown broadcast: $action")
                    }
                }
            }
            
            android.util.Log.d("BleScan", "🔵 About to register receiver...")
            
            try {
                val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    Context.RECEIVER_EXPORTED
                } else {
                    0
                }
                
                registerReceiver(discoveryBroadcastReceiver, discoveryIntentFilter, flags)
                android.util.Log.d("BleScan", "✅ Receiver registered successfully!")
            } catch (e: Exception) {
                android.util.Log.e("BleScan", "❌ CRITICAL: registerReceiver failed: ${e.message}", e)
                e.printStackTrace()
                isScanning = false
                return
            }
            
            // Start discovery
            android.util.Log.d("BleScan", "🔵 Calling startDiscovery()...")
            
            try {
                if (bluetoothAdapter.isDiscovering) {
                    android.util.Log.d("BleScan", "  Cancelling previous discovery...")
                    bluetoothAdapter.cancelDiscovery()
                    Thread.sleep(500)
                }
                
                val startResult = bluetoothAdapter.startDiscovery()
                
                if (startResult) {
                    android.util.Log.d("BleScan", "✅✅✅ startDiscovery() SUCCESS! ✅✅✅")
                } else {
                    android.util.Log.e("BleScan", "❌ startDiscovery() returned FALSE")
                }
            } catch (e: Exception) {
                android.util.Log.e("BleScan", "❌ startDiscovery threw exception: ${e.message}", e)
            }
            
        } catch (e: Exception) {
            android.util.Log.e("BleScan", "❌ EXCEPTION in startClassicDiscovery: ${e.message}", e)
            e.printStackTrace()
            isScanning = false
            try {
                if (discoveryBroadcastReceiver != null) {
                    unregisterReceiver(discoveryBroadcastReceiver)
                }
            } catch (ex: Exception) {
                android.util.Log.e("BleScan", "  ❌ Error unregistering: ${ex.message}")
            }
        }
    }
    
    @SuppressLint("MissingPermission")
    private fun startBleScanning() {
        android.util.Log.d("BleScan", "═══════ BLE SCAN START ═══════")
        
        try {
            val bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
            if (bluetoothAdapter == null || !bluetoothAdapter.isEnabled) {
                android.util.Log.d("BleScan", "⚠️ BLE scan skipped - adapter unavailable")
                return
            }
            
            val scanner = bluetoothAdapter.bluetoothLeScanner
            if (scanner == null) {
                android.util.Log.d("BleScan", "⚠️ BLE scan skipped - scanner not available")
                return
            }
            
            android.util.Log.d("BleScan", "🔵 Starting BLE scan...")
            scanner.startScan(bleCallback)
            android.util.Log.d("BleScan", "✅ BLE scan started!")
            
        } catch (e: Exception) {
            android.util.Log.e("BleScan", "❌ Exception in startBleScanning: ${e.message}", e)
        }
    }
    
    private val bleCallback = object : ScanCallback() {
        override fun onScanResult(callbackType: Int, result: ScanResult?) {
            if (result != null) {
                android.util.Log.d("BleScan", "✅ BLE Found: ${result.device.name} (${result.device.address}) RSSI: ${result.rssi}")
                
                val deviceInfo = mapOf(
                    "name" to (result.device.name ?: "Unknown"),
                    "address" to result.device.address,
                    "type" to "BLE",
                    "rssi" to result.rssi
                )
                
                runOnUiThread {
                    try {
                        methodChannel?.invokeMethod("onDeviceFound", deviceInfo)
                    } catch (e: Exception) {
                        android.util.Log.e("BleScan", "Error sending BLE device: ${e.message}")
                    }
                }
            }
        }
        
        override fun onScanFailed(errorCode: Int) {
            android.util.Log.e("BleScan", "❌ BLE scan failed: Error code $errorCode")
        }
    }
    
    @SuppressLint("MissingPermission")
    private fun stopScan() {
        android.util.Log.d("BleScan", "🔴 STOPSCAN CALLED")
        
        if (!isScanning) {
            android.util.Log.d("BleScan", "⚠️ Not scanning, nothing to stop")
            return
        }
        
        isScanning = false
        
        try {
            val bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
            bluetoothAdapter?.cancelDiscovery()
            android.util.Log.d("BleScan", "✓ Classic discovery cancelled")
        } catch (e: Exception) {
            android.util.Log.e("BleScan", "Error cancelling discovery: ${e.message}")
        }
        
        try {
            val bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
            val scanner = bluetoothAdapter?.bluetoothLeScanner
            scanner?.stopScan(bleCallback)
            android.util.Log.d("BleScan", "✓ BLE scan stopped")
        } catch (e: Exception) {
            android.util.Log.e("BleScan", "Error stopping BLE scan: ${e.message}")
        }
        
        try {
            if (discoveryBroadcastReceiver != null) {
                unregisterReceiver(discoveryBroadcastReceiver)
                discoveryBroadcastReceiver = null
                android.util.Log.d("BleScan", "✓ Receiver unregistered")
            }
        } catch (e: Exception) {
            android.util.Log.e("BleScan", "Error unregistering receiver: ${e.message}")
        }
    }
    
    private fun startBleScan(result: MethodChannel.Result) {
        try {
            val bluetoothAdapter = BluetoothAdapter.getDefaultAdapter() ?: run {
                result.error("ERROR", "Bluetooth adapter not found", null)
                return
            }
            
            android.util.Log.d("BleScan", "Starting native Android BLE scan...")
            
            if (!bluetoothAdapter.isEnabled) {
                android.util.Log.e("BleScan", "Bluetooth is not enabled")
                result.error("ERROR", "Bluetooth is not enabled", null)
                return
            }
            
            val bluetoothLeScanner = bluetoothAdapter.bluetoothLeScanner
            if (bluetoothLeScanner == null) {
                android.util.Log.e("BleScan", "BLE scanner not available")
                result.error("ERROR", "BLE scanner not available", null)
                return
            }
            
            android.util.Log.d("BleScan", "✓ Starting BLE scan...")
            bluetoothLeScanner.startScan(scanCallbackLe)
            result.success(true)
            
        } catch (e: Exception) {
            android.util.Log.e("BleScan", "Error starting BLE scan: ${e.message}", e)
            result.error("ERROR", "Error starting BLE scan", e.message)
        }
    }
    
    private fun stopBleScan() {
        try {
            val bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
            val bluetoothLeScanner = bluetoothAdapter?.bluetoothLeScanner
            bluetoothLeScanner?.stopScan(scanCallbackLe)
            android.util.Log.d("BleScan", "BLE scan stopped")
        } catch (e: Exception) {
            android.util.Log.e("BleScan", "Error stopping BLE scan: ${e.message}")
        }
    }
    
    private val scanCallbackLe = object : ScanCallback() {
        override fun onScanResult(callbackType: Int, result: ScanResult?) {
            super.onScanResult(callbackType, result)
            if (result != null) {
                android.util.Log.d("BleScan", "Found (LE): ${result.device.name} (${result.device.address}) RSSI: ${result.rssi}")
            }
        }
        
        override fun onScanFailed(errorCode: Int) {
            super.onScanFailed(errorCode)
            android.util.Log.e("BleScan", "Scan failed with error code: $errorCode")
        }
    }
    
    private fun connectToClassicBluetooth(address: String): Boolean {
        return try {
            android.util.Log.d("BluetoothConnect", "Connecting to $address")
            
            // Get Bluetooth adapter
            val bluetoothAdapter = BluetoothAdapter.getDefaultAdapter() ?: return false
            
            // Get the remote device
            val device = bluetoothAdapter.getRemoteDevice(address)
            
            // Close any existing connection
            bluetoothSocket?.close()
            
            // Create socket with HC-06 Serial Port UUID
            bluetoothSocket = device.createRfcommSocketToServiceRecord(HC06_UUID)
            android.util.Log.d("BluetoothConnect", "Socket created: $bluetoothSocket")
            
            // Connect
            bluetoothSocket?.connect()
            android.util.Log.d("BluetoothConnect", "Socket connected")
            
            // Get output stream
            outputStream = bluetoothSocket?.outputStream
            android.util.Log.d("BluetoothConnect", "OutputStream obtained: $outputStream")
            
            if (outputStream == null) {
                android.util.Log.e("BluetoothConnect", "✗ OutputStream is NULL after getting!")
                return false
            }
            
            android.util.Log.d("BluetoothConnect", "✓ Successfully connected to $address")
            true
        } catch (e: Exception) {
            android.util.Log.e("BluetoothConnect", "✗ Error connecting: ${e.message}", e)
            bluetoothSocket?.close()
            bluetoothSocket = null
            outputStream = null
            false
        }
    }
    
    private fun disconnectBluetooth() {
        try {
            outputStream?.close()
            bluetoothSocket?.close()
            outputStream = null
            bluetoothSocket = null
            android.util.Log.d("BluetoothConnect", "Disconnected")
        } catch (e: Exception) {
            android.util.Log.e("BluetoothConnect", "Error disconnecting: ${e.message}")
        }
    }
}
