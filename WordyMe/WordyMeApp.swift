import SwiftUI
import WordyMePackage
import AppFeature
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
	@UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
	let persistenceController = PersistenceController.shared
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.environment(\.managedObjectContext, persistenceController.container.viewContext)
		}
	}
}

