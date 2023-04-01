import ComposableArchitecture
import Foundation

public struct BrainReducer: ReducerProtocol {
  public init() {}

  public struct State {
    var string: String

    public init(string: String = "") {
      self.string = string
    }
  }

  public enum Action: Equatable {
    case something
  }

  public func reduce(into _: inout State, action: Action) -> EffectTask<Action> {
    switch action {
    case .something:
      return .none
    }
  }
}
