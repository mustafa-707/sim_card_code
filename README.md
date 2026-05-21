# sim_card_code

[![StandWithPalestine](https://raw.githubusercontent.com/TheBSD/StandWithPalestine/main/badges/StandWithPalestine.svg)](https://github.com/TheBSD/StandWithPalestine/blob/main/docs/README.md)
[![Pub Version](https://img.shields.io/pub/v/sim_card_code.svg)](https://pub.dev/packages/sim_card_code)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A Flutter plugin for SIM card and cellular network info on Android & iOS —
country code, operator, network type, eSIM status, multi-SIM and live changes.

## Features

- **SIM** — country code, operator, ICCID, phone number, state, eSIM flag
- **Network** — operator, country, type, 2G–5G generation, roaming
- **Multi-SIM** — count, dual-SIM detection, per-SIM lookup by subscription id
- **Device** — device id (IMEI/MEID), hardware eSIM support
- **Live updates** — a `Stream` of SIM / network changes

## Install

```yaml
dependencies:
  sim_card_code: ^0.2.0
```

iOS works with both CocoaPods and Swift Package Manager — no setup needed.

## Usage

```dart
import 'package:sim_card_code/sim_card_code.dart';

// SIM + network
final country = await SimCardManager.simCountryCode;  // "US"
final net     = await SimCardManager.networkInfo;     // operator, type, generation
final esim    = await SimCardManager.isEsim;

// All SIMs, or one SIM by subscription id (multi-SIM)
final sims = await SimCardManager.allSimInfo;
final one  = await SimCardManager.simInfoForSubscription(sims.first.subscriptionId!);

// Live changes — SIM insert/remove/swap, network/roaming
SimCardManager.onChanged.listen((e) => print('changed: ${e.type}'));
```

Failures return `null` by default. Set `SimCardManager.throwOnError = true` to
get a `SimCardException` instead.

## Permissions

**Android** — add to `AndroidManifest.xml`, then request at runtime (e.g. with
[`permission_handler`](https://pub.dev/packages/permission_handler)):

```xml
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
```

**iOS** — no setup. `supportsEsim` needs the
[`com.apple.developer.esim-access`](https://developer.apple.com/contact/request/esim-access-entitlement)
entitlement, otherwise it always returns `false`.

## Platform support

| Platform | Min | Notes |
| -------- | --- | ----- |
| Android  | API 21 | full support |
| iOS      | 13.0 | no phone number / IMEI / ICCID / roaming (privacy) |

## Support

If this plugin helps you, consider supporting development:

[![Buy Me A Coffee](https://www.buymeacoffee.com/assets/img/guidelines/download-assets-sm-1.svg)](https://buymeacoffee.com/is10vmust)

## License

MIT — see [LICENSE](LICENSE).
