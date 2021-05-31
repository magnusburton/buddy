//
//  HeartWidget.swift
//  HeartWidget
//
//  Created by Magnus Burton on 2021-04-13.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct HeartWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
		VStack(alignment: .leading) {
			Text("Heart Rate Variability")
				.font(.headline.bold())
			
			HStack(alignment: .top) {
				VStack(alignment: .leading) {
					HStack(alignment: .lastTextBaseline, spacing: 2) {
						Text("53")
							.font(.system(size: 30).bold())
						Text("ms")
							.font(Font.subheadline.weight(.medium))
					}
					Spacer()
					Text("Most recent: 62 ms")
						.font(.caption)
				}
				Spacer()
			}
		}
		.foregroundColor(.white)
		.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
		.padding(Constants.widget.padding)
		.background(LinearGradient(gradient: Gradient(colors: [Color(red: 255/255, green: 0/255, blue: 138/255, opacity: 1.0), Color(red: 255/255, green: 35/255, blue: 33/255, opacity: 1.0)]), startPoint: .top, endPoint: .bottom))
    }
}

@main
struct HeartWidget: Widget {
    let kind: String = "HeartWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            HeartWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
		.supportedFamilies([.systemMedium])
    }
}

struct HeartWidget_Previews: PreviewProvider {
    static var previews: some View {
        HeartWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
