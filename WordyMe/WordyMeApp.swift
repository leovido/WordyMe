import SwiftUI
import AppFeature
import WordyMePackage
import BrainLibraryFeature
import ComposableArchitecture

final class AppDelegate: NSObject, UIApplicationDelegate {
	let store = Store(
		initialState: AppReducer.State(),
		reducer: AppReducer()
	)

	var viewStore: ViewStore<Void, AppReducer.Action> {
		ViewStore(self.store.stateless)
	}

	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
	) -> Bool {
		self.viewStore.send(.appDelegate(.didFinishLaunching))
		return true
	}

	func application(
		_ application: UIApplication,
		didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
	) {
		self.viewStore.send(.appDelegate(.didRegisterForRemoteNotifications(.success(deviceToken))))
	}

	func application(
		_ application: UIApplication,
		didFailToRegisterForRemoteNotificationsWithError error: Error
	) {
		self.viewStore.send(.appDelegate(.didRegisterForRemoteNotifications(.failure(error))))
	}
}

@main
struct WordyMeApp: App {
	let store: Store<AppReducer.State, AppReducer.Action>
	
	init() {
		self.store = Store(
			initialState: AppReducer.State(),
			reducer: AppReducer()
		)
	}
	
	@UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
	let persistenceController = PersistenceController.shared
	
	var body: some Scene {
		WindowGroup {
			TabView {
				WithViewStore(store) { viewStore in
					MainWordView(
						store: store.scope(
							state: \.wordState,
							action: AppReducer.Action.wordFeature
						)
					)
						.environment(\.managedObjectContext, persistenceController.container.viewContext)
						.tabItem {
							Label("Words", systemImage: "text.bubble")
						}
						.tabItem {
							Label("Stats", systemImage: "chart.bar")
						}
					
					BrainView()
						.tabItem {
							Label("Brain", systemImage: "books.vertical")
						}
				}
			}
		}
	}
}
