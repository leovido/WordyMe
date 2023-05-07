import ComposableArchitecture
import XCTest

@testable import FemCycle

@MainActor
final class FemCycleTests: XCTestCase {
	func testSomething() async {
		let store = TestStore(
			initialState: FemCycleReducer.State(),
			reducer: FemCycleReducer()
		)
		
		await store.send(.generateCycles)
	}
	
	func testInputPeriodDate() async {
		let store = TestStore(
			initialState: FemCycleReducer.State(startDateOfPeriod: DateComponents(calendar: .current, month: 3, day: 3, yearForWeekOfYear: 2023).date!),
			reducer: FemCycleReducer()
		)
		
		let expectedDate = DateComponents(calendar: .current, month: 3, day: 8, yearForWeekOfYear: 2023).date!
		let expectedDate2 = DateComponents(calendar: .current, month: 3, day: 10, yearForWeekOfYear: 2023).date!

		await store.send(.inputCurrentPeriodEndDate(.five)) {
			$0.endDateOfPeriod = expectedDate
		}
		
		await store.send(.inputCurrentPeriodEndDate(.seven)) {
			$0.endDateOfPeriod = expectedDate2
		}
	}
	
	func testInputCycleStart() async {
		let store = TestStore(
			initialState: FemCycleReducer.State(),
			reducer: FemCycleReducer()
		)
		
		let input = DateComponents(
			calendar: .current,
			timeZone: .gmt,
				month: 4,
				day: 10,
			 	yearForWeekOfYear: 2023
			).date!
		
		let expectedEndCycleDate = DateComponents(
			calendar: .current,
			timeZone: .gmt,
			month: 5,
			day: 8,
			yearForWeekOfYear: 2023
		).date!
		
		let expectedPeriodDate = DateComponents(
			calendar: .current,
			timeZone: .gmt,
			month: 5,
			day: 9,
			yearForWeekOfYear: 2023
		).date!

		await store.send(.inputCurrentStartCycleDate(input)) {
			$0.startDateOfCycle = input
			$0.endDateOfCycle = expectedEndCycleDate
			$0.estimatedStartDateOfPeriod = expectedPeriodDate
		}
	}
}
