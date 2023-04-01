import CoreData

public struct PersistenceController {
  public static let shared = PersistenceController()

  static var preview: PersistenceController = {
    let result = PersistenceController(inMemory: true)
    let viewContext = result.container.viewContext
    for _ in 0 ..< 10 {
      let newItem = Item(context: viewContext)
      newItem.word = "Word"
      newItem.timestamp = Date()
    }
    do {
      try viewContext.save()
    } catch {
      // Replace this implementation with code to handle the error appropriately.
      // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      let nsError = error as NSError
      fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    }
    return result
  }()

  public let container: NSPersistentCloudKitContainer

  init(inMemory: Bool = false) {
    let module = "WordyMePackage"
    let momdName = "Word.momd"

    guard let modelURL = Bundle.module.url(forResource: "Word", withExtension: "momd"),
          let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)
    else {
      fatalError("Failed to load model named \(momdName) in module named \(module)")
    }
    container = NSPersistentCloudKitContainer(name: "Word", managedObjectModel: managedObjectModel)
    if inMemory {
      container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
    }
    container.viewContext.automaticallyMergesChangesFromParent = true
    container.loadPersistentStores(completionHandler: { _, error in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
  }
}
