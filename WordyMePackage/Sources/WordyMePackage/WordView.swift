import SwiftUI

public struct WordView: View {
	public let item: Item
	
	@State private var definition: [Definition] = []
	@State private var isLoading: Bool = false
	
	public init(item: Item, definition: [Definition] = []) {
		self.item = item
		self.definition = definition
	}
	
	var phonetic: String {
		definition.compactMap({ $0.phonetic })
		.description
	}
	
	var definitionElements: [DefinitionElement] {
		definition
			.flatMap({ $0.meanings })
			.flatMap({ $0.definitions })
	}
	
	public var body: some View {
		ScrollView {
			LazyVStack(alignment: .leading) {
				HStack {
					Text(item.word ?? "")
						.font(.largeTitle)
						.fontDesign(.serif)
						.bold()
					
					Text(phonetic)
						.foregroundColor(.gray)
				}
				.padding(.bottom)
				
				if isLoading {
					ProgressView()
				} else {
						ForEach(Array(definitionElements.enumerated()),  id: \.offset) { index, element in
							
							HStack(alignment: .top) {
								Text(index.description)
									.bold()
									.foregroundColor(.gray)
									.padding(.trailing)
									.fontDesign(.rounded)
									.accessibilityLabel(Text(index.description))
								Text(element.definition ?? "")
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
		}
		.padding()
		.onAppear {
			viewStore.send(.fetchWord)
		}
	}
}

//struct WordView_Previews: PreviewProvider {
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
//}

