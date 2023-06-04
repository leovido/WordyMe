import ComposableArchitecture
import Counter
import DevCycle
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
    public var appDelegateState: AppDelegateReducer.State

    public init(string: String = "",
                wordState: WordReducer.State = .init(),
                statsState: StatsReducer.State = .init(),
                counterState: CounterReducer.State = .init(),
                appDelegateState: AppDelegateReducer.State = .init())
    {
      self.string = string
      self.wordState = wordState
      self.statsState = statsState
      self.counterState = counterState
      self.appDelegateState = appDelegateState
    }
  }

  public enum Action: Equatable {
    case appDelegate(AppDelegateReducer.Action)
    case wordFeature(WordReducer.Action)
    case statsFeature(StatsReducer.Action)
    case counterFeature(CounterReducer.Action)
    case onAppear
  }

  @Dependency(\.devCycleNotification) var devCycleNotification

  public var body: some ReducerProtocol<State, Action> {
    Reduce { _, action in
      switch action {
      case .onAppear:
        return .run { send in
          for await _ in await self.devCycleNotification() {
            await send(.appDelegate(.fetchAllFeatures))
          }
        }
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

    Scope(state: \.appDelegateState, action: /Action.appDelegate) {
      AppDelegateReducer()
    }
  }
}

public struct DevCycleFeatures: Equatable, ExpressibleByDictionaryLiteral {
  public typealias Key = String
  public typealias Value = Feature

  public var key: String
  public var value: Feature

  public init(key: String, value: Feature) {
    self.key = key
    self.value = value
  }

  public init(dictionaryLiteral elements: (String, Feature)...) {
    guard let (key, value) = elements.first else {
      fatalError("Invalid dictionary literal")
    }
    self.key = key
    self.value = value
  }
}

public struct AppDelegateReducer: ReducerProtocol {
  public struct State: Equatable {
    var allFeatures: DevCycleFeatures?
    var dvcClient: DVCClient?

    public init(allFeatures: DevCycleFeatures? = nil,
                dvcClient: DVCClient? = nil)
    {
      self.allFeatures = allFeatures
      self.dvcClient = dvcClient
    }
  }

  public enum Action: Equatable {
    case didFinishLaunching
    case didRegisterForRemoteNotifications(TaskResult<Data>)
    case fetchAllFeatures
    case setDVCClient(DVCClient)
  }

  public init() {}

  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .didFinishLaunching:
        return .run { action in
          guard let user = try? DVCUser.builder()
            .userId("4321")
            .build()
          else {
            fatalError()
          }

          let dvcClient = await dvcHandler(user: user)

          await action.send(.setDVCClient(dvcClient))

          //          SentrySDK.start { options in
//            options.dsn = "https://edaeff785d8d4f4ea20f5246a847471c@o4504940331728896.ingest.sentry.io/4504940332908544"
//            options.debug = true // Enabled debug when first installing is always helpful
//
//            // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
//            // We recommend adjusting this value in production.
//            options.tracesSampleRate = 1.0
//          }
        }

      case .didRegisterForRemoteNotifications(.failure):
        return .none

      case let .didRegisterForRemoteNotifications(.success(tokenData)):
        let token = tokenData.map { String(format: "%02.2hhx", $0) }.joined()
        return .fireAndForget {}
      case .fetchAllFeatures:
        guard let dvcClient = state.dvcClient else {
          return .none
        }
        let allFeatures = dvcClient.allFeatures()

        state.allFeatures = allFeatures.map { key, value in
          DevCycleFeatures(key: key, value: value)
        }
        .first!

        return .none
      case let .setDVCClient(dvcClient):
        state.dvcClient = dvcClient

        return .none
      }
    }
  }

  func dvcHandler(user: DVCUser) async -> DVCClient {
    guard let dvcClient = try? DVCClient.builder()
      .sdkKey("dvc_mobile_f8228e24_8593_4411_9d78_af36f7580c70_7161ddb")
      .user(user)
      .build(onInitialized: { error in
        guard error == nil else {
          fatalError()
        }

        NotificationCenter.default.post(name: NSNotification.Name("DevCycleInitialised"), object: nil)
      })
    else {
      fatalError()
    }

    return dvcClient
  }
}

extension DVCClient: Equatable {
  public static func == (lhs: DevCycle.DVCClient, rhs: DevCycle.DVCClient) -> Bool {
    lhs.allFeatures() == rhs.allFeatures()
  }
}

extension Feature: Equatable {
  public static func == (lhs: Feature, rhs: Feature) -> Bool {
    lhs.key == rhs.key
  }
}

extension DependencyValues {
  var devCycleNotification: @Sendable () async -> AsyncStream<Notification> {
    get { self[DevCycleNotification.self] }
    set { self[DevCycleNotification.self] = newValue }
  }
}

private enum DevCycleNotification: DependencyKey {
  static let liveValue: @Sendable () async -> AsyncStream = {
    AsyncStream(
      NotificationCenter.default
        .notifications(named: Notification.Name("DevCycleInitialised"))
    )
  }

  static let testValue: @Sendable () async -> AsyncStream = {
    AsyncStream(
      NotificationCenter.default
        .notifications(named: Notification.Name("DevCycleInitialised"))
    )
  }
}
