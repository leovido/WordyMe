// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "WordyMePackage",
  platforms: [
    .iOS("16.1"),
    .macOS("13"),
  ],
  products: [
    .library(
      name: "WordFeature",
      targets: ["WordFeature"]
    ),
    .library(
      name: "AppFeature",
      targets: ["AppFeature"]
    ),
    .library(
      name: "BrainLibraryFeature",
      targets: ["BrainLibraryFeature"]
    ),
    .library(
      name: "SpeechFeature",
      targets: ["SpeechFeature"]
    ),
    .library(
      name: "StyleGuide",
      targets: ["StyleGuide"]
    ),

  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.52.0"),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
             from: "1.11.0"),
    .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "0.2.0"),
    .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.49.0"),
    .package(url: "https://github.com/getsentry/sentry-cocoa", from: "8.3.3"),
  ],
  targets: [
    .target(name: "BuildTools"),
    .target(
      name: "WordFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "SpeechFeature",
        "StyleGuide",
      ],
      resources: [.process("Word.xcdatamodeld")]
    ),
    .target(
      name: "AppFeature",
      dependencies: [
        "StatsFeature",
        "WordFeature",
        "StyleGuide",
        .product(name: "Sentry", package: "sentry-cocoa"),
      ]
    ),
    .target(
      name: "StatsFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .target(
      name: "BrainLibraryFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .target(
      name: "SpeechFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
      ]
    ),
    .target(
      name: "StyleGuide",
      dependencies: []
    ),
    .testTarget(
      name: "WordFeatureTests",
      dependencies: [
        "WordFeature",
      ]
    ),
  ]
  .map { (target: Target) in
    target.swiftSettings = [.unsafeFlags([
      "-Xfrontend",
      "-warn-long-function-bodies=100",
      "-Xfrontend",
      "-warn-long-expression-type-checking=100",
    ])]
    return target
  }
)
