import ComposableArchitecture
import StyleGuide
import SwiftUI

public struct WordDetailView: View {
  public let item: Item

  @ObservedObject var viewStore: ViewStore<WordReducer.State, WordReducer.Action>

  public init(item: Item, viewStore: ViewStore<WordReducer.State, WordReducer.Action>) {
    self.item = item
    self.viewStore = viewStore
  }

  public var body: some View {
    ScrollView {
      LazyVStack(alignment: .leading) {
        HStack {
          Text(item.word ?? "")
            .font(.largeTitle)
            .fontDesign(.serif)
            .bold()
            .foregroundColor(ColorGuide.secondary)

          Text(viewStore.state.phonetic)
            .foregroundColor(.gray)
        }
        .padding(.bottom)

        if viewStore.state.isLoading {
          ProgressView()
        } else {
          ForEach(Array(viewStore.state.definitionElements.enumerated()), id: \.offset) { index, element in

            HStack(alignment: .top) {
              Text(index.description)
                .bold()
                .foregroundColor(ColorGuide.secondary)
                .padding(.trailing)
                .fontDesign(.rounded)
                .accessibilityLabel(Text(index.description))
              Text(element.definition ?? "")
                .foregroundColor(ColorGuide.secondary)
                .font(.body)
                .fontDesign(.serif)
                .padding(.bottom)
            }
            .frame(alignment: .topLeading)

            ExampleView(example: element.example)
          }
          .transition(AnyTransition.opacity.animation(.default))
        }

        Spacer()
      }
      .padding(.horizontal)
    }
    .navigationTitle(Text(item.word!))
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      viewStore.send(.fetchWord(item.word!))
    }
    .background(ColorGuide.primaryAlt)
  }
}
