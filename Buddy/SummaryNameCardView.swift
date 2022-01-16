//
//  SummaryNameCardView.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-05-20.
//

import SwiftUI
import CareKitUI

struct SummaryNameCardView: View {
	@EnvironmentObject private var userData: UserData
	
	@State var firstName: String?
	
	var saveDisabled: Bool {
		return firstName?.count ?? 0 < 2
	}
	
	struct SummaryTextFieldStyle: TextFieldStyle {
		func _body(configuration: TextField<Self._Label>) -> some View {
			configuration
				.font(.headline.bold())
				.padding()
				.background(Color.tertiarySystemBackground)
				.cornerRadius(Constants.cornerRadius)
				.overlay(RoundedRectangle(cornerRadius: Constants.cornerRadius).strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.0)))
		}
	}
	
    var body: some View {
		CardView {
			VStack(alignment: .leading, spacing: Constants.spacing) {
				Text("profile.name.card.title")
					.font(.headline)
					.bold()
				Text("profile.name.card.description")
					.font(.caption)
					.fontWeight(.medium)
					.multilineTextAlignment(.leading)
				
				// Fix done button
				TextField("profile.name.card.placeholder", text: $firstName ?? "")
					.textContentType(.givenName)
					.textFieldStyle(SummaryTextFieldStyle())
					.padding([.vertical])
					.submitLabel(.done)
					.onSubmit {
						if let firstName = firstName?.trimmingCharacters(in: .whitespacesAndNewlines), firstName.count > 0 {
							userData.firstName = firstName
							
							withAnimation {
								userData.showFirstNameCard = false
							}
						}
						
						hideKeyboard()
					}
				
				Button(action: {
					if let firstName = firstName?.trimmingCharacters(in: .whitespacesAndNewlines), firstName.count > 0 {
						userData.firstName = firstName
					}
					
					withAnimation {
						userData.showFirstNameCard = false
					}
					hideKeyboard()
				}) {
					HStack {
						Spacer()
						Text("Save")
							.font(.headline.bold())
							.foregroundColor(.white)
							.multilineTextAlignment(.center)
						Spacer()
					}
				}
				.disabled(saveDisabled)
				.padding()
				.overlay(Color.black.opacity(saveDisabled ? 0.3 : 0.0))
				.background(Color(red: 0.0, green: 0.5, blue: 0.4, opacity: 1.0))
				.cornerRadius(Constants.cornerRadius)
				
				Button(action: {
					withAnimation {
						userData.showFirstNameCard = false
					}
					hideKeyboard()
				}) {
					HStack {
						Spacer()
						Text("Skip")
							.font(.subheadline.bold())
							.foregroundColor(Color(red: 0.0, green: 0.5, blue: 0.4, opacity: 1.0))
							.multilineTextAlignment(.center)
						Spacer()
					}
				}
				.padding(Constants.padding)
				.background(Color.white)
				.overlay(RoundedRectangle(cornerRadius: Constants.cornerRadius).strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.0)))
				.cornerRadius(Constants.cornerRadius)
				.padding([.top, .bottom], 2)
				
				Text("profile.name.card.privacy")
					.font(.caption2)
					.foregroundColor(.secondary)
					.multilineTextAlignment(.leading)
			}.padding()
		}
    }
}

struct SummaryNameCardView_Previews: PreviewProvider {
    static var previews: some View {
        ViewPreview(SummaryNameCardView())
			.environmentObject(UserData.shared)
    }
}
