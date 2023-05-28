import ComposableArchitecture
import Foundation
// import SharedModels

public enum PeriodDaysLength: Int, Hashable {
  case five = 5
  case seven = 7
}

public enum Fem: Hashable {
  public static let cycle: Int = 28
  public static let ovulationDays: [Int] = [11, 12, 13]
  public static let eggHoursAlive: Int = 24
}

public struct PeriodCycle: Equatable {
  public var startDate: Date?
  public var endDate: Date?
}

public struct FemCycleReducer: ReducerProtocol {
  public init() {}

  public struct State: Equatable {
    public var cycle: [PeriodCycle]

    public var ovulationDates: [Date] = []

    @BindingState public var startDateOfCycle: Date?
    public var endDateOfCycle: Date? {
      guard let startDateOfCycle = startDateOfCycle else {
        return nil
      }
      var dc = DateComponents()
      dc.day = Fem.cycle

      return Calendar.current.date(byAdding: dc, to: startDateOfCycle) ?? Date()
    }

    public var estimatedStartDateOfPeriod: Date?

    public var startDateOfPeriod: Date?
    public var endDateOfPeriod: Date?

    public init(
      cycle: [PeriodCycle] = [],
      startDateOfCycle: Date? = nil,
      startDateOfPeriod: Date? = nil,
      endDateOfPeriod: Date? = nil,
      estimatedStartDateOfPeriod: Date? = nil
    ) {
      self.cycle = cycle
      self.startDateOfCycle = startDateOfCycle
      self.startDateOfPeriod = startDateOfPeriod
      self.endDateOfPeriod = endDateOfPeriod
      self.estimatedStartDateOfPeriod = estimatedStartDateOfPeriod

      ovulationDates = Fem.ovulationDays.compactMap { day in
        var dc = DateComponents()
        dc.day = day

        let date = Calendar.current.date(byAdding: dc, to: self.startDateOfCycle ?? Date())

        return date
      }
    }
  }

  public enum Action: Equatable {
    case generateCycles
    case inputCurrentPeriodEndDate(PeriodDaysLength)
    case inputCurrentStartCycleDate(Date)
    case confirmStartPeriodDate(Date)
    case confirmEndPeriodDate(Date)
  }

  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case let .confirmEndPeriodDate(date):

        return .none
      case let .confirmStartPeriodDate(date):

        return .none
      case let .inputCurrentStartCycleDate(startDate):

        state.startDateOfCycle = startDate

        var oneDayEstimate = DateComponents()
        oneDayEstimate.day = 1

        let oneDayDate = Calendar.current.date(byAdding: oneDayEstimate, to: state.endDateOfCycle!)

        state.estimatedStartDateOfPeriod = oneDayDate

        return .none
      case let .inputCurrentPeriodEndDate(periodDaysLength):

        var daysToAdd = DateComponents()
        daysToAdd.day = periodDaysLength.rawValue

        let endDateOfPeriod = Calendar.current.date(
          byAdding: daysToAdd,
          to: state.startDateOfPeriod!
        )

        state.endDateOfPeriod = endDateOfPeriod
        return .none
      case .generateCycles:
        // 3th of March end on 8th of March; day 1 was 9th of April
        // 4th of April end on 9th; day 1 was 10th of April
        let date = Date()
        let dc = DateComponents(calendar: Calendar.current, month: 3, day: 3, yearForWeekOfYear: 2023)

        var daysToAdd = DateComponents()
        daysToAdd.day = PeriodDaysLength.five.rawValue

        let endDateOfPeriod = Calendar.current.date(byAdding: daysToAdd,
                                                    to: dc.date!)

        dump(dc.date)

        return .none
      }
    }
  }
}
