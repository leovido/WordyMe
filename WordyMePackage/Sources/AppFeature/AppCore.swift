import ComposableArchitecture
import Foundation
import WordyMePackage
import StatsFeature

public struct AppReducer: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable {
		var string: String
		public var wordState: WordReducer.State
		public var statsState: StatsReducer.State

		public init(string: String = "",
								wordState: WordReducer.State = .init(),
								statsState: StatsReducer.State = .init()) {
			self.string = string
			self.wordState = wordState
			self.statsState = statsState
		}
	}
	
	public enum Action: Equatable {
		case appDelegate(AppDelegateReducer.Action)
		case wordFeature(WordReducer.Action)
		case statsFeature(StatsReducer.Action)
	}
	
	public var body: some ReducerProtocol<State, Action> {
		Reduce { state, action in
			switch action {
			case .appDelegate(.didFinishLaunching):
				return .none
			case .appDelegate:
				return .none
			case .wordFeature:
				return .none
			case .statsFeature:
				return .none
			}
		}
		
		Scope(state: \.wordState, action: /Action.wordFeature) {
			WordReducer()
		}
		
		Scope(state: \.statsState, action: /Action.statsFeature) {
			StatsReducer()
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
		Reduce { state, action in
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
}

