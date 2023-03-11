import ComposableArchitecture
import Foundation

public struct AppReducer: ReducerProtocol {
	public init() {}

	public struct State {
		var string: String
		
		public init(string: String = "") {
			self.string = string
		}
	}
	
	public enum Action: Equatable {
		case something
		case appDelegate(AppDelegateReducer.Action)
	}
	
	public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
		switch action {
			case .appDelegate(.didFinishLaunching):
				return .none
			case .appDelegate:
				return .none
			case .something:
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
	
	public func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
		switch action {
			case .didFinishLaunching:
				return .run { send in
				}
				
			case .didRegisterForRemoteNotifications(.failure):
				return .none
				
			case let .didRegisterForRemoteNotifications(.success(tokenData)):
				let token = tokenData.map { String(format: "%02.2hhx", $0) }.joined()
				return .fireAndForget {
					
				}
		}
	}
}

