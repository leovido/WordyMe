import ComposableArchitecture

public struct WordReducer: ReducerProtocol {
	public init() {}
	
	public struct State: Hashable {
		public var word: Definition
		var showingAlert: Bool = false
		var newWord: String = ""
		var isRecording: Bool = false
		var isPressing: Bool = false
		
		public init(word: Definition = .init(word: nil, phonetic: nil, phonetics: [], origin: nil, meanings: []),
								showingAlert: Bool = false,
								newWord: String = "",
								isRecording: Bool = false,
								isPressing: Bool = false) {
			self.word = word
			self.showingAlert = showingAlert
			self.newWord = newWord
			self.isRecording = isRecording
			self.isPressing = isPressing
		}
	}
	
	public enum Action: Equatable {
		case wordResponse(TaskResult<Definition>)
		case addNewItem
		case isAlertPresented(Bool)
		case setWord(String)
		case recordingUpdate(Bool)
		case recordingButtonPressed(Bool)
		case updateNewWord(String)
	}
	
	public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
		switch action {
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
			case let .recordingUpdate(isRecording):
				state.isRecording = isRecording
				return .none
			case let .recordingButtonPressed(isPressing):
				state.isPressing = isPressing
				return .none
			case let .updateNewWord(newWord):
				state.newWord = newWord
				return .none
		}
	}
}
