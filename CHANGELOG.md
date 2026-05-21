# CHANGES

## 0.2.0

- **Swift Package Manager (SPM) support** — the iOS plugin now ships a
  `Package.swift`, so apps built with `--enable-swift-package-manager` (the
  upcoming Flutter default) no longer need CocoaPods. CocoaPods stays fully
  supported. Resolves [#8](https://github.com/mustafa-707/sim_card_code/issues/8).
- **Multi-SIM support** — new `SimCardManager.simInfoForSubscription(subscriptionId)`
  returns full info for a specific SIM via `TelephonyManager.createForSubscriptionId`
  on Android. Resolves [#6](https://github.com/mustafa-707/sim_card_code/issues/6).
- **Reactive change streams** — new `SimCardManager.onChanged` broadcast
  `Stream<SimCardChangeEvent>` fires on SIM insert/remove/swap and on
  network/operator/roaming changes. The cache is refreshed automatically
  before each event, so reads inside a listener return fresh data.
- **Typed network info** — added `NetworkType` and `NetworkGeneration` (2G–5G)
  enums, exposed via `NetworkInfo.type`, `NetworkInfo.generation` and
  `SimCardManager.networkGeneration`. The existing `networkType` string getter
  is unchanged.
- **Opt-in typed errors** — set `SimCardManager.throwOnError = true` to receive
  a `SimCardException` (with an error code) on failure instead of a silent
  `null`. Defaults to `false`, so existing behavior is preserved.
- Internal: split the Dart source into `models.dart` + `manager.dart`
  (no public API change).
- iOS: restructured `ios/` into the SPM package layout
  (`ios/sim_card_code/Sources/...`); CocoaPods consumers are unaffected.
- iOS: minimum deployment target raised to 13.0 to match current Flutter.
- iOS: corrected the podspec metadata (homepage, author, summary, version).
- iOS: `isEsim` device-model fallback now parses the model's major number, so
  it stays correct for iPhone 16, 17 and future models instead of relying on a
  hardcoded identifier list.
- Fixed `SimCardManager.clearCache()` not clearing the cached `supportsEsim`
  value.
- Android: bumped Kotlin 2.1.0 → 2.3.21, Android Gradle Plugin 8.7.3 → 8.11.1,
  `compileSdk` 35 → 36.
- Android: pinned the Gradle wrapper to stable 8.14 (was the `9.0-milestone-1`
  pre-release).
- Removed the legacy Android unit-test scaffold.
- Added `flutter_lints` + `analysis_options.yaml` and formatted the codebase.
- Improved the README and example app.

No breaking changes — the existing public Dart API is unchanged.

## 0.1.0

- Added new flag `isEsim` by @Praanim , to tell us if this sim is E-sim

## 0.0.9

- Handle phone number for android 13+

## 0.0.8

- Fixes on Android ~ getAllSimInfo

## 0.0.7

- Update README.md
- Solve type issues on iOS
- Return Locale.current.identifier if not found in iOS
- handle android phone number by permission (must to use permission handler)

## 0.0.6

- Update README.md
- Solve type issues

## 0.0.5

- Update README.md
- Solve Keep calling native issue

## 0.0.4

- Update README.md
- Add more information from sim card
- update version and gradle

## 0.0.3

- Handling for android deprecated methods <https://github.com/mustafa-707/sim_card_code/issues/1>.
- handling iOS compatibility issues
- update example and README

## 0.0.2

- Handle nullable state.

## 0.0.1

- Release the package.
