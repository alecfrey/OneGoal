//
//  GoalWidget.swift
//  GoalWidget
//
//  Created by Alec Frey on 6/14/22.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct GoalWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack {
            HStack {
                Text("One Goal")
                    .font(.headline)
                    .foregroundColor(.purple)
                Spacer()
                Text(Date(), style: .date)
                    .font(.subheadline)
                    .fontWeight(.thin)
            }
            .padding(.horizontal)
            .padding(.top)
            ZStack {
                Rectangle()
                    //.foregroundColor(Color(goal.isAccomplished ? .green : .red))
                    .animation(.easeIn(duration: 0.5))
                HStack {
                    GoalCardView()
                    Spacer()
                    VStack {
                        Button(action: {
                            
                        }, label: {
                            Image(systemName: "checkmark.square")
                                .resizable()
                                .frame(width: 35 , height: 35)
                        })
                        Button(action: {
                            
                        }, label: {
                            Image(systemName: "star.square")
                                .resizable()
                                .frame(width: 35 , height: 35)
                        })
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct GoalCardView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(.white)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 15)
//                        //.stroke((goal.isFavorited ? .yellow : .clear), lineWidth: 5)
//                        .foregroundColor(.white)
//                        .border(.black, width: 5)
//                )
                .cornerRadius(15)
                .animation(.easeInOut(duration: 1))
            //Text(goal.description)
                .padding()
                .font(.caption)
                .foregroundColor(.black)
        }
        .frame(width: 225, height: 85, alignment: .leading)
    }
}

@main
struct GoalWidget: Widget {
    let kind: String = "GoalWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            GoalWidgetEntryView(entry: entry)
        }
       // .supportedFamilies([.systemMedium])
        .supportedFamilies([])
        .configurationDisplayName("Today Aim")
        .description("Accomplish the aim of the day.")
    }
}

struct GoalWidget_Previews: PreviewProvider {
    static var previews: some View {
        GoalWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
