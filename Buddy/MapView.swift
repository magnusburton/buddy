//
//  MapView.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-03-14.
//

import SwiftUI
import MapKit

struct MapView: View {
	@State var region = MKCoordinateRegion(center: .init(latitude: 37.334722, longitude: -122.008889), latitudinalMeters: 1200, longitudinalMeters: 1200)
	
	var interactionModes: MapInteractionModes = []
	
	var body: some View {
		Map(coordinateRegion: $region,
			interactionModes: interactionModes,
			showsUserLocation: true,
			userTrackingMode: nil,
			annotationItems: [PinItem(coordinate: .init(latitude: 37.334722, longitude: -122.008889))]) {
			item in MapMarker(coordinate: item.coordinate)
		}
		.edgesIgnoringSafeArea(.all)
	}
}

struct PinItem: Identifiable {
	let id = UUID()
	let coordinate: CLLocationCoordinate2D
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
