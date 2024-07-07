# Sim Card Info Plugin

A Flutter plugin for accessing SIM card Country Code.

## Features

- Retrieve SIM country code.

## Supported Platforms

- iOS (9.0 and above)
- Android

## iOS 14 and Above

Starting from iOS 14, the `serviceSubscriberCellularProviders` property used to retrieve SIM card information is deprecated. The plugin currently uses this method, so consider alternative approaches for future iOS updates. Always refer to the latest Apple documentation for recommended practices regarding access to SIM card information.

## Usage

To use this plugin, add `sim_card_code` as a dependency in your `pubspec.yaml` file.

### Example

```dart
    final phoneContryCode = await SimCardInfo.simCountryCode; // Output is "XX" Country code upper letters
```

## Limitations

- Access to SIM card information depends on the availability and permissions granted by the user.

## Support

If you find this plugin helpful, consider supporting me:

[![Buy Me A Coffee](https://www.buymeacoffee.com/assets/img/guidelines/download-assets-sm-1.svg)](https://buymeacoffee.com/is10vmust)
