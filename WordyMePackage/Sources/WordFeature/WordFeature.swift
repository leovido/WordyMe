import ComposableArchitecture
import Foundation
import SpeechFeature
import PossibleWordsFeature

public struct WordReducer: ReducerProtocol {
	
  public init() {}

  public struct State: Equatable {
    public var wordDefinitions: [Definition]
    public var words: [String]
    public var showingAlert: Bool = false
    @BindingState public var isLoading: Bool = false
    @BindingState public var newWord: String = ""
    @BindingState public var hasPossibleWords: Bool = false
		public var possibleWordsFeature: PossibleWordsReducer.State
    public var speechState: SpeechFeature.State

    var phonetic: String {
      wordDefinitions.compactMap { $0.phonetic }
        .description
    }

    var definitionElements: [DefinitionElement] {
      wordDefinitions
        .flatMap { $0.meanings }
        .flatMap { $0.definitions }
    }

    public init(
      wordDefinitions: [Definition] = [
        .init(
          word: nil,
          phonetic: nil,
          phonetics: [],
          origin: nil,
          meanings: []
        ),
      ],
			words: [String] = [],
      showingAlert: Bool = false,
      newWord: String = "",
			hasPossibleWords: Bool = false,
      speechState: SpeechFeature.State = .init(),
			possibleWordsFeature: PossibleWordsReducer.State = .init()
    ) {
      self.wordDefinitions = wordDefinitions
      self.showingAlert = showingAlert
      self.newWord = newWord
			self.hasPossibleWords = hasPossibleWords
      self.speechState = speechState
			self.words = words
			self.possibleWordsFeature = possibleWordsFeature
    }
  }

  public enum Action: Equatable, BindableAction {
    case wordResponse(Definition)
    case fetchWord(String)
    case addNewItem
    case isAlertPresented(Bool)
    case setWord(String)
		case speechFeature(SpeechFeature.Action)
		case possibleWordsFeature(PossibleWordsReducer.Action)
    case updateNewWord(String)
    case onAppear
    case binding(BindingAction<State>)
		case updateCurrentWords([String])
  }

  @Dependency(\.speechClient) var speechClient
  @Dependency(\.managedContext) var managedContext
  @Dependency(\.date) var date
	@Dependency(\.wordClient) var wordClient
	@Dependency(\.wordNotification) var wordNotification

  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      struct WordId: Hashable {}
      switch action {
			case let .possibleWordsFeature(possibleAction):
				switch possibleAction {
				case .didClosePossibleWordsSheet:
					state.hasPossibleWords = false
					return .none
				case .didReceiveNewWords:
					state.hasPossibleWords = true
					return .none
				case let .receivePossibleWords(newWords):
					state.possibleWordsFeature.possibleWords = newWords
					
					return .run { send in
						await send(.possibleWordsFeature(.didReceiveNewWords))
					}
				default:
					return .none
				}
			case let .updateCurrentWords(newWords):
				state.words = newWords
				
				return .none
      case .binding:
        return .none
      case .onAppear:
        return .run { send in
					for await word in await self.wordNotification() {
						await send(.setWord(word))
					}
        }
      case let .fetchWord(word):
        state.isLoading = true
        return .run { send in
          guard let response = await wordClient.fetchWord(word).first else {
            return
          }
          await send(.wordResponse(response))
        }

      case let .wordResponse(word):
        state.isLoading = false

        state.wordDefinitions = [word]
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

        case let .possibleWords(transcriptions):
					return .run { send in
						await send(.possibleWordsFeature(.receivePossibleWords(transcriptions)))
					}
        default: return .none
        }
      }
    }
    BindingReducer()
    Scope(state: \.speechState, action: /Action.speechFeature) {
      SpeechFeature()
    }
		Scope(state: \.possibleWordsFeature, action: /Action.possibleWordsFeature) {
			PossibleWordsReducer()
		}
  }
}

extension DependencyValues {
	var wordNotification: @Sendable () async -> AsyncStream<String> {
		get { self[WordNotification.self] }
		set { self[WordNotification.self] = newValue }
	}
}

private enum WordNotification: DependencyKey {
	static let liveValue: @Sendable () async -> AsyncStream<String> = {
		await AsyncStream(
			NotificationCenter.default
				.notifications(named: Notification.Name("AddNewWord"))
				.compactMap { notification in
					notification.object as? String
				}
		)
	}
	static let testValue: @Sendable () async -> AsyncStream<String> = unimplemented(
		#"@Dependency(\.screenshots)"#, placeholder: .finished
	)
}
