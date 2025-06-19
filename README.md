# Sim Card Info Plugin

[![StandWithPalestine](https://raw.githubusercontent.com/TheBSD/StandWithPalestine/main/badges/StandWithPalestine.svg)](https://github.com/TheBSD/StandWithPalestine/blob/main/docs/README.md)
[![Pub Version](https://img.shields.io/pub/v/sim_card_code.svg)](https://pub.dev/packages/sim_card_code)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A comprehensive Flutter plugin that provides extensive access to SIM card and network information across iOS and Android platforms. Get detailed information about SIM cards, network operators, device identifiers, and dual SIM support.

## 📋 Features

### SIM Card Information

- **Country Code**: Retrieve SIM card country code in ISO format (e.g., "US", "UK", "IN")
- **Operator Details**: Get SIM operator name and operator code
- **Serial Number**: Access SIM card serial number (ICCID)
- **Phone Number**: Retrieve the phone number associated with the SIM
- **SIM State**: Check current SIM card state (READY, ABSENT, PIN_REQUIRED, etc.)
- **SIM Presence**: Detect if a SIM card is present in the device

### Network Information

- **Network Operator**: Get current network operator name
- **Network Country**: Retrieve network country code
- **Network Type**: Identify network technology (LTE, 5G, HSPA, EDGE, etc.)
- **Roaming Status**: Check if device is currently roaming

### Dual SIM Support

- **SIM Count**: Get total number of SIM slots
- **Dual SIM Detection**: Check if device supports dual SIM
- **All SIM Info**: Retrieve detailed information for all active SIM cards
- **Multi-SIM Management**: Handle multiple subscriptions and SIM slots

### Device Information

- **Device ID**: Get device IMEI/MEID identifier

## 🔧 Installation

Add `sim_card_code` to your `pubspec.yaml`:

```yaml
dependencies:
  sim_card_code: ^latest_version
```

Then run:

```bash
flutter pub get
```

## 📱 Platform Support

| Platform   | Support |
| ---------- | ------- |
| Android    | ✅      |
| iOS (9.0+) | ✅      |
| Web        | ❌      |
| macOS      | ❌      |
| Windows    | ❌      |
| Linux      | ❌      |

## 🔐 Permissions

### Android

Add the following permission to your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
```

### iOS

No additional setup required for iOS 9.0 - 13.x.

## 🚀 Usage

Import the package:

```dart
import 'package:sim_card_code/sim_card_code.dart';
```

### Basic SIM Information

```dart
// Get SIM country code
try {
  final countryCode = await SimCardManager.simCountryCode;
} catch (e) {
  print('Error: $e');
}

// Get SIM operator name
try {
  final operatorName = await SimCardManager.simOperatorName;
  print('SIM Operator: $operatorName'); // Output: "Verizon", "Vodafone", etc.
} catch (e) {
  print('Error: $e');
}

// Get SIM operator code
try {
  final operatorCode = await SimCardManager.simOperatorCode;
  print('Operator Code: $operatorCode'); // Output: "310260", etc.
} catch (e) {
  print('Error: $e');
}
```

### SIM State and Presence

```dart
// Check if SIM card is present
try {
  final hasSimCard = await SimCardManager.hasSimCard;
  print('Has SIM Card: $hasSimCard');
} catch (e) {
  print('Error: $e');
}

// Get SIM state
try {
  final simState = await SimCardManager.simState;
  print('SIM State: $simState'); // READY, ABSENT, PIN_REQUIRED, etc.
} catch (e) {
  print('Error: $e');
}
```

### Network Information

```dart
// Get network operator name
try {
  final networkOperator = await SimCardManager.networkOperatorName;
  print('Network Operator: $networkOperator');
} catch (e) {
  print('Error: $e');
}

// Get network country code
try {
  final networkCountryCode = await SimCardManager.networkCountryCode;
  print('Network Country Code: $networkCountryCode');
} catch (e) {
  print('Error: $e');
}

// Get network type
try {
  final networkType = await SimCardManager.networkType;
  print('Network Type: $networkType'); // LTE, HSPA, EDGE, etc.
} catch (e) {
  print('Error: $e');
}

// Check roaming status
try {
  final isRoaming = await SimCardManager.isRoaming;
  print('Is Roaming: $isRoaming');
} catch (e) {
  print('Error: $e');
}
```

### Dual SIM Support

```dart
// Check if device supports dual SIM
try {
  final isDualSim = await SimCardManager.isDualSim;
  print('Is Dual SIM: $isDualSim');
} catch (e) {
  print('Error: $e');
}

// Get SIM count
try {
  final simCount = await SimCardManager.simCount;
  print('SIM Count: $simCount');
} catch (e) {
  print('Error: $e');
}

// Get all SIM information
try {
  final allSimInfo = await SimCardManager.getAllSimInfo;
  for (var simInfo in allSimInfo) {
    print('Slot Index: ${simInfo['slotIndex']}');
    print('Subscription ID: ${simInfo['subscriptionId']}');
    print('Display Name: ${simInfo['displayName']}');
    print('Carrier Name: ${simInfo['carrierName']}');
    print('Country ISO: ${simInfo['countryIso']}');
    print('Phone Number: ${simInfo['phoneNumber']}');
    print('Is Roaming: ${simInfo['isNetworkRoaming']}');
    print('---');
  }
} catch (e) {
  print('Error: $e');
}
```

### Sensitive Information (Requires Permissions)

```dart
// Get SIM serial number (ICCID)
try {
  final serialNumber = await SimCardManager.simSerialNumber;
  print('SIM Serial Number: $serialNumber');
} catch (e) {
  print('Error: $e');
}

// Get phone number
try {
  final phoneNumber = await SimCardManager.phoneNumber;
  print('Phone Number: $phoneNumber');
} catch (e) {
  print('Error: $e');
}

// Get device ID (IMEI/MEID)
try {
  final deviceId = await SimCardManager.deviceId;
  print('Device ID: $deviceId');
} catch (e) {
  print('Error: $e');
}
```

## 📊 SIM States

The plugin returns the following SIM states:

- `READY`: SIM card is ready for use
- `ABSENT`: No SIM card detected
- `PIN_REQUIRED`: SIM card requires PIN entry
- `PUK_REQUIRED`: SIM card requires PUK entry
- `NETWORK_LOCKED`: SIM card is network locked
- `NOT_READY`: SIM card is not ready
- `PERM_DISABLED`: SIM card is permanently disabled
- `CARD_IO_ERROR`: SIM card I/O error
- `CARD_RESTRICTED`: SIM card is restricted
- `UNKNOWN`: Unknown SIM state

## 🌐 Network Types

The plugin identifies the following network types:

- `LTE`: 4G LTE network
- `HSPA`: High Speed Packet Access
- `HSDPA`: High Speed Downlink Packet Access
- `HSUPA`: High Speed Uplink Packet Access
- `HSPAP`: Evolved High Speed Packet Access
- `UMTS`: Universal Mobile Telecommunications System
- `EDGE`: Enhanced Data rates for GSM Evolution
- `GPRS`: General Packet Radio Service
- `CDMA`: Code Division Multiple Access
- `EVDO_0`: Evolution-Data Optimized Rev 0
- `EVDO_A`: Evolution-Data Optimized Rev A
- `1xRTT`: Single Carrier Radio Transmission Technology
- `EHRPD`: Evolved High Rate Packet Data
- `UNKNOWN`: Unknown network type

## ⚠️ Error Handling

The plugin returns `null` in the following cases:

- No SIM card is detected
- The device doesn't support the requested functionality
- Required permissions are not granted
- Any other error occurs during execution

All methods may throw exceptions with specific error codes:

- `PERMISSION_DENIED`: Required permissions not granted
- `SIM_*_ERROR`: Specific SIM-related errors
- `NETWORK_*_ERROR`: Network-related errors

## 🔒 Privacy Considerations

This plugin accesses sensitive device and SIM information. Some methods require the `READ_PHONE_STATE` permission and may return personally identifiable information such as:

- Phone numbers
- Device IMEI/MEID
- SIM serial numbers

Ensure you comply with your app store's privacy policies and inform users about data collection.

## 💖 Support

If you find this plugin helpful, consider supporting the development:

[![Buy Me A Coffee](https://www.buymeacoffee.com/assets/img/guidelines/download-assets-sm-1.svg)](https://buymeacoffee.com/is10vmust)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📞 Contact

For bugs or feature requests, please create an issue on the GitHub repository.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
