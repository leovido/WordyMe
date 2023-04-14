import ComposableArchitecture
import XCTest
import SharedModels

@testable import WordFeature

@MainActor
final class WordyMePackageTests: XCTestCase {
  func testFetchWord() async {
    let mock = Definition(word: "String", phonetic: nil, phonetics: [], origin: nil, meanings: [])

    let store = TestStore(
      initialState: WordReducer.State(
				wordDefinitions: [mock]
      ),
      reducer: WordReducer()
    ) {
      $0.wordClient.fetchWord = { word in
        [Definition(word: word, phonetic: nil, phonetics: [], origin: nil, meanings: [])]
      }
    }
    store.dependencies.wordClient = WordClient.testValue

    await store.send(.fetchWord(mock.word!)) {
      $0.isLoading = true
    }

    await store.receive(.wordResponse(mock)) {
      $0.isLoading = false
      $0.wordDefinitions = [mock]
    }
  }
	
	func testPossibleWords() async {
		let mockWords = [
			Transcription(
				formattedString: "Alt",
				segments: [
					TranscriptionSegment(
						alternativeSubstrings: ["Oat", "Oak", "Old"],
						confidence: 0.50,
						duration: 1,
						substring: "",
						timestamp: 1
					)
				]
			)
		]

		let store = TestStore(
			initialState: WordReducer.State(),
			reducer: WordReducer()
		) { _ in }
		
		await store.send(.possibleWordsFeature(.receivePossibleWords(mockWords))) {
			$0.possibleWordsFeature.possibleWords = mockWords
		}
		
		await store.receive(.possibleWordsFeature(.didReceiveNewWords)) {
			$0.hasPossibleWords = true
			$0.possibleWordsFeature.possibleWords = mockWords
		}
	}
	
	func testOnAppear() async {
		let (wordNotification, wordCreated) = AsyncStream<String>.streamWithContinuation()

		let store = TestStore(
			initialState: WordReducer.State(),
			reducer: WordReducer()
		) {
			$0.wordNotification = { wordNotification }
		}
		wordCreated.yield("Testing")

		let task = await store.send(.onAppear)
		await store.receive(.setWord("Testing")) {
			$0.newWord = "Testing"
		}

		await task.cancel()
		
		// Simulate a screenshot being taken to show no effects are executed.
		wordCreated.yield("Testing false")
	}
	
	func testPhonetics() async {
		let store = TestStore(
			initialState: WordReducer.State(),
			reducer: WordReducer()
		)
		
		dump(store.state.phonetic)
		XCTAssertEqual(store.state.phonetic, "[]")
		XCTAssertTrue(store.state.definitionElements.isEmpty)
	}
}
