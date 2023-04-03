import ComposableArchitecture
import CoreData
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
        reducer: WordReducer.shared._printChanges()
      )
    )
  }

  public var body: some View {
    NavigationView {
      VStack {
        List {
          ForEach(items.sorted(by: { $0.timestamp! > $1.timestamp! })) { item in
            NavigationLink {
              WordView(item: item, viewStore: viewStore)
            } label: {
              Text(item.word ?? "")
            }
          }
          .onDelete(perform: deleteItems)
        }
        .transition(AnyTransition.asymmetric(insertion: .opacity, removal: .slide))
        .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            EditButton()
          }
          ToolbarItem {
            Button(action: {
              viewStore.send(.addNewItem)
            }) {
              Label("Add Item", systemImage: "plus")
            }
            .alert("Enter your word", isPresented: viewStore.binding(get: \.showingAlert, send: WordReducer.Action.isAlertPresented)) {
              TextField("Enter your word", text: viewStore.binding(get: \.newWord, send: WordReducer.Action.setWord))
              Button("OK", action: {
                addNewWord(newWord: viewStore.newWord)
              })
            } message: {
              Text("This word will be store in the app.")
            }
          }
        }
        .navigationTitle(Text("My words"))

        Button(action: {
          haptic(type: .success)
        }, label: {
          Image(systemName: "mic.circle")
            .resizable()
            .frame(width: 100, height: 100)
            .accessibilityLabel(viewStore.state.speechState.isRecording ? "with transcription" : "without transcription")
        })

        .background(.clear)
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
        .onChange(of: viewStore.state.newWord) { newValue in
          addNewWord(newWord: newValue)
        }
      }
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

struct ContentView_Previews: PreviewProvider {
  //	static let store: StoreOf<WordReducer> = .init(initialState: WordReducer.State(word: .init(word: "Word", phonetic: "phonetic", phonetics: [], origin: nil, meanings: [.init(partOfSpeech: "Part of speech", definitions: [])]), showingAlert: false, newWord: "", isRecording: false, isPressing: false), reducer: WordReducer())

  static var previews: some View {
    fatalError()
    //		WithViewStore(store) { viewStore in
    //			MainWordView(viewStore: viewStore)
    //				.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
  }
}
