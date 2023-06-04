import ComposableArchitecture
import Foundation

public struct FinanceComparisonReducer: ReducerProtocol {
  public init() {}

  public struct State: Equatable {
    @BindingState public var initial: Double
    @BindingState public var initialString: String
    @BindingState public var monthlyPayments: Double
    @BindingState public var years: UInt8
    @BindingState public var interestRate: Double
    @BindingState public var futureValue: Double?

    public init(initial: Double, monthlyPayments: Double, years: UInt8, interestRate: Double, futureValue: Double? = nil) {
      self.initial = initial
      initialString = initial.description
      self.monthlyPayments = monthlyPayments
      self.years = years
      self.interestRate = interestRate
      self.futureValue = futureValue
    }
  }

  public enum Action: Equatable, BindableAction {
    case futureValue
    case presentValue
    case paymentsNeededPerMonth
    case binding(BindingAction<State>)
  }

  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .binding:
        return .run { send in
          await send(.futureValue)
        }
      case .futureValue:

        state.futureValue = ExcelFormulas.fv(presentValue: state.initial,
                                             interestRate: Double(state.interestRate),
                                             term: state.monthlyPayments,
                                             years: Double(state.years))

        return .none
      case .presentValue:
        fatalError()
      case .paymentsNeededPerMonth:
        fatalError()
      }
    }
    BindingReducer()
  }
}

private enum ExcelFormulas {
  //	static func pmt(rate : Double, nper : Double, pv : Double, fv : Double = 0, type : Double = 0) -> Double {
  //		return ((-pv * ExcelFormulas.pvif(rate: rate, nper: nper) - fv) / ((1.0 + rate * type) * ExcelFormulas.fvifa(rate: rate, nper: nper)))
  //	}

//  static func pow1pm1(x: Double, y: Double) -> Double {
//    (x <= -1) ? pow(1 + x, y) - 1 : exp(y * log(1.0 + x)) - 1
//  }
//
//  static func pow1p(x: Double, y: Double) -> Double {
//    (abs(x) > 0.5) ? pow(1 + x, y) : exp(y * log(1.0 + x))
//  }

//  static func pvif(rate: Double, nper: Double) -> Double {
//    ExcelFormulas.pow1p(x: rate, y: nper)
//  }
//
//  static func fvifa(initial _: Double, rate: Double, nper: Double) -> Double {
//    (rate == 0) ? nper : ExcelFormulas.pow1pm1(x: rate, y: nper) / rate
//  }

  //	FV = PV (1 + i)t
  static func fv(presentValue: Double, interestRate: Double, term: Double, years: Double) -> Double {
    presentValue * pow(1 + interestRate, years * (term / 12))
  }
}
