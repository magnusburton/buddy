//
//  WorkoutMapView.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-03-16.
//

import SwiftUI
import HealthKit

struct WorkoutMapView: View {
	let workout: WorkoutManager.Workout
	@Binding var isPresented: Bool
	
    var body: some View {
		NavigationView {
			MapView(interactionModes: .all)
				.navigationBarTitle(Text("Workout Route"), displayMode: .inline)
				.navigationBarItems(leading: Button(action: {
					self.isPresented = false
				}) {
					Text("Done").bold()
				})
		}
    }
}

struct WorkoutMapView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
			ViewPreview(WorkoutMapView(workout: WorkoutManager.testWorkouts[0], isPresented: .constant(true)))
			ViewPreview(WorkoutMapView(workout: WorkoutManager.testWorkouts[1], isPresented: .constant(true)))
		}
//		.environmentObject(UserData())
    }
}
