//
//  ContentViewPlaceholder.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-03-04.
//

import SwiftUI
import CareKitUI

struct ContentViewPlaceholder: View {
	@Environment(\.managedObjectContext) private var viewContext
	@EnvironmentObject private var userData: UserData
	
	@FetchRequest(
		sortDescriptors: [NSSortDescriptor(keyPath: \Workout.endDate, ascending: true)],
		animation: .default)
	private var items: FetchedResults<Workout>
	
	var body: some View {
		VStack {
			CardView {
				HStack {
					Spacer()
					Button(action: addItem) {
						Label("Add Item", systemImage: "plus")
					}
					Spacer()
				}
				.padding()
			}
			.padding()
			
			List {
				ForEach(items) { item in
					Text("Item at \(item.startDate!, formatter: itemFormatter) \(item.endDate!, formatter: itemFormatter) \(item.processed ? "true" : "false")")
				}
				.onDelete(perform: deleteItems)
			}
		}
	}
	
	private func addItem() {
		withAnimation {
			let newItem = Workout(context: viewContext)
			newItem.endDate = Date()
			newItem.startDate = Date().addingTimeInterval(-60*46)
			newItem.processed = false
			
			do {
				try viewContext.save()
			} catch {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				let nsError = error as NSError
				fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
			}
		}
	}
	
	private func deleteItems(offsets: IndexSet) {
		withAnimation {
			offsets.map { items[$0] }.forEach(viewContext.delete)
			
			do {
				try viewContext.save()
			} catch {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				let nsError = error as NSError
				fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
			}
		}
	}
}

private let itemFormatter: DateFormatter = {
	let formatter = DateFormatter()
	formatter.dateStyle = .short
	formatter.timeStyle = .medium
	return formatter
}()

struct ContentViewPlaceholder_Previews: PreviewProvider {
	static var previews: some View {
		ContentViewPlaceholder()
			.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
			.environmentObject(UserData())
			.environmentObject(HealthManager())
			.environmentObject(WorkoutManager())
	}
}
