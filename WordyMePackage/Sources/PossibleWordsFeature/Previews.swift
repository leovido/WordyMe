import ComposableArchitecture
import SwiftUI

#if DEBUG
  struct PossibilityView_Previews: PreviewProvider {
    static let store: StoreOf<PossibleWordsReducer> = .init(
      initialState: PossibleWordsReducer.State(possibleWords: [
        .init(formattedString: "Demo", segments: [
          .init(alternativeSubstrings: ["Alternative"], confidence: 0.89, duration: 1, substring: "", timestamp: 1),
        ]),
        .init(formattedString: "Word", segments: [
          .init(alternativeSubstrings: ["Alternative"], confidence: 3, duration: 1, substring: "", timestamp: 1),
        ]),
      ], selectedWord: nil),
      reducer: PossibleWordsReducer()
    )

    static let store2: StoreOf<PossibleWordsReducer> = .init(
      initialState: PossibleWordsReducer.State(possibleWords: [
        .init(formattedString: "Demo", segments: [
          .init(alternativeSubstrings: ["Alternative"], confidence: 0.89, duration: 1, substring: "", timestamp: 1),
        ]),
        .init(formattedString: "Word", segments: [
          .init(alternativeSubstrings: ["Alternative"], confidence: 3, duration: 1, substring: "", timestamp: 1),
        ]),
      ], selectedWord: .init(formattedString: "Word", segments: [
        .init(alternativeSubstrings: ["Alternative"], confidence: 3, duration: 1, substring: "", timestamp: 1),
      ])),
      reducer: PossibleWordsReducer()
    )
    static var previews: some View {
      Group {
        PossibilityView(store: store)
        PossibilityView(store: store2)
      }
    }
  }
#endif
