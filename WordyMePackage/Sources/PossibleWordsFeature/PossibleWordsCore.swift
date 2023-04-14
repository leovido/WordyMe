import ComposableArchitecture
import Foundation
import SharedModels

public struct PossibleWordsReducer: ReducerProtocol {
	public init() {}

	public struct State: Equatable {
		@BindingState public var possibleWords: [Transcription]
		public var selectedWord: Transcription?

		public init(possibleWords: [Transcription] = [], selectedWord: Transcription? = nil) {
			self.possibleWords = possibleWords
			self.selectedWord = selectedWord
		}
	}

	public enum Action: Equatable {
		case receivePossibleWords([Transcription])
		case didReceiveNewWords
		case selectWord(Transcription?)
		case didClosePossibleWordsSheet
		case confirmSelection
	}

	public var body: some ReducerProtocol<State, Action> {
		Reduce { state, action in
			switch action {
			case .didClosePossibleWordsSheet:
				state.possibleWords.removeAll()
				return .run { send in
					await send(.selectWord(nil))
				}
			case let .receivePossibleWords(newWords):
				state.possibleWords = newWords

				return .none
			case let .selectWord(selectedWord):
				state.selectedWord = selectedWord
				return .none
			case .didReceiveNewWords:
				return .none
			case .confirmSelection:
				return .run { send in
					await send(.didClosePossibleWordsSheet)
					await send(.selectWord(nil))
				}
			}
		}
	}
}
