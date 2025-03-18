# Sim Card Code

[![StandWithPalestine](https://raw.githubusercontent.com/TheBSD/StandWithPalestine/main/badges/StandWithPalestine.svg)](https://github.com/TheBSD/StandWithPalestine/blob/main/docs/README.md)
[![Pub Version](https://img.shields.io/pub/v/sim_card_code.svg)](https://pub.dev/packages/sim_card_code)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A lightweight Flutter plugin that provides access to SIM card country code information across iOS and Android platforms.

## 📋 Features

- Retrieve SIM card country code in ISO format (e.g., "US", "UK", "IN")
- Simple, straightforward API
- Support for multiple platforms

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

| Platform | Support |
| -------- | ------- |
| Android  | ✅      |
| iOS (9.0+) | ✅    |
| Web      | ❌      |
| macOS    | ❌      |
| Windows  | ❌      |
| Linux    | ❌      |

### iOS

No additional setup required for iOS 9.0 - 13.x.

## 🚀 Usage

Import the package:

```dart
import 'package:sim_card_code/sim_card_code.dart';
```

Retrieve the SIM country code:

```dart
try {
  final countryCode = await SimCardInfo.simCountryCode;
  print('SIM Country Code: $countryCode'); // Output: "US", "GB", etc.
} catch (e) {
  print('Could not retrieve SIM country code: $e');
}
```

## ⚠️ Handling Errors

The plugin returns `null` in the following cases:

- No SIM card is detected
- The device doesn't support this functionality
- Required permissions are not granted
- Any other error occurs during execution

## 💖 Support

If you find this plugin helpful, consider supporting the development:

[![Buy Me A Coffee](https://www.buymeacoffee.com/assets/img/guidelines/download-assets-sm-1.svg)](https://buymeacoffee.com/is10vmust)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📞 Contact

For bugs or feature requests, please create an issue on the GitHub repository.
