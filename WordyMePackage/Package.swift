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
      name: "AppFeature",
      targets: ["AppFeature"]
    ),
    .library(
      name: "Common",
      targets: ["Common"]
    ),
    .library(
      name: "Counter",
      targets: ["Counter"]
    ),
    .library(
      name: "FemCycle",
      targets: ["FemCycle"]
    ),
    .library(
      name: "FinanceComparison",
      targets: ["FinanceComparison"]
    ),
    .library(
      name: "WordFeature",
      targets: ["WordFeature"]
    ),
    .library(
      name: "BrainLibraryFeature",
      targets: ["BrainLibraryFeature"]
    ),
    .library(
      name: "PossibleWordsFeature",
      targets: ["PossibleWordsFeature"]
    ),
    .library(
      name: "SharedModels",
      targets: ["SharedModels"]
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
      name: "AppFeature",
      dependencies: [
        "StatsFeature",
        "WordFeature",
        "StyleGuide",
        "Counter",
        .product(name: "Sentry", package: "sentry-cocoa"),
      ]
    ),
    .target(
      name: "Common",
      dependencies: [
      ]
    ),
    .target(
      name: "Counter",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .target(
      name: "FinanceComparison",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
				"StyleGuide"
      ]
    ),
		.testTarget(
			name: "FinanceComparisonTests",
			dependencies: [
				"FinanceComparison",
			]
		),
    .target(
      name: "FemCycle",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .testTarget(
      name: "FemCycleTests",
      dependencies: [
        "FemCycle",
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
      name: "SharedModels",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .target(
      name: "PossibleWordsFeature",
      dependencies: [
        "SharedModels",
        "StyleGuide",
      ]
    ),
    .testTarget(
      name: "PossibleWordsTests",
      dependencies: [
        "PossibleWordsFeature",
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
      ]
    ),
    .target(
      name: "SpeechFeature",
      dependencies: [
        "SharedModels",
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
      ]
    ),
    .target(
      name: "StyleGuide",
      dependencies: []
    ),
    .target(
      name: "WordFeature",
      dependencies: [
        "Common",
        "SharedModels",
        "SpeechFeature",
        "StyleGuide",
        "PossibleWordsFeature",
      ],
      resources: [.process("Word.xcdatamodeld")]
    ),
    .testTarget(
      name: "WordFeatureTests",
      dependencies: [
        "WordFeature",
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
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
