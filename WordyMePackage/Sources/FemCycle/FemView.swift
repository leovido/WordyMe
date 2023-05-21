import ComposableArchitecture
import SwiftUI

struct FemView: View {
  public let store: StoreOf<FemCycleReducer>

  public init(store: StoreOf<FemCycleReducer>) {
    self.store = store
  }

  var df: DateFormatter {
    let dff = DateFormatter()
    dff.dateFormat = "d"

    return dff
  }

  var body: some View {
    WithViewStore(store) { _ in
      EmptyView()
      //			EquatableCalendarView.init(interval: .init(start: viewStore.startDateOfCycle!, end: viewStore.endDateOfCycle!), value: Date()) { currentDate in
      //				VStack {
      //					HStack {
      //						Spacer()
      //						Text(df.string(from: currentDate))
      //							.font(.caption)
      //					}
      //					.padding(.vertical, 4)
//
      //					Text("🍑")
      //						.font(.largeTitle)
      //						.frame(width: 50, height: 50)
      //				}
      //				.border(Color.black, width: 1)
      //				.padding(4)
      //			}
      //			.padding()
    }
  }
}

struct FemView_Previews: PreviewProvider {
  static let dc = DateComponents(calendar: Calendar.current, month: 3, day: 10, yearForWeekOfYear: 2023)

  static let store: Store<FemCycleReducer.State, FemCycleReducer.Action> = .init(
    initialState: .init(startDateOfCycle: dc.date!),
    reducer: FemCycleReducer()
  )

  static var count: Int = 0
  //	static let viewStore: ViewStore<WordReducer.State, WordReducer.Action> = .init(store)
  static var previews: some View {
    Group {
      FemView(store: store)
    }
  }
}

// extension Calendar {
//	func generateDates(
//		inside interval: DateInterval,
//		matching components: DateComponents
//	) -> [Date] {
//		var dates: [Date] = []
//		dates.append(interval.start)
//
//		enumerateDates(
//			startingAfter: interval.start,
//			matching: components,
//			matchingPolicy: .nextTime
//		) { date, _, stop in
//			if let date = date {
//				if date < interval.end {
//					dates.append(date)
//				} else {
//					stop = true
//				}
//			}
//		}
//
//		return dates
//	}
// }
//
// extension DateFormatter {
//	static let monthAndYear: DateFormatter = {
//		let formatter = DateFormatter()
//		formatter.setLocalizedDateFormatFromTemplate("MMMM yyyy")
//		return formatter
//	}()
// }
//
// struct EquatableCalendarView<DateView: View, Value: Equatable>: View, Equatable {
//	static func == (
//		lhs: EquatableCalendarView<DateView, Value>,
//		rhs: EquatableCalendarView<DateView, Value>
//	) -> Bool {
//		lhs.interval == rhs.interval && lhs.value == rhs.value && lhs.showHeaders == rhs.showHeaders
//	}
//
//	let interval: DateInterval
//	let value: Value
//	let showHeaders: Bool
//	let onHeaderAppear: (Date) -> Void
//	let content: (Date) -> DateView
//
//	init(
//		interval: DateInterval,
//		value: Value,
//		showHeaders: Bool = true,
//		onHeaderAppear: @escaping (Date) -> Void = { _ in },
//		@ViewBuilder content: @escaping (Date) -> DateView
//	) {
//		self.interval = interval
//		self.value = value
//		self.showHeaders = showHeaders
//		self.onHeaderAppear = onHeaderAppear
//		self.content = content
//	}
//
//	var body: some View {
//		CalendarView(
//			interval: interval,
//			showHeaders: showHeaders,
//			onHeaderAppear: onHeaderAppear
//		) { date in
//			content(date)
//		}
//	}
// }
//
// struct CalendarView<DateView>: View where DateView: View {
//	let interval: DateInterval
//	let showHeaders: Bool
//	let onHeaderAppear: (Date) -> Void
//	let content: (Date) -> DateView
//
//	@Environment(\.sizeCategory) private var contentSize
//	@Environment(\.calendar) private var calendar
//	@State private var months: [Date] = []
//	@State private var days: [Date: [Date]] = [:]
//
//	private var columns: [GridItem] {
//		let spacing: CGFloat = contentSize.isAccessibilityCategory ? 2 : 8
//		return Array(repeating: GridItem(spacing: spacing), count: 7)
//	}
//
//	var body: some View {
//		LazyVGrid(columns: columns) {
//			ForEach(months, id: \.self) { month in
//				Section(header: header(for: month)) {
//					ForEach(days[month, default: []], id: \.self) { date in
//						if calendar.isDate(date, equalTo: month, toGranularity: .month) {
//							content(date).id(date)
//						} else {
//							content(date).hidden()
//						}
//					}
//				}
//			}
//		}
//		.onAppear {
//			months = calendar.generateDates(
//				inside: interval,
//				matching: DateComponents(day: 1, hour: 0, minute: 0, second: 0)
//			)
//
//			days = months.reduce(into: [:]) { current, month in
//				guard
//					let monthInterval = calendar.dateInterval(of: .month, for: month),
//					let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
//					let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end)
//				else { return }
//
//				current[month] = calendar.generateDates(
//					inside: DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end),
//					matching: DateComponents(hour: 0, minute: 0, second: 0)
//				)
//			}
//		}
//	}
//
//	private func header(for month: Date) -> some View {
//		Group {
//			if showHeaders {
//				Text(DateFormatter.monthAndYear.string(from: month))
//					.font(.title)
//					.padding()
//			}
//		}
//		.onAppear { onHeaderAppear(month) }
//	}
// }
