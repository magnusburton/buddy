//
//  MaxHeartRateAlgorithmView.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-07-19.
//

import SwiftUI

struct MaxHeartRateAlgorithmView: View {
	@EnvironmentObject private var userData: UserData
	@EnvironmentObject private var healthKitManager: HealthKitManager
	
	@State private var selectedFormula: HealthTools.MaxHRAlgorithm = .haskell
	
    var body: some View {
		Form {
			if healthKitManager.dateOfBirth?.age == nil {
				Label(
					title: { Text("No age set!").bold() },
					icon: {
						Image(systemName: "exclamationmark.circle")
							.foregroundColor(.red)
							.font(.system(size: 20))
					})
			}
			
			if healthKitManager.biologicalSex == nil {
				Label(
					title: { Text("No gender set!").bold() },
					icon: {
						Image(systemName: "exclamationmark.circle")
							.foregroundColor(.red)
							.font(.system(size: 20))
					})
			}
			
			AlgorithmRowView(author: "60-days max", formula: .average, formulaString: "Your max HR for the past 60 days", selected: selectedFormula == .average, onTap: {
				selectedFormula = .average
				userData.maxHRAlgorithm = .average
			})
			
			AlgorithmRowView(author: "Nes, et al. (2013)", formula: .nes, formulaString: "211 - (0.64 × age)", selected: selectedFormula == .nes, onTap: {
				selectedFormula = .nes
				userData.maxHRAlgorithm = .nes
			})
			
			AlgorithmRowView(author: "Tanaka, Monahan, & Seals (2001)", formula: .tanaka, formulaString: "208 - (0.7 × age)", selected: selectedFormula == .tanaka, onTap: {
				selectedFormula = .tanaka
				userData.maxHRAlgorithm = .tanaka
			})
			
			AlgorithmRowView(author: "Oakland University (2007)", formula: .oakland, formulaString: "192 - (0.007 × age²)", selected: selectedFormula == .oakland, onTap: {
				selectedFormula = .oakland
				userData.maxHRAlgorithm = .oakland
			})
			
			AlgorithmRowView(author: "Haskell & Fox (1970)", formula: .haskell, formulaString: "220 - age", selected: selectedFormula == .haskell, onTap: {
				selectedFormula = .haskell
				userData.maxHRAlgorithm = .haskell
			})
			
			AlgorithmRowView(author: "Robergs & Landwehr (2002)", formula: .robergs, formulaString: "205.8 - (0.685 × age)", selected: selectedFormula == .robergs, onTap: {
				selectedFormula = .robergs
				userData.maxHRAlgorithm = .robergs
			})
		}
		.navigationBarTitle(Text("Max HR"), displayMode: .inline)
		.onAppear(perform: {
			selectedFormula = userData.maxHRAlgorithm
		})
    }
}

struct MaxHeartRateAlgorithmView_Previews: PreviewProvider {
    static var previews: some View {
        MaxHeartRateAlgorithmView()
			.environmentObject(UserData())
			.environmentObject(HealthKitManager())
    }
}

struct AlgorithmRowView: View {
	@EnvironmentObject private var healthKitManager: HealthKitManager
	
	var author: String
	var formula: HealthTools.MaxHRAlgorithm
	var formulaString: String
	var selected: Bool
	var onTap: () -> Void
	
	@State private var maxHR: Double?
	
	var body: some View {
		Section(header: Text(author), footer: Group {
			if let maxHR = maxHR {
				Text("This formula results in a max HR of \(maxHR.formatted(.number.precision(.fractionLength(1)))) bpm.")
				.bold()
			}
			
		}) {
			if selected {
				HStack {
					Text(formulaString)
						.bold()
					Spacer()
					Image(systemName: "checkmark.circle")
						.font(.body.bold())
				}
				.foregroundColor(.accentColor)
			} else {
				HStack {
					Text(formulaString)
					Spacer()
					Image(systemName: "circle.dotted")
				}
			}
		}
		.contentShape(Rectangle())
		.onTapGesture {
			onTap()
			let feedback = UIImpactFeedbackGenerator()
			feedback.impactOccurred()
		}
		.task {
			if let age = healthKitManager.dateOfBirth?.age {
				maxHR = await HealthTools.getMaxHR(from: age, using: formula, gender: healthKitManager.biologicalSex, date: .now)
			}
		}
	}
}
