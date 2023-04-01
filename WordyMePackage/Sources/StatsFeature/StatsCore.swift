import ComposableArchitecture
import Foundation

public struct Stats: Identifiable, Codable, Hashable {
    public var id: UUID = .init()

    var name: String
    var amount: Double
}

public struct StatsReducer: ReducerProtocol {
    public init() {}

    public struct State: Equatable {
        var stats: [Stats]

        public init(stats: [Stats] = []) {
            self.stats = stats
        }
    }

    public enum Action: Equatable {
        case onAppear
        case fetchStats
        case receiveStats(TaskResult<[Stats]>)
    }

    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .fetchStats:
            return .none
        case let .receiveStats(.success(tasks)):
            return .none
        case let .receiveStats(.failure(error)):
            return .none
        case .onAppear:
            state.stats = [.init(name: "Total words", amount: 39)]
            return .none
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

    public func reduce(into _: inout State, action: Action) -> Effect<Action, Never> {
        switch action {
        case .didFinishLaunching:
            return .run { _ in
            }

        case .didRegisterForRemoteNotifications(.failure):
            return .none

        case let .didRegisterForRemoteNotifications(.success(tokenData)):
            let token = tokenData.map { String(format: "%02.2hhx", $0) }.joined()
            return .fireAndForget {}
        }
    }
}
