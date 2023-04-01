import ComposableArchitecture
import SpeechFeature
import Foundation

public struct WordReducer: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable {
		public var word: Definition
		public var showingAlert: Bool = false
		@BindingState public var newWord: String = ""
		public var speechState: SpeechFeature.State
		
		public init(
			word: Definition = .init(
			word: nil,
			phonetic: nil,
			phonetics: [],
			origin: nil,
			meanings: []
		),
			showingAlert: Bool = false,
			newWord: String = "",
			speechState: SpeechFeature.State = .init()
		) {
			self.word = word
			self.showingAlert = showingAlert
			self.newWord = newWord
			self.speechState = speechState
		}
	}
	
	public enum Action: Hashable {
		case wordResponse(TaskResult<Definition>)
		case fetchWord(String)
		case addNewItem
		case isAlertPresented(Bool)
		case setWord(String)
		case speechFeature(SpeechFeature.Action)
		case updateNewWord(String)
	}
	
	@Dependency(\.speechClient) var speechClient
	@Dependency(\.managedContext) var managedContext
	@Dependency(\.date) var date
	@Dependency(\.wordClient) var wordClient

	public var body: some ReducerProtocol<State, Action> {
		Reduce { state, action in
			switch action {
			case let .fetchWord(word):
					.run {
						await wordClient.fetchWord(word)
					}
				
				return .none
				case let .wordResponse(.success(word)):
					state.word = word
					return .none
				case .wordResponse(.failure(_)):
					return .none
				case .addNewItem:
					state.showingAlert = true
					return .none
				case let .isAlertPresented(isShowingAlert):
					state.showingAlert = isShowingAlert
					return .none
				case let .setWord(newWord):
					state.newWord = newWord
					return .none
				case let .updateNewWord(newWord):
					state.newWord = newWord
					return .none
			case let .speechFeature(speechAction):
				switch speechAction {
				case let .speech(.success(transcribedText)):
					state.newWord = transcribedText
					
					return .none
					
				default: return .none
				}
			}
		}
		Scope(state: \.speechState, action: /Action.speechFeature) {
			SpeechFeature()
		}
	}
}
