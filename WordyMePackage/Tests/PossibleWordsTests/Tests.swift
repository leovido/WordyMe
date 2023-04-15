import ComposableArchitecture
import XCTest
import SharedModels

@testable import PossibleWordsFeature

@MainActor
final class PossibleWordsTests: XCTestCase {
	let expectedValue = [
		Transcription(formattedString: "Fancy",
																 segments: [
																	.init(alternativeSubstrings: ["Fans", "Fancied"], confidence: 0.04, duration: 1, substring: "", timestamp: 1)
																 ]),
		Transcription(formattedString: "Fancied",
																 segments: [
																	.init(alternativeSubstrings: ["Fans", "Fancied"], confidence: 0.04, duration: 1, substring: "", timestamp: 1)
																 ])
	]
	
	func testSomething() async {
		let store = TestStore(
			initialState: PossibleWordsReducer.State(),
			reducer: PossibleWordsReducer()
		)
	}
	
	func testHightlightWord() async {
		let expectedValue = [
			Transcription(formattedString: "Fancy",
																	 segments: [
																		.init(alternativeSubstrings: ["Fans", "Fancied"], confidence: 0.04, duration: 1, substring: "", timestamp: 1)
																	 ]),
			Transcription(formattedString: "Fancied",
																	 segments: [
																		.init(alternativeSubstrings: ["Fans", "Fancied"], confidence: 0.04, duration: 1, substring: "", timestamp: 1)
																	 ])
		]
		let store = TestStore(
			initialState: PossibleWordsReducer.State(possibleWords: expectedValue),
			reducer: PossibleWordsReducer()
		)
		
		await store.send(.selectWord(expectedValue.first!)) {
			$0.possibleWords = expectedValue
			$0.selectedWord = expectedValue.first!
		}
	}
	
	func testDidCloseModal() async {
		let expectedValue = [
			Transcription(formattedString: "Fancy",
																	 segments: [
																		.init(alternativeSubstrings: ["Fans", "Fancied"], confidence: 0.04, duration: 1, substring: "", timestamp: 1)
																	 ]),
			Transcription(formattedString: "Fancied",
																	 segments: [
																		.init(alternativeSubstrings: ["Fans", "Fancied"], confidence: 0.04, duration: 1, substring: "", timestamp: 1)
																	 ])
		]
		let store = TestStore(
			initialState: PossibleWordsReducer.State(possibleWords: expectedValue),
			reducer: PossibleWordsReducer()
		)
		
		await store.send(.didClosePossibleWordsSheet) {
			$0.possibleWords = []
		}
		
		await store.receive(.selectWord(nil))
	}
	
	func testReceivePossibleWords() async {
		let expectedValue = [
			Transcription(formattedString: "Fancy",
																	 segments: [
																		.init(alternativeSubstrings: ["Fans", "Fancied"], confidence: 0.04, duration: 1, substring: "", timestamp: 1)
																	 ]),
			Transcription(formattedString: "Fancied",
																	 segments: [
																		.init(alternativeSubstrings: ["Fans", "Fancied"], confidence: 0.04, duration: 1, substring: "", timestamp: 1)
																	 ])
		]
		
		let store = TestStore(
			initialState: PossibleWordsReducer.State(possibleWords: expectedValue),
			reducer: PossibleWordsReducer()
		)
		
		await store.send(.receivePossibleWords(expectedValue))
	}
	
	func testDidReceiveNewWords() async {
		let store = TestStore(
			initialState: PossibleWordsReducer.State(possibleWords: []),
			reducer: PossibleWordsReducer()
		)
		
		await store.send(.didReceiveNewWords)
	}
	
	func testConfirmSelection() async {
		let store = TestStore(
			initialState: PossibleWordsReducer.State(possibleWords: expectedValue),
			reducer: PossibleWordsReducer()
		)
		
		await store.send(.confirmSelection)
		await store.receive(.didClosePossibleWordsSheet) {
			$0.possibleWords = []
		}
		await store.receive(.selectWord(nil))
	}
	
	func testView() {
		let store = Store(initialState: PossibleWordsReducer.State(),
											reducer: PossibleWordsReducer())
		let view = PossibilityView(store: store)
	}
}
