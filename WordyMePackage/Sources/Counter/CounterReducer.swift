import ComposableArchitecture

public struct CounterReducer: ReducerProtocol {
  public init() {}

  public struct State: Equatable {
    public var count: Int

    public init(count: Int = 0) {
      self.count = count
    }
  }

  public enum Action: Hashable {
    case incrementCount
    case fetchTotalCount
    case resetCount
  }

  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .resetCount:
        state.count = 0
        return .none
      case .incrementCount:
        state.count += 1

        return .none
      case .fetchTotalCount:
        return .none
      }
    }
  }
}
