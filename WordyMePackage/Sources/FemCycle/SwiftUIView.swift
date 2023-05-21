import ComposableArchitecture
import SwiftUI

struct ContentView: View {
  public let store: StoreOf<FemCycleReducer>

  private let calendar: Calendar
  private let monthFormatter: DateFormatter
  private let dayFormatter: DateFormatter
  private let weekDayFormatter: DateFormatter
  private let fullFormatter: DateFormatter

  private static var now = Date() // Cache now

  init(store: StoreOf<FemCycleReducer>,
       calendar: Calendar)
  {
    self.store = store
    self.calendar = calendar
    monthFormatter = DateFormatter(dateFormat: "MMMM", calendar: calendar)
    dayFormatter = DateFormatter(dateFormat: "d", calendar: calendar)
    weekDayFormatter = DateFormatter(dateFormat: "EEEEE", calendar: calendar)
    fullFormatter = DateFormatter(dateFormat: "MMMM dd, yyyy", calendar: calendar)
  }

  var body: some View {
    WithViewStore(store) { viewStore in
      VStack {
        Text("Selected date: \(fullFormatter.string(from: viewStore.startDateOfCycle!))")
          .bold()
          .foregroundColor(.red)
        CalendarView(
          calendar: calendar,
          date: .init(get: {
            viewStore.startDateOfCycle!
          }, set: { _ in

          }),
          content: { date in
            Button(action: {
              //						viewStore.startDateOfCycle = date
            }) {
              VStack {
                Text(" ")
                  .font(.largeTitle)
                  .frame(width: 50, height: 50)
                  .cornerRadius(8)
                  .background(
                    viewStore.ovulationDates.contains(date) ? .pink : .blue
                  )
              }
              .border(Color.black, width: 1)
              .padding(4)
              .overlay(
                Text(dayFormatter.string(from: date))
                  .foregroundColor(.black)
              )
            }
          },
          trailing: { date in
            Text(dayFormatter.string(from: date))
              .foregroundColor(.secondary)
          },
          header: { date in
            Text(weekDayFormatter.string(from: date))
          },
          title: { date in
            HStack {
              Text(monthFormatter.string(from: date))
                .font(.headline)
                .padding()
              Spacer()
              Button {
                withAnimation {
                  guard let newDate = calendar.date(
                    byAdding: .month,
                    value: -1,
                    to: viewStore.startDateOfCycle!
                  ) else {
                    return
                  }

                  //									viewStore.startDateOfCycle = newDate
                }
              } label: {
                Label(
                  title: { Text("Previous") },
                  icon: { Image(systemName: "chevron.left") }
                )
                .labelStyle(IconOnlyLabelStyle())
                .padding(.horizontal)
                .frame(maxHeight: .infinity)
              }
              Button {
                withAnimation {
                  guard let newDate = calendar.date(
                    byAdding: .month,
                    value: 1,
                    to: viewStore.startDateOfCycle!
                  ) else {
                    return
                  }

                  //									viewStore.startDateOfCycle = newDate
                }
              } label: {
                Label(
                  title: { Text("Next") },
                  icon: { Image(systemName: "chevron.right") }
                )
                .labelStyle(IconOnlyLabelStyle())
                .padding(.horizontal)
                .frame(maxHeight: .infinity)
              }
            }
            .padding(.bottom, 6)
          }
        )
        .equatable()
      }
      .padding()
    }
  }
}

// MARK: - Component

public struct CalendarView<Day: View, Header: View, Title: View, Trailing: View>: View {
  // Injected dependencies
  private var calendar: Calendar
  @Binding private var date: Date
  private let content: (Date) -> Day
  private let trailing: (Date) -> Trailing
  private let header: (Date) -> Header
  private let title: (Date) -> Title

  // Constants
  private let daysInWeek = 7

  public init(
    calendar: Calendar,
    date: Binding<Date>,
    @ViewBuilder content: @escaping (Date) -> Day,
    @ViewBuilder trailing: @escaping (Date) -> Trailing,
    @ViewBuilder header: @escaping (Date) -> Header,
    @ViewBuilder title: @escaping (Date) -> Title
  ) {
    self.calendar = calendar
    _date = date
    self.content = content
    self.trailing = trailing
    self.header = header
    self.title = title
  }

  public var body: some View {
    let month = date.startOfMonth(using: calendar)
    let days = makeDays()

    return LazyVGrid(columns: Array(repeating: GridItem(), count: daysInWeek)) {
      Section(header: title(month)) {
        ForEach(days.prefix(daysInWeek), id: \.self, content: header)
        ForEach(days, id: \.self) { date in
          if calendar.isDate(date, equalTo: month, toGranularity: .month) {
            content(date)
          } else {
            trailing(date)
          }
        }
      }
    }
  }
}

// MARK: - Conformances

extension CalendarView: Equatable {
  public static func == (lhs: CalendarView<Day, Header, Title, Trailing>, rhs: CalendarView<Day, Header, Title, Trailing>) -> Bool {
    lhs.calendar == rhs.calendar && lhs.date == rhs.date
  }
}

// MARK: - Helpers

private extension CalendarView {
  func makeDays() -> [Date] {
    guard let monthInterval = calendar.dateInterval(of: .month, for: date),
          let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
          let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1)
    else {
      return []
    }

    let dateInterval = DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end)
    return calendar.generateDays(for: dateInterval)
  }
}

private extension Calendar {
  func generateDates(
    for dateInterval: DateInterval,
    matching components: DateComponents
  ) -> [Date] {
    var dates = [dateInterval.start]

    enumerateDates(
      startingAfter: dateInterval.start,
      matching: components,
      matchingPolicy: .nextTime
    ) { date, _, stop in
      guard let date = date else { return }

      guard date < dateInterval.end else {
        stop = true
        return
      }

      dates.append(date)
    }

    return dates
  }

  func generateDays(for dateInterval: DateInterval) -> [Date] {
    generateDates(
      for: dateInterval,
      matching: dateComponents([.hour, .minute, .second], from: dateInterval.start)
    )
  }
}

private extension Date {
  func startOfMonth(using calendar: Calendar) -> Date {
    calendar.date(
      from: calendar.dateComponents([.year, .month], from: self)
    ) ?? self
  }
}

private extension DateFormatter {
  convenience init(dateFormat: String, calendar: Calendar) {
    self.init()
    self.dateFormat = dateFormat
    self.calendar = calendar
  }
}

// MARK: - Previews

#if DEBUG
  struct CalendarView_Previews: PreviewProvider {
    static let startDateCycle = DateComponents(calendar: Calendar.current, month: 5, day: 8, yearForWeekOfYear: 2023).date!

    static let store: Store<FemCycleReducer.State, FemCycleReducer.Action> = .init(
      initialState: .init(startDateOfCycle: startDateCycle),
      reducer: FemCycleReducer()
    )

    static var previews: some View {
      Group {
        ContentView(store: store, calendar: Calendar(identifier: .gregorian))
      }
    }
  }
#endif
