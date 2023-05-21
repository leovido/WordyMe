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

//    SentrySDK.start { options in
//      options.dsn = "https://edaeff785d8d4f4ea20f5246a847471c@o4504940331728896.ingest.sentry.io/4504940332908544"
//      options.debug = true // Enabled debug when first installing is always helpful
//
//      // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
//      // We recommend adjusting this value in production.
//      options.tracesSampleRate = 1.0
//    }
  }

  @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
  let persistenceController = PersistenceController.shared

  var body: some Scene {
    WindowGroup {
      TabView {
        WithViewStore(store) { _ in
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
