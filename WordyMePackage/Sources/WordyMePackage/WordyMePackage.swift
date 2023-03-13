import ComposableArchitecture

public struct WordReducer: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable {
		public var word: Definition
		
		public init(word: Definition = .init(word: nil, phonetic: nil, phonetics: [], origin: nil, meanings: [])) {
			self.word = word
		}
	}
	
	public enum Action: Equatable {
		case wordResponse(TaskResult<Definition>)
	}
	
	public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
		switch action {
			case let .wordResponse(.success(word)):
				state.word = word
				return .none
			case .wordResponse(.failure(_)):
				return .none
		}
	}
}
