//
//  BuddyApp.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-03-04.
//

import SwiftUI

@main
struct BuddyApp: App {
	@Environment(\.scenePhase) private var scenePhase
	
    let persistenceController = PersistenceController.shared
	let userData = UserData()
	let HKManager = HealthKitManager()
	let workoutManager = WorkoutManager()
	let healthManager = HealthManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
				.environmentObject(userData)
				.environmentObject(HKManager)
				.environmentObject(workoutManager)
				.environmentObject(healthManager)
		}.onChange(of: scenePhase) { phase in
			if phase == .active {
				// start timers, observing queries, etc.
				if userData.firstLaunch == false {
					HKManager.authorizeHealthKit() { result, error in
						healthManager.initStore()
						workoutManager.initStore()
					}
				}
			} else if phase == .background {
				// clean up resources, stop timers, etc.
			} else if phase == .inactive {
				// stop intensive computation
			}
		}
    }
}
