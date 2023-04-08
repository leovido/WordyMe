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
            .foregroundColor(Color(uiColor: ColorGuide.secondary))

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
                .foregroundColor(Color(uiColor: ColorGuide.secondary))
                .padding(.trailing)
                .fontDesign(.rounded)
                .accessibilityLabel(Text(index.description))
              Text(element.definition ?? "")
                .foregroundColor(Color(uiColor: ColorGuide.secondary))
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
    .background(Color(uiColor: ColorGuide.primaryAlt))
  }
}

// struct WordView_Previews: PreviewProvider {
//	static let context = PersistenceController.preview.container.viewContext
//
//	static var previews: some View {
//		let item = Item(context: context)
//		item.word = "Word"
//
//		return NavigationStack {
//			WordView(item: item,
//							 definition: [
//								Definition(
//									word: "word",
//									phonetic: "word",
//									phonetics: [.init(text: "word",
//																		audio: nil)],
//									origin: "origin",
//									meanings: [.init(partOfSpeech: "part of speech", definitions: [
//										.init(
//											definition: " a single distinct meaningful element of speech or writing, used with others (or sometimes alone) to form a sentence and typically shown with a space on either side when written or printed",
//											example: "I don't like the word ‘unofficial’ | so many words for so few ideas.",
//											synonyms: ["Synonyms"],
//											antonyms: ["Antonyms"])])])])
//		}
//	}
// }
