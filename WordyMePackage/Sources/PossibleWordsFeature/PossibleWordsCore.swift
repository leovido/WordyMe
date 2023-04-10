import ComposableArchitecture
import Foundation
import SharedModels

public struct PossibleWordsReducer: ReducerProtocol {
	public init() {}

	public struct State: Equatable {
		@BindingState public var possibleWords: [Transcription]

		public init(possibleWords: [Transcription] = []) {
			self.possibleWords = possibleWords
		}
	}

	public enum Action: Equatable {
		case receivePossibleWords([Transcription])
		case didReceiveNewWords
		case selectWord(String)
		case didClosePossibleWordsSheet
	}

	public var body: some ReducerProtocol<State, Action> {
		Reduce { state, action in
			switch action {
			case .didClosePossibleWordsSheet:
				state.possibleWords.removeAll()
				return .none
			case let .receivePossibleWords(newWords):
				state.possibleWords = newWords

				return .none
			case let .selectWord(selectedWord):
				return .none
			case .didReceiveNewWords:
				return .none
			}
		}
	}
}
