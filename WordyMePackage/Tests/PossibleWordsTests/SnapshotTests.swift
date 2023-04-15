import Foundation
import SnapshotTesting
import XCTest
import ComposableArchitecture

@testable import PossibleWordsFeature
import SwiftUI

@MainActor
final class SnapshotTests: XCTestCase {
	func testViewNoSelection() {
		let store: StoreOf<PossibleWordsReducer> = .init(
			initialState: PossibleWordsReducer.State(possibleWords: [
				.init(formattedString: "Demo", segments: [
					.init(alternativeSubstrings: ["Alternative"], confidence: 0.89, duration: 1, substring: "", timestamp: 1)
				]),
				.init(formattedString: "Word", segments: [
					.init(alternativeSubstrings: ["Alternative"], confidence: 3, duration: 1, substring: "", timestamp: 1)
				])
			], selectedWord: nil),
			reducer: PossibleWordsReducer()
		)
		
		let view = UIHostingController(rootView: PossibilityView(store: store))
		
		assertSnapshot(matching: view, as: .image(on: .iPhoneX))
	}
	
	func testViewWithSelection() {
		let store: StoreOf<PossibleWordsReducer> = .init(
			initialState: PossibleWordsReducer.State(possibleWords: [
				.init(formattedString: "Demo", segments: [
					.init(alternativeSubstrings: ["Alternative"], confidence: 0.89, duration: 1, substring: "", timestamp: 1)
				]),
				.init(formattedString: "Word", segments: [
					.init(alternativeSubstrings: ["Alternative"], confidence: 3, duration: 1, substring: "", timestamp: 1)
				])
			], selectedWord: .init(formattedString: "Word", segments: [
				.init(alternativeSubstrings: ["Alternative"], confidence: 3, duration: 1, substring: "", timestamp: 1)
			 ])),
			reducer: PossibleWordsReducer()
		)
		
		let view = UIHostingController(rootView: PossibilityView(store: store))
		
		assertSnapshot(matching: view, as: .image(on: .iPhoneX))
	}
}
