# sim_card_code

[![StandWithPalestine](https://raw.githubusercontent.com/TheBSD/StandWithPalestine/main/badges/StandWithPalestine.svg)](https://github.com/TheBSD/StandWithPalestine/blob/main/docs/README.md)
[![Pub Version](https://img.shields.io/pub/v/sim_card_code.svg)](https://pub.dev/packages/sim_card_code)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A Flutter plugin for reading SIM card and cellular network information on
Android and iOS — country code, operator, network type, eSIM status, dual-SIM
details and more.

> ⚠️ **Privacy first.** Some values (phone number, IMEI, ICCID) are sensitive
> and gated behind permissions. Read [Privacy considerations](#-privacy-considerations)
> before shipping.

## Contents

- [Features](#-features)
- [Installation](#-installation)
- [Platform support](#-platform-support)
- [Permissions & setup](#-permissions--setup)
- [Usage](#-usage)
- [Multi-SIM (subscription) support](#-multi-sim-subscription-support)
- [Reacting to changes](#-reacting-to-changes)
- [API reference](#-api-reference)
- [SIM states](#-sim-states) · [Network types](#-network-types)
- [Error handling](#-error-handling)
- [Privacy considerations](#-privacy-considerations)

## 📋 Features

| Category | What you get |
| -------- | ------------ |
| **SIM card** | Country code (ISO), operator name & code, ICCID, phone number, SIM state, presence, eSIM flag |
| **Network** | Operator name, country code, network type (5G/LTE/HSPA/…), roaming status |
| **Dual / multi-SIM** | SIM count, dual-SIM detection, per-SIM info, lookup by subscription id |
| **Device** | Device id (IMEI/MEID), hardware eSIM support |
| **Live updates** | Reactive stream of SIM / network / roaming changes |

## 🔧 Installation

```yaml
dependencies:
  sim_card_code: ^0.2.0
```

```bash
flutter pub get
```

### iOS — CocoaPods or Swift Package Manager

The iOS plugin ships **both** a CocoaPods podspec and a `Package.swift`, so it
works whether or not your app has Swift Package Manager enabled — no extra steps
required. Apps using `--enable-swift-package-manager` (becoming the Flutter
default) resolve the plugin through SPM automatically; everyone else keeps using
CocoaPods.

## 📱 Platform support

| Platform | Support | Notes |
| -------- | :-----: | ----- |
| Android  | ✅ | API 21+ |
| iOS      | ✅ | iOS 13.0+ |
| Web / macOS / Windows / Linux | ❌ | Not applicable |

## 🔐 Permissions & setup

### Android

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
```

`READ_PHONE_STATE` is a runtime permission — request it before calling methods
that need it (`phoneNumber`, `simSerialNumber`, `deviceId`, `allSimInfo`,
`isEsim`, `simInfoForSubscription`). Use a package such as
[`permission_handler`](https://pub.dev/packages/permission_handler):

```dart
import 'package:permission_handler/permission_handler.dart';

await Permission.phone.request();
```

### iOS

No setup is required for most methods. `SimCardManager.supportsEsim` needs the
`com.apple.developer.esim-access` entitlement — see
[eSIM on iOS](#esim-on-ios). Several values are unavailable on iOS for privacy
reasons (see [API reference](#-api-reference)).

## 🚀 Usage

```dart
import 'package:sim_card_code/sim_card_code.dart';
```

### Basic SIM information

```dart
final countryCode  = await SimCardManager.simCountryCode;   // "US", "UK", "IN"
final operatorName = await SimCardManager.simOperatorName;  // "Verizon", "Vodafone"
final operatorCode = await SimCardManager.simOperatorCode;  // "310260"
final hasSim       = await SimCardManager.hasSimCard;       // true / false
final simState     = await SimCardManager.simState;         // SimState.ready, …
```

### Network information

```dart
final network = await SimCardManager.networkInfo;
print(network.operatorName);      // current network operator
print(network.countryCode);       // network country code
print(network.networkType);       // raw string: "LTE", "5G", …
print(network.type);              // typed: NetworkType.lte
print(network.generation.label);  // "4G" (also NetworkGeneration enum)
print(network.isRoaming);         // true / false
```

### Dual-SIM

```dart
final isDualSim = await SimCardManager.isDualSim;
final simCount  = await SimCardManager.simCount;

// allSimInfo returns a typed List<SimCardInfo>
final allSims = await SimCardManager.allSimInfo;
for (final sim in allSims) {
  print('Slot ${sim.slotIndex} · subId ${sim.subscriptionId}');
  print('  ${sim.carrierName} (${sim.countryCode})');
  print('  eSIM: ${sim.isEsim} · state: ${sim.simState?.name}');
}
```

### Sensitive values (Android — requires `READ_PHONE_STATE`)

```dart
final serial   = await SimCardManager.simSerialNumber;  // ICCID — Android only
final phone    = await SimCardManager.phoneNumber;      // Android only
final deviceId = await SimCardManager.deviceId;         // IMEI/MEID — Android only
```

## 🔀 Multi-SIM (subscription) support

On multi-SIM devices the default getters (`simCountryCode`, `isEsim`, …) always
report the **default** SIM. To target a specific SIM, use
`simInfoForSubscription` with a subscription id taken from `allSimInfo`:

```dart
final allSims = await SimCardManager.allSimInfo;

for (final sim in allSims) {
  final subId = sim.subscriptionId;
  if (subId == null) continue;

  final info = await SimCardManager.simInfoForSubscription(subId);
  print('SIM $subId → ${info?.carrierName}, eSIM: ${info?.isEsim}');
}
```

On Android the data is read through `TelephonyManager.createForSubscriptionId`,
so the values reflect the requested SIM. It returns `null` when the subscription
is inactive, on Android < 22, or on **iOS** — iOS has no integer subscription id,
so use `allSimInfo` there instead.

## 🔔 Reacting to changes

`SimCardManager.onChanged` is a broadcast stream that emits a
`SimCardChangeEvent` whenever a SIM is inserted, removed or swapped, or the
network / operator / roaming state changes. The plugin clears its cache before
each event, so any getter read inside the listener returns fresh data:

```dart
final sub = SimCardManager.onChanged.listen((event) async {
  switch (event.type) {
    case SimChangeType.sim:
      print('SIM changed');
    case SimChangeType.network:
      print('Network changed');
    case SimChangeType.unknown:
      break;
  }
  final info = await SimCardManager.basicSimInfo; // already fresh
});

// Cancel the subscription when updates are no longer needed.
await sub.cancel();
```

Android detects SIM insert/remove/swap and service-state changes; iOS reports
carrier and radio-technology updates via `CoreTelephony`.

## 📖 API reference

All members of `SimCardManager` are `static`. Getters cache their result; call
`SimCardManager.clearCache()` to force a refresh.

| Member | Returns | iOS |
| ------ | ------- | :-: |
| `simCountryCode` | `Future<String?>` | ✅ |
| `simOperatorName` | `Future<String?>` | ✅ |
| `simOperatorCode` | `Future<String?>` | ✅ |
| `simSerialNumber` | `Future<String?>` | ❌ privacy |
| `phoneNumber` | `Future<String?>` | ❌ privacy |
| `simState` | `Future<SimState>` | ✅ |
| `networkOperatorName` | `Future<String?>` | ✅ |
| `networkCountryCode` | `Future<String?>` | ✅ |
| `networkType` | `Future<String?>` | ✅ |
| `isRoaming` | `Future<bool>` | ❌ |
| `hasSimCard` | `Future<bool>` | ✅ |
| `simCount` | `Future<int>` | ✅ |
| `isDualSim` | `Future<bool>` | ✅ |
| `isEsim` | `Future<bool>` | ✅ heuristic |
| `supportsEsim` | `Future<bool>` | ✅ entitlement |
| `deviceId` | `Future<String?>` | ❌ privacy |
| `allSimInfo` | `Future<List<SimCardInfo>>` | ✅ |
| `basicSimInfo` | `Future<SimCardInfo?>` | ✅ |
| `networkInfo` | `Future<NetworkInfo>` | ✅ |
| `simInfoForSubscription(int)` | `Future<SimCardInfo?>` | ❌ use `allSimInfo` |
| `networkGeneration` | `Future<NetworkGeneration>` | ✅ |
| `onChanged` | `Stream<SimCardChangeEvent>` | ✅ |
| `throwOnError` | `bool` (default `false`) | — |
| `clearCache()` | `void` | — |

> iOS cannot expose phone number, ICCID, IMEI/MEID or roaming status — those
> methods return an error there and surface as `null`.

### eSIM on iOS

`SimCardManager.supportsEsim` requires the `com.apple.developer.esim-access`
entitlement. Without it the check **always returns `false`**, even on
eSIM-capable devices.

1. Request the [eSIM access entitlement](https://developer.apple.com/contact/request/esim-access-entitlement)
   from Apple with your developer account.
2. Wait for Apple's approval.
3. Re-download the Development & Distribution provisioning profiles with the
   entitlement enabled.
4. Add the carrier descriptors to your `Info.plist`:

```xml
<key>CarrierDescriptors</key>
<array>
  <dict>
    <key>GID1</key><string>***</string>
    <key>GID2</key><string>***</string>
    <key>MCC</key><string>***</string> <!-- Country Code -->
    <key>MNC</key><string>***</string> <!-- Network Code -->
  </dict>
</array>
```

## 📊 SIM states

`SimState` enum values: `ready`, `absent`, `pinRequired`, `pukRequired`,
`networkLocked`, `notReady`, `permDisabled`, `cardIoError`, `cardRestricted`,
`unknown`.

## 🌐 Network types

`LTE`, `5G`, `HSPAP`, `HSPA`, `HSDPA`, `HSUPA`, `UMTS`, `EDGE`, `GPRS`, `CDMA`,
`EVDO_0`, `EVDO_A`, `EVDO_B`, `1xRTT`, `EHRPD`, `UNKNOWN`.

## ⚠️ Error handling

Every method returns `null` (or a sensible default) instead of throwing — the
plugin swallows platform exceptions internally. A `null` result means one of:

- no SIM card is present,
- the platform doesn't support the requested value,
- the required permission was not granted,
- an unexpected platform error occurred.

Native error codes you may see in logs: `PERMISSION_DENIED`, `SIM_*_ERROR`,
`NETWORK_*_ERROR`, `NOT_AVAILABLE_ON_IOS`.

### Typed errors (opt-in)

To distinguish failure modes instead of getting a silent `null`, enable
`throwOnError`. Methods then throw a `SimCardException` carrying the error code:

```dart
SimCardManager.throwOnError = true;

try {
  final number = await SimCardManager.phoneNumber;
} on SimCardException catch (e) {
  if (e.code == 'PERMISSION_DENIED') {
    // prompt the user for the READ_PHONE_STATE permission
  }
}
```

`throwOnError` defaults to `false`, so existing code keeps the `null`-on-failure
behavior.

## 🔒 Privacy considerations

This plugin can access personally identifiable information — phone numbers,
IMEI/MEID and SIM serial numbers. Before shipping:

- Declare data collection in your store privacy labels and privacy policy.
- Only request what your app actually needs.
- Comply with GDPR, CCPA and other applicable regulations.

The plugin includes an iOS `PrivacyInfo.xcprivacy` manifest.

## 💖 Support

If this plugin helps you, consider supporting development:

[![Buy Me A Coffee](https://www.buymeacoffee.com/assets/img/guidelines/download-assets-sm-1.svg)](https://buymeacoffee.com/is10vmust)

## 📞 Contact

Bugs and feature requests → [GitHub issues](https://github.com/mustafa-707/sim_card_code/issues).

## 📄 License

MIT — see [LICENSE](LICENSE).
