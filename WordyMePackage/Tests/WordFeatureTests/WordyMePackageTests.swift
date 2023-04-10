import ComposableArchitecture
import XCTest
import SharedModels

@testable import WordFeature

@MainActor
final class WordyMePackageTests: XCTestCase {
  func testSomething() async {
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
		) {_ in }
		
		await store.send(.possibleWordsFeature(.receivePossibleWords(mockWords))) {
			$0.possibleWordsFeature.possibleWords = mockWords
		}
		
		await store.receive(.possibleWordsFeature(.didReceiveNewWords)) {
			$0.hasPossibleWords = true
			$0.possibleWordsFeature.possibleWords = mockWords
		}
	}
}
