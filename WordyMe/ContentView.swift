import SwiftUI
import CoreData
import Speech

struct ContentView: View {
	@Environment(\.managedObjectContext) private var viewContext
	@StateObject var speechRecognizer = SpeechRecognizer()

	@State private var showingAlert = false
	@State private var newWord = ""
	@State private var isRecording = false
	@State private var isPressing = false

	@FetchRequest(
		sortDescriptors: [NSSortDescriptor(keyPath: \Item.word, ascending: true)],
		animation: .default)
	private var items: FetchedResults<Item>
	
	var body: some View {
		NavigationView {
			VStack {
				List {
					ForEach(items.sorted(by: { $0.timestamp! > $1.timestamp! })) { item in
						NavigationLink {
							WordView(item: item)
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
							showingAlert.toggle()
						}) {
							Label("Add Item", systemImage: "plus")
						}
						.alert("Enter your word", isPresented: $showingAlert) {
							TextField("Enter your word", text: $newWord)
							Button("OK", action: {
								addNewWord(newWord: newWord)
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
						.accessibilityLabel(isRecording ? "with transcription" : "without transcription")
				})
				
				.background(.clear)
				.onLongPressGesture(minimumDuration: 0.2, perform: {}, onPressingChanged: { isPressing in
					self.isPressing = isPressing
					
					if !isPressing {
						speechRecognizer.stopTranscribing()
						isRecording = false
						
						self.addNewWord(newWord: speechRecognizer.transcript)
					}
					
					if self.isPressing {
						isRecording = true
						
						speechRecognizer.reset()
						speechRecognizer.transcribe()
					}
				})
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
			self.newWord = ""

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
	static var previews: some View {
		ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
	}
}
