// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "WordyMePackage",
	platforms: [
		.iOS("16.1"),
	],
	products: [
		.library(
			name: "WordyMePackage",
			targets: ["WordyMePackage"]),
		.library(
			name: "AppFeature",
			targets: ["AppFeature"]),
		.library(
			name: "BrainLibraryFeature",
			targets: ["BrainLibraryFeature"]),
		.library(
			name: "StatsFeature",
			targets: ["StatsFeature"]),
		.library(
			name: "SpeechFeature",
			targets: ["SpeechFeature"])
	],
	dependencies: [
		.package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.52.0"),
		.package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
						 from: "1.11.0"),
		.package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "0.2.0"),
	],
	targets: [
		.target(
			name: "WordyMePackage",
			dependencies: [
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
				"SpeechFeature"
			],
			resources: [.process("Word.xcdatamodeld")]),
		.target(
			name: "AppFeature",
			dependencies: [
				"StatsFeature",
				"WordyMePackage"
			]),
		.target(
			name: "StatsFeature",
			dependencies: [
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]),
		.target(
			name: "BrainLibraryFeature",
			dependencies: [
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]),
		.target(
			name: "SpeechFeature",
			dependencies: [
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
				.product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
			]),
		.testTarget(
			name: "WordyMePackageTests",
			dependencies: [
				"WordyMePackage",
			])
	]
		.map { (target: Target) in
			target.swiftSettings = [.unsafeFlags([
				"-Xfrontend",
				"-warn-long-function-bodies=100",
				"-Xfrontend",
				"-warn-long-expression-type-checking=100"
			])]
			return target
		}
)

