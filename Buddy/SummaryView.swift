//
//  SummaryView.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-03-05.
//

import SwiftUI
import CareKitUI
import HealthKit

struct SummaryView: View {
	@Environment(\.managedObjectContext) private var viewContext
	@EnvironmentObject private var userData: UserData
	@EnvironmentObject private var healthManager: HealthManager
	
	@State var workouts = 212.0
	@State var showProfile = false
	
    var body: some View {
		NavigationView {
			ScrollView {
				LazyVStack {
					CardView {
						VStack(alignment: .leading) {
							Text("Analyzing your workouts")
								.font(.headline.bold())
							Text("I'm currently analyzing your workouts. This may take a while snce it's the initial setup but I'll keep it up-to-date incrementally.")
								.font(.caption)
								.fontWeight(.medium)
								.lineLimit(nil)
							
							ProgressBarView(progress: self.workouts / 265.0)
							
							Text("\(self.workouts, specifier: "%.0f") of 265 workouts analyzed.")
								.font(.caption)
								.fontWeight(.medium)
								.foregroundColor(.gray)
						}
						.padding(.all)
					}
					
					CardView {
						Slider(value: $workouts,
							   in: 0...265,
							   step: 1)
						.padding()
					}
					
					ForEach(healthManager.insights) { insight in
						InsightCardView(insight)
					}
					
					if userData.showFirstNameCard {
						SummaryNameCardView()
					}
					
					HStack {
						Text("Insights")
							.font(.title2.bold())
						
						Spacer()
						
						Button(action: {
							healthManager.generateInsights()
						}, label: {
							Text("Generate")
								.font(.caption)
						})
					}
					
					CardView {
						HStack(spacing: Constants.spacing*3) {
							Spacer()
							ProgressView()
								.progressViewStyle(CircularProgressViewStyle())
							Text("Loading insights")
							Spacer()
						}
						.frame(height: 100)
						.padding()
					}
					
					CardView {
						VStack {
							LabeledValueTaskView(
								title: Text("Heart Rate Variability"),
								detail: Text("During the past two months your average HRV has increased. This is a good sign and represent an increase in fitness and a decreased level of stress."),
								state: .complete(
									Text("\(healthManager.data[.hrv]?.average ?? 0, specifier: "%.0f")"),
									Text("ms")
								)
							)
							
							Text("Trend: \(healthManager.data[.hrv]?.trend() ?? -123)")
							
							Divider()
							
							BaselineChartView(for: .hrv)
						}
						.padding()
					}
					
					CardView {
						VStack {
							LabeledValueTaskView(
								title: Text("Resting Heart Rate"),
								detail: Text("During the past two months your average RHR has decreased. This is a good sign and represent an increase in fitness and a decreased level of stress."),
								state: .complete(
									Text("\(healthManager.data[.rhr]?.average ?? 0, specifier: "%.0f")"),
									Text("bpm")
								)
							)
							
							Text("Trend: \(healthManager.data[.rhr]?.trend() ?? -123)")
							
							Divider()
							
							BaselineChartView(for: .rhr)
						}
						.padding()
					}
					
					CardView {
						VStack {
							LabeledValueTaskView(
								title: Text("Body Fat"),
								detail: Text("During the past two months your average body fat has decreased. This is a good sign and represent an increase in fitness and a decreased risk of heart disease."),
								state: .complete(
									Text("\(healthManager.data[.bodyFat]?.average ?? 0, specifier: "%.0f")"),
									Text("%")
								)
							)
							
							Text("Trend: \(healthManager.data[.bodyFat]?.trend() ?? -123)")
							
							Divider()
							
							BaselineChartView(for: .bodyFat)
						}
						.padding()
					}
				}
				.padding()
			}
			.navigationTitle("Hi \(userData.firstName ?? "there")!")
			.toolbar {
				Button(action: {
					self.showProfile.toggle()
				}) {
					Image(systemName: "person.crop.circle")
						.font(.title)
				}.sheet(isPresented: $showProfile) {
					ProfileView(isPresented: self.$showProfile)
						.environmentObject(userData)
				}
			}
		}
    }
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView()
			.environmentObject(UserData())
			.environmentObject(HealthManager())
    }
}
