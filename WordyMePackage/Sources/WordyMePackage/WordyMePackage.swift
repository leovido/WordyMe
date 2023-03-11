import ComposableArchitecture

struct Feature: ReducerProtocol {
	struct State: Equatable {
		var word: Definition
	}
	
	enum Action: Equatable {
		case wordResponse(TaskResult<Definition>)
	}
	
	func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
		switch action {
			case let .wordResponse(.success(word)):
				state.word = word
				return .none
			case let .wordResponse(.failure(error)):
				return .none
		}
	}
}
