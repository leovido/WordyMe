import ComposableArchitecture
import XCTest

@testable import FinanceComparison

@MainActor
final class FinanceComparisonTests: XCTestCase {
  func testSomething() async {
    let store = TestStore(
      initialState: FinanceComparisonReducer.State(
        initial: 1,
        monthlyPayments: 12,
        years: 1,
        interestRate: 0.10,
        futureValue: nil
      ),
      reducer: FinanceComparisonReducer()
    )

    await store.send(.futureValue) {
      $0.futureValue = 1.10
    }
  }
}
