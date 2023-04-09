import ComposableArchitecture
import CoreData
import StyleGuide
import SwiftUI

public struct MainWordView: View {
  @Environment(\.managedObjectContext) private var viewContext

  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Item.word, ascending: true)],
    animation: .default
  )
  private var items: FetchedResults<Item>

  public let store: StoreOf<WordReducer>
  @ObservedObject var viewStore: ViewStore<WordReducer.State, WordReducer.Action>

  public init(store: StoreOf<WordReducer>) {
    self.store = store
    viewStore = ViewStore(
      .init(
        initialState: WordReducer.State(),
        reducer: WordReducer()._printChanges()
      )
    )
  }
	
	private func WordSectionsView() -> some View {
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
						.padding(.top, 4)
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
		NavigationView {
			ZStack {
				ColorGuide.primaryAlt
					.edgesIgnoringSafeArea(.all)
				VStack {
					WordSectionsView()
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
						
						if self.viewStore.state.speechState.isRecording {
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
					addNewWord(newWord: viewStore.newWord)
				})
			} message: {
				Text("This word will be stored in the app.")
			}
			.onAppear {
				viewStore.send(.onAppear)
				viewStore.send(.updateCurrentWords(items.compactMap(\.word)))
			}
			.onChange(of: viewStore.state.newWord) { newValue in
				addNewWord(newWord: newValue)
			}
			.onChange(of: items.compactMap(\.word)) { newItems in
				viewStore.send(.updateCurrentWords(newItems))
			}
			.sheet(isPresented: viewStore.binding(\.$hasPossibleWords)) {
				VStack(alignment: .leading) {
					ScrollView {
						Text("Possibilities")
							.font(.largeTitle)
						ForEach(viewStore.state.possibleWords) { possibility in
							HStack {
								Text(possibility.formattedString)
									.font(.title)
								
								let confidence = possibility.segments.filter {
									$0.substring == possibility.formattedString
								}
									.map(\.confidence)
									.first ?? 0
								
								let formattedConfidence = String(format: "%0.2f%%", confidence * 100)
								Text(formattedConfidence)
							}
							.padding()
						}
					}
				}
			}
			.navigationTitle(Text("My words"))
			.tint(ColorGuide.secondary)
		}
	}

  func haptic(type: UINotificationFeedbackGenerator.FeedbackType) {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(type)
  }

  private func addNewWord(newWord: String) {
    guard !newWord.isEmpty else {
      haptic(type: .error)

      return
    }
    withAnimation {
      let newItem = Item(context: viewContext)
      newItem.timestamp = Date()
      newItem.word = newWord
      self.viewStore.send(.updateNewWord(newWord))

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
		initialState: WordReducer.State(),
		reducer: WordReducer()
	)
	
	static var previews: some View {
		Group {
			MainWordView(store: store)
				.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
				.previewDevice(PreviewDevice(rawValue: "iPhone 14"))

			MainWordView(store: store)
				.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
				.previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro Max"))
		}
	}
}
#endif

extension View {
	func asAnyView() -> AnyView {
		AnyView(self)
	}
}
