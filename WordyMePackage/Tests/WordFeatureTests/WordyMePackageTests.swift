import ComposableArchitecture
import XCTest

@testable import WordFeature

@MainActor
final class WordyMePackageTests: XCTestCase {
  func testSomething() async {
    let mock = Definition(word: "String", phonetic: nil, phonetics: [], origin: nil, meanings: [])

    // Create a test store with the initial state
    let store = TestStore(
      initialState: WordReducer.State(
        word: [mock]
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
      $0.word = [mock]
    }
  }
}
