import ComposableArchitecture
import CoreData
import Dependencies

extension NSManagedObjectContext: DependencyKey {
  public static var liveValue: NSManagedObjectContext {
    .init(concurrencyType: .mainQueueConcurrencyType)
  }
}

extension NSManagedObjectContext: TestDependencyKey {
  public static var testValue: NSManagedObjectContext {
    .init(concurrencyType: .mainQueueConcurrencyType)
  }
}

public extension DependencyValues {
  var managedContext: NSManagedObjectContext {
    get { self[NSManagedObjectContext.self] }
    set { self[NSManagedObjectContext.self] = newValue }
  }
}
