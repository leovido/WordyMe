//
//  WordyMeApp.swift
//  WordyMe
//
//  Created by Christian Leovido on 10/03/2023.
//

import SwiftUI

@main
struct WordyMeApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
