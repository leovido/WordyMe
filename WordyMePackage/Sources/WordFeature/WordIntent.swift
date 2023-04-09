import AppIntents
import Dependencies

public struct WordIntent: AppIntent {
  public init() {}

  public static let title: LocalizedStringResource = "Add a new word"

  // Description of the action in Shortcuts
  // Category name allows you to group actions - shown when tapping on an app in the Shortcuts library
  static var description: IntentDescription = .init(
    """
    Add a new word to your collection.
    """,
    categoryName: "Words"
  )

  @Parameter(title: "Word",
             description: "The new word to be added",
             inputOptions: String.IntentInputOptions(capitalizationType: .words),
             requestValueDialog: IntentDialog("What is the new word?"))
  var word: String

  public func perform() async throws -> some ReturnsValue & ProvidesDialog {
    NotificationCenter.default.post(name: NSNotification.Name("AddNewWord"), object: word)
    return .result(dialog: "Okay, adding \(word)")
  }
}

struct AppShortcuts: AppShortcutsProvider {
  @AppShortcutsBuilder
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: WordIntent(),
      phrases: ["Append \(\.$word) to \(.applicationName) "]
    )
  }
}

extension WordIntent: DependencyKey {
  public static var liveValue: WordIntent {
    WordIntent()
  }
}

extension WordIntent: TestDependencyKey {
  public static var testValue: WordIntent {
    WordIntent()
  }
}

public extension DependencyValues {
  var wordIntent: WordIntent {
    get { self[WordIntent.self] }
    set { self[WordIntent.self] = newValue }
  }
}

public struct WordIntentClient {
  public static let shared: WordIntentClient = .init(words: [])

  var words: [Definition]
}

extension WordIntentClient: DependencyKey {
  public static var liveValue: WordIntentClient {
    WordIntentClient.shared
  }
}

extension WordIntentClient: TestDependencyKey {
  public static var testValue: WordIntentClient {
    WordIntentClient.shared
  }
}

public extension DependencyValues {
  var wordIntentClient: WordIntentClient {
    get { self[WordIntentClient.self] }
    set { self[WordIntentClient.self] = newValue }
  }
}
