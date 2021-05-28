//
//  WorkoutSimpleCardView.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-05-25.
//

import SwiftUI

import CareKitUI

struct WorkoutSimpleCardView: View {
	var title: String
	var details: String?
	var state: LabeledValueTaskViewState?
	
	var detailText: Text? {
		if let detail = self.details {
			return Text("\(detail)")
		}
		return nil
	}
	var stateText: LabeledValueTaskViewState {
		if let stateParam = state {
			return stateParam
		}
		return .incomplete(Text("No data"))
	}
	
	var body: some View {
		CardView {
			VStack {
				LabeledValueTaskView(
					title: Text("\(title)"),
					detail: detailText,
					state: stateText
				)
			}
			.padding()
		}
	}
}


struct WorkoutSimpleCardView_Previews: PreviewProvider {
    static var previews: some View {
		Group {
			ViewPreview(WorkoutSimpleCardView(
							title: "Cadence",
							details: "Something something something something",
							state: .complete(Text("165"), Text("spm"))))
			ViewPreview(WorkoutSimpleCardView(title: "Cadence"))
		}
		.frame(width: 350)
    }
}
