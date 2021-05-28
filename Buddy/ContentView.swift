//
//  ContentView.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-03-04.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
	@EnvironmentObject private var userData: UserData
	
	@State private var boardingSheet = false
	@State private var tabSelection = 0

    var body: some View {
		TabView(selection: $tabSelection) {
			SummaryView()
				.tabItem {
					Label(Constants.TabBarNames[0], systemImage: Constants.TabBarImages[0])
				}
				.tag(0)
			
			WorkoutView()
				.tabItem {
					Label(Constants.TabBarNames[1], systemImage: Constants.TabBarImages[1])
				}
				.tag(1)
		}
		.onAppear(perform: {
			if !userData.firstLaunch {
				return
			}
			
			boardingSheet = true
		})
		.sheet(isPresented: $boardingSheet) {
			OnboardingView(isPresented: $boardingSheet)
		}
    }
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			ViewPreview(ContentView())
		}
		.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
		.environmentObject(UserData())
		.environmentObject(HealthKitManager())
		.environmentObject(WorkoutManager())
		.environmentObject(HealthManager())
    }
}
