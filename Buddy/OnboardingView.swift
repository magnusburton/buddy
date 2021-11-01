//
//  OnboardingView.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-03-04.
//

import SwiftUI
import HealthKit

struct OnboardingView: View {
	@EnvironmentObject private var userData: UserData
	@EnvironmentObject private var HKManager: HealthKitManager
	@EnvironmentObject private var healthManager: HealthManager
	@EnvironmentObject private var workoutManager: WorkoutManager
	
	@Binding var isPresented: Bool
	@State private var selected = 0
	
	var caption: Text? {
		if selected == 3 {
			return Text("Your data never leaves your device and won't be shared with anyone in any way.")
		}
		return nil
	}
	
	var buttonText: String {
		if selected == 3 {
			return "Sync Health Data"
		}
		return "Next"
	}
	
	var body: some View {
		ZStack {
			LinearGradient(gradient: Gradient(colors: [.green, Color(red: 0.0, green: 0.5, blue: 0.4, opacity: 1.0)]), startPoint: .top, endPoint: .bottom)
			
			VStack {
				TabView(selection: $selected) {
					OnboardingPageTextView(
						image: Image(systemName: "face.smiling.fill"),
						title: Text("Hi, I'm Buddy!"),
						description: Text("Get an easy to grasp, simplified overview of your health and lifestyle in order for you to make well educated decisions regarding your health."),
						selected: $selected
					)
					.tag(0)
					
					OnboardingPageTextView(
						image: Image(systemName: "location.fill.viewfinder"),
						title: Text("Let's go to the beach, beach."),
						description: Text("In order for me to recommend workout routes and ways to stay fit I'd like to get access to your location. This data is only used to recommend nearby places to you and is not shared with anyone."),
						selected: $selected
					)
					.tag(1)
					
					OnboardingPageTextView(
						image: Image(systemName: "wifi.slash"),
						title: Text("Your data is Your data."),
						description: Text("Buddy never spills your secrets. Your data is yours, and only yours. We'll therefore only process your data on device, leveraging the built-in power of your device."),
						selected: $selected
					)
					.tag(2)
					
					OnboardingPageTextView(
						image: Image("Icon-Apple-Health"),
						title: Text("Automatically sync data from Apple Health."),
						description: Text("Buddy uses your Apple Health data to give you better recommendations based on your lifestyle. You'll see a consolidated view of all your health data so you can improve your way of life."),
						selected: $selected
					)
					.tag(3)
				}
				.padding()
				.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
				.overlay(TouchesHandler())
				
				Spacer()
				
				VStack {
					VStack(alignment: .center) {
						caption
							.foregroundColor(Color.white)
							.font(.footnote)
							.multilineTextAlignment(.center)
					}
					.isHidden(caption == nil)
					
					Button(action: {
						if selected == 3 {
							Task {
								let result = await HKManager.authorizeHealthKit()
								
								if result {
									healthManager.initStore()
									workoutManager.initStore()
									
									await MainActor.run {
										isPresented = false
										userData.firstLaunch = false
									}
								} else {
									debugPrint("Did not authorize HK!")
								}
							}
						} else {
							withAnimation(.easeInOut(duration: 0.5)) {
								self.selected += 1
							}
						}
					}) {
						HStack {
							Spacer()
							Text(self.buttonText)
								.font(.headline.bold())
								.foregroundColor(Color(red: 0.0, green: 0.5, blue: 0.4, opacity: 1.0))
								.multilineTextAlignment(.center)
							Spacer()
						}
					}
					.padding()
					.background(Color.white)
					.cornerRadius(Constants.cornerRadius)
				}
				.padding()
			}
		}
		.allowAutoDismiss(false)
		.edgesIgnoringSafeArea(.all)
	}
}

struct OnboardingPageTextView: View {
	let image: Image
	let title: Text
	let description: Text
	var caption: Text?
	@Binding var selected: Int
	
	var body: some View {
		VStack {
			HStack {
				image
					.resizable()
					.frame(width: 75.0, height: 75.0)
				Spacer()
			}
			
			VStack(alignment: .leading) {
				title
					.font(.title.bold())
					.foregroundColor(Color.white)
					.multilineTextAlignment(.leading)
				description
					.foregroundColor(Color.white)
					.multilineTextAlignment(.leading)
					.padding(.top)
			}
		}
	}
}

struct OnboardingView_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			OnboardingView(isPresented: .constant(true))
				.previewDevice("iPhone 11")
			OnboardingView(isPresented: .constant(true))
				.previewDevice("iPhone 8")
		}
		.environmentObject(UserData())
		.environmentObject(HealthKitManager())
		.environmentObject(HealthManager())
		.environmentObject(WorkoutManager())
	}
}
