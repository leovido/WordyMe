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
	],
	dependencies: [
		.package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.52.0"),
		.package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
						 from: "1.11.0"),
	],
	targets: [
		.target(
			name: "WordyMePackage",
			dependencies: [
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			],
			resources: [.process("Word.xcdatamodeld")]),
		.target(
			name: "AppFeature",
			dependencies: [
				"WordyMePackage"
			]),
		.target(
			name: "BrainLibraryFeature",
			dependencies: [
			]),
		.testTarget(
			name: "WordyMePackageTests",
			dependencies: ["WordyMePackage"])
	]
)

