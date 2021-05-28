//
//  ProfileView.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-05-15.
//

import SwiftUI
import HealthKit

struct ProfileView: View {
	@EnvironmentObject private var userData: UserData
	@EnvironmentObject private var healthKitManager: HealthKitManager
	
	@Binding var isPresented: Bool
	
	@State private var customMaxHR = false
	@State private var maxHR = 200
	@State private var isAgeSupportPresented = false
	
	let hrStep = 1
	let hrRange = 150...210
	
	var body: some View {
		NavigationView {
			Form {
				Section {
					HStack {
						Image(systemName: "person.crop.circle")
							.font(.largeTitle)
							.foregroundColor(.gray)
						
						VStack(alignment: .leading) {
							if let firstName = userData.firstName {
								Text(firstName)
							} else {
								Button(action: {
									// Open sheet with information why all permissions are required.
								}) {
									HStack(spacing: Constants.spacing) {
										Text("No name set")
										Image(systemName: "questionmark.circle")
									}
								}
							}
							
							if let age = healthKitManager.dateOfBirth?.age {
								Text("\(age) years old")
									.font(.footnote)
							} else {
								Button {
									isAgeSupportPresented = true
								} label: {
									HStack(spacing: Constants.spacing) {
										Text("No age available")
										Image(systemName: "questionmark.circle")
									}
									.font(.footnote)
								}
								.sheet(isPresented: $isAgeSupportPresented) {
									SafariView(url: URL(string: "https://support.apple.com/guide/iphone/iph07ebe0df5/14.0/ios/14.0")!)
										.edgesIgnoringSafeArea(.bottom)
								}
							}
						}
					}
				}.padding(.vertical, Constants.padding)
				
				Section {
					Toggle(isOn: $userData.includeWalks, label: {
						Text("Include walks")
					})
				}
				
				Section(header: Text("Heart Rate Zones")) {
					HStack {
						Text("Max HR")
						Spacer()
						HStack(alignment: .lastTextBaseline, spacing: Constants.spacing) {
							Text("196")
								.bold()
							Text("bpm")
								.font(.caption)
						}
					}
					Toggle(isOn: $userData.showHRZoneDetails, label: {
						Text("Show expanded workout data")
					})
				}
				
				Section(header: Text("Units"), footer: Text("These settings won't impact your data in the Health app.")) {
					Picker(selection: $userData.unitDistance, label: Text("Distance"), content: {
						Text(HKUnit.mile().unitString).tag(HKUnit.mile())
						Text(HKUnit.meterUnit(with: .kilo).unitString).tag(HKUnit.meterUnit(with: .kilo))
					})
					Picker(selection: $userData.unitWeight, label: Text("Weight"), content: {
						Text(HKUnit.pound().unitString).tag(HKUnit.pound())
						Text(HKUnit.gramUnit(with: .kilo).unitString).tag(HKUnit.gramUnit(with: .kilo))
					})
					Picker(selection: $userData.unitEnergy, label: Text("Energy"), content: {
						Text(HKUnit.kilocalorie().unitString).tag(HKUnit.kilocalorie())
						Text(HKUnit.jouleUnit(with: .kilo).unitString).tag(HKUnit.jouleUnit(with: .kilo))
						Text(HKUnit.largeCalorie().unitString).tag(HKUnit.largeCalorie())
					})
				}
				
				Section(header: Text("Developer tools")) {
					Button(action: {
						/// Something
					}) {
						Text("Clear analyzed workouts")
					}
					Button(action: {
						UserDefaults.standard.removeObject(forKey: "firstLaunch")
						UserDefaults.standard.removeObject(forKey: "showFirstNameCard")
					}) {
						Text("Reset onboarding data")
					}
				}
			}
			.navigationBarTitle(Text("Profile"), displayMode: .inline)
			.navigationBarItems(trailing: Button(action: {
				self.isPresented = false
			}) {
				Text("Done")
					.bold()
			})
		}
	}
}

struct ProfileView_Previews: PreviewProvider {
	static var previews: some View {
		ViewPreview(ProfileView(isPresented: .constant(true)))
			.environmentObject(UserData())
			.environmentObject(HealthKitManager())
	}
}
