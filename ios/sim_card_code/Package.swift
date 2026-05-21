// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "sim_card_code",
  platforms: [
    .iOS("13.0"),
  ],
  products: [
    .library(name: "sim-card-code", targets: ["sim_card_code"]),
  ],
  dependencies: [
    .package(name: "FlutterFramework", path: "../FlutterFramework"),
  ],
  targets: [
    .target(
      name: "sim_card_code",
      dependencies: [
        .product(name: "FlutterFramework", package: "FlutterFramework"),
      ],
      resources: [
        .process("PrivacyInfo.xcprivacy"),
      ],
      linkerSettings: [
        .linkedFramework("CoreTelephony"),
      ]
    ),
  ]
)
