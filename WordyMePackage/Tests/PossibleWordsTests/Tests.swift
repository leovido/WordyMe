import ComposableArchitecture
import XCTest

@testable import PossibleWordsFeature

@MainActor
final class PossibleWordsTests: XCTestCase {
	func testSomething() async {
		let store = TestStore(
			initialState: PossibleWordsReducer.State(),
			reducer: PossibleWordsReducer()
		) {
		}
	}
}
