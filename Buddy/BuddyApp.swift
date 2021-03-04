//
//  BuddyApp.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-03-04.
//

import SwiftUI

@main
struct BuddyApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
