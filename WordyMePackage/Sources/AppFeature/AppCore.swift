import ComposableArchitecture
import Counter
import Foundation
import Sentry
import StatsFeature
import WordFeature

public struct AppReducer: ReducerProtocol {
  public init() {}

  public struct State: Equatable {
    var string: String
    public var wordState: WordReducer.State
    public var statsState: StatsReducer.State
    public var counterState: CounterReducer.State

    public init(string: String = "",
                wordState: WordReducer.State = .init(),
                statsState: StatsReducer.State = .init(),
                counterState: CounterReducer.State = .init())
    {
      self.string = string
      self.wordState = wordState
      self.statsState = statsState
      self.counterState = counterState
    }
  }

  public enum Action: Equatable {
    case appDelegate(AppDelegateReducer.Action)
    case wordFeature(WordReducer.Action)
    case statsFeature(StatsReducer.Action)
    case counterFeature(CounterReducer.Action)
  }

  public var body: some ReducerProtocol<State, Action> {
    Reduce { _, action in
      switch action {
      case .appDelegate(.didFinishLaunching):
        return .none
      case .appDelegate:
        return .none
      case .wordFeature:
        return .none
      case .statsFeature:
        return .none
      case .counterFeature:
        return .none
      }
    }

    Scope(state: \.wordState, action: /Action.wordFeature) {
      WordReducer()
    }

    Scope(state: \.statsState, action: /Action.statsFeature) {
      StatsReducer()
    }

    Scope(state: \.counterState, action: /Action.counterFeature) {
      CounterReducer()
    }
  }
}

public struct AppDelegateReducer: ReducerProtocol {
  public typealias State = Void

  public enum Action: Equatable {
    case didFinishLaunching
    case didRegisterForRemoteNotifications(TaskResult<Data>)
  }

  public init() {}

  public var body: some ReducerProtocol<State, Action> {
    Reduce { _, action in
      switch action {
      case .didFinishLaunching:
        return .run { _ in
          SentrySDK.start { options in
            options.dsn = "https://edaeff785d8d4f4ea20f5246a847471c@o4504940331728896.ingest.sentry.io/4504940332908544"
            options.debug = true // Enabled debug when first installing is always helpful

            // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
            // We recommend adjusting this value in production.
            options.tracesSampleRate = 1.0
          }
        }

      case .didRegisterForRemoteNotifications(.failure):
        return .none

      case let .didRegisterForRemoteNotifications(.success(tokenData)):
        let token = tokenData.map { String(format: "%02.2hhx", $0) }.joined()
        return .fireAndForget {}
      }
    }
  }
}
