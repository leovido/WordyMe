import ComposableArchitecture
import CoreData
import StyleGuide
import SwiftUI
import PossibleWordsFeature

public struct MainWordView: View {
  @Environment(\.managedObjectContext) private var viewContext

  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Item.word, ascending: true)],
    animation: .default
  )
  private var items: FetchedResults<Item>

  public let store: StoreOf<WordReducer>

  public init(store: StoreOf<WordReducer>) {
    self.store = store
  }
	
	private func WordSectionsView(viewStore: ViewStore<WordReducer.State, WordReducer.Action>) -> some View {
		Group {
			if items.isEmpty {
				Spacer()
				VStack {
					Image(systemName: "text.bubble")
						.resizable()
						.aspectRatio(contentMode: .fit)
						.foregroundColor(ColorGuide.secondary)
						.frame(width: 70, height: 70)

					Text("New words")
						.font(.title)
						.foregroundColor(ColorGuide.secondary)
						.bold()
						.multilineTextAlignment(.center)
						.padding(.top)

					Text("Start adding new words to improve your vocabulary")
						.font(.body)
						.foregroundColor(ColorGuide.secondary)
						.multilineTextAlignment(.center)
						.padding(.top, 2)
				}
				Spacer()

			} else {
				List {
					ForEach(items.sorted(by: { $0.timestamp! > $1.timestamp! })) { item in
						NavigationLink {
							WordDetailView(item: item, viewStore: viewStore)
						} label: {
							Text(item.word ?? "")
								.fontDesign(.rounded)
								.foregroundColor(ColorGuide.primaryAlt)
						}
					}
					.onDelete(perform: deleteItems)
					.transition(AnyTransition.asymmetric(insertion: .opacity, removal: .slide))
				}
				.scrollContentBackground(.hidden)
				.listStyle(InsetGroupedListStyle())
			}
		}
	}

	public var body: some View {
		WithViewStore(store) { viewStore in
			NavigationView {
				ZStack {
					ColorGuide.primaryAlt
						.edgesIgnoringSafeArea(.all)
					VStack {
						WordSectionsView(viewStore: viewStore)
						Spacer()
						
						Button(action: {
							haptic(type: .success)
						}, label: {
							Image(systemName: "mic.circle")
								.resizable()
								.frame(width: 100, height: 100)
								.accessibilityLabel(viewStore.state.speechState.isRecording ? "with transcription" : "without transcription")
						})
						.background(.clear)
						.tint(ColorGuide.secondary)
						.onLongPressGesture(minimumDuration: 0.2, perform: {}, onPressingChanged: { isPressing in
							if isPressing {
								viewStore.send(.speechFeature(.recordButtonTapped))
							} else {
								viewStore.send(.speechFeature(.stopTranscribing))
							}
							
							if viewStore.state.speechState.isRecording {
								viewStore.send(.speechFeature(.recordButtonTapped))
							}
						})
					}
					.transition(AnyTransition.asymmetric(insertion: .opacity, removal: .slide))
				}
				.toolbar {
					ToolbarItem(placement: .primaryAction) {
						Menu {
							Button(action: {
								viewStore.send(.addNewItem)
							}) {
								Label("Add Item", systemImage: "plus")
							}
							viewStore.state.words.isEmpty ? EmptyView().asAnyView() : EditButton().asAnyView()
						} label: {
							Label("Menu", systemImage: "ellipsis")
						}
					}
				}
				.alert(
					"Enter your word",
					isPresented: viewStore.binding(get: \.showingAlert, send: WordReducer.Action.isAlertPresented)
				) {
					TextField(
						"Enter your word",
						text: viewStore.binding(\.$newWord)
					)
					Button("Ok", action: {
						addNewWord(viewStore: viewStore)
					})
				} message: {
					Text("This word will be stored in the app.")
				}
				.onAppear {
					viewStore.send(.onAppear)
					viewStore.send(.updateCurrentWords(items.compactMap(\.word)))
				}
				.onChange(of: viewStore.state.newWord) { newValue in
					addNewWord(viewStore: viewStore)
				}
				.onChange(of: items.compactMap(\.word)) { newItems in
					viewStore.send(.updateCurrentWords(newItems))
				}
				.sheet(isPresented: viewStore.binding(\.$hasPossibleWords)) {
					PossibilityView(
						store: store.scope(
							state: \.possibleWordsFeature,
							action: WordReducer.Action.possibleWordsFeature
						)
					)
				}
				.navigationTitle(Text("My words"))
				.tint(ColorGuide.secondary)
			}
			.navigationTitle(Text("My words"))
			.tint(ColorGuide.secondary)
		}
	}

  func haptic(type: UINotificationFeedbackGenerator.FeedbackType) {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(type)
  }

	private func addNewWord(viewStore: ViewStore<WordReducer.State, WordReducer.Action>) {
		guard !viewStore.newWord.isEmpty else {
      haptic(type: .error)

      return
    }
    withAnimation {
      let newItem = Item(context: viewContext)
      newItem.timestamp = Date()
      newItem.word = viewStore.newWord
      viewStore.send(.updateNewWord(viewStore.newWord))

      do {
        try viewContext.save()
      } catch {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nsError = error as NSError
        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
      }
    }
  }

  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      offsets.map { items.sorted(by: { $0.timestamp! > $1.timestamp! })[$0] }.forEach(viewContext.delete)

      do {
        try viewContext.save()
      } catch {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nsError = error as NSError
        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
      }
    }
  }
}

private let itemFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateStyle = .short
  formatter.timeStyle = .medium
  return formatter
}()

#if DEBUG
struct MainWordView_Previews: PreviewProvider {
	static let store: StoreOf<WordReducer> = .init(
		initialState: WordReducer.State(words: ["Sample"], hasPossibleWords: true, possibleWordsFeature: .init(possibleWords: [.init(formattedString: "Demo", segments: [
			.init(alternativeSubstrings: ["Alternative"], confidence: 0.78, duration: 1, substring: "", timestamp: 1)
		])])),
		reducer: WordReducer()
	)
	
	static var previews: some View {
		Group {
			MainWordView(store: store)
				.previewDevice(PreviewDevice(rawValue: "iPhone 14"))

			MainWordView(store: store)
				.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
				.previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro Max"))
		}
		.previewLayout(.sizeThatFits)
	}
}
#endif

extension View {
	func asAnyView() -> AnyView {
		AnyView(self)
	}
}
