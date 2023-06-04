import AppFeature
import BrainLibraryFeature
import ComposableArchitecture
import Counter
import Sentry
import StyleGuide
import SwiftUI
import WordFeature

final class AppDelegate: NSObject, UIApplicationDelegate {
  let store = Store(
    initialState: AppReducer.State(),
    reducer: AppReducer()
  )

  var viewStore: ViewStore<Void, AppReducer.Action> {
    ViewStore(store.stateless)
  }

  func application(
    _: UIApplication,
    didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    viewStore.send(.appDelegate(.didFinishLaunching))
    return true
  }

  func application(
    _: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    viewStore.send(.appDelegate(.didRegisterForRemoteNotifications(.success(deviceToken))))
  }

  func application(
    _: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    viewStore.send(.appDelegate(.didRegisterForRemoteNotifications(.failure(error))))
  }
}

@main
struct WordyMeApp: App {
  let store: Store<AppReducer.State, AppReducer.Action>

  init() {
    store = Store(
      initialState: AppReducer.State(),
      reducer: AppReducer()._printChanges()
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
          .onAppear {
            viewStore.send(.onAppear)
          }

          CountView(
            store: store.scope(
              state: \.counterState,
              action: AppReducer.Action.counterFeature
            )
          )
          .tabItem {
            Label("Brain", systemImage: "books.vertical")
          }
        }
      }
      .tint(ColorGuide.secondary)
      .colorInvert()
    }
  }
}
