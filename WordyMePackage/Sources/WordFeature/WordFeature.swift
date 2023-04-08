import ComposableArchitecture
import Foundation
import SpeechFeature

public struct WordReducer: ReducerProtocol {
  public init() {}

  public struct State: Equatable {
    public var word: [Definition]
    public var showingAlert: Bool = false
    @BindingState public var isLoading: Bool = false
    @BindingState public var newWord: String = ""
    @BindingState public var hasPossibleWords: Bool = false
    public var possibleWords: [Transcription] = []
    public var speechState: SpeechFeature.State

    var phonetic: String {
      word.compactMap { $0.phonetic }
        .description
    }

    var definitionElements: [DefinitionElement] {
      word
        .flatMap { $0.meanings }
        .flatMap { $0.definitions }
    }

    public init(
      word: [Definition] = [
        .init(
          word: nil,
          phonetic: nil,
          phonetics: [],
          origin: nil,
          meanings: []
        ),
      ],
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

  public enum Action: Equatable, BindableAction {
    case wordResponse(Definition)
    case fetchWord(String)
    case addNewItem
    case isAlertPresented(Bool)
    case setWord(String)
    case speechFeature(SpeechFeature.Action)
    case updateNewWord(String)
    case onAppear
    case binding(BindingAction<State>)
  }

  @Dependency(\.speechClient) var speechClient
  @Dependency(\.managedContext) var managedContext
  @Dependency(\.date) var date
  @Dependency(\.wordClient) var wordClient

  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .binding:
        if !state.hasPossibleWords {
          state.possibleWords.removeAll()
        }
        return .none
      case .onAppear:
        return .run { send in
          let values = NotificationCenter.default.publisher(for: Notification.Name("AddNewWord"))
            .compactMap { notification in
              notification.object as? String
            }
            .values

          for await word in values {
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

        state.word = [word]
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
          state.possibleWords = transcriptions
          state.hasPossibleWords = !state.possibleWords.isEmpty

          return .none
        default: return .none
        }
      }
    }
    BindingReducer()
    Scope(state: \.speechState, action: /Action.speechFeature) {
      SpeechFeature()
    }
  }
}
