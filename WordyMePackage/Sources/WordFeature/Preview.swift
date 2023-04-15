import ComposableArchitecture
import SwiftUI

#if DEBUG
  struct WordView_Previews: PreviewProvider {
    static let context = PersistenceController.preview.container.viewContext

    static let store: Store<WordReducer.State, WordReducer.Action> = .init(
      initialState: .init(),
      reducer: WordReducer()
    )
    static let viewStore: ViewStore<WordReducer.State, WordReducer.Action> = .init(store)

    static var previews: some View {
      let item = Item(context: context)
      item.word = "Word"

      return NavigationStack {
        WordDetailView(item: item,
                       viewStore: viewStore)
      }
    }
  }
#endif
