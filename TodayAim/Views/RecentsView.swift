//
//  RecentsView.swift
//  Today Aim
//
//  Created by Alec Frey on 6/6/22.
//

import SwiftUI
import CoreData

struct RecentsView: View {
    @StateObject var model: AimManager
    var recentsSelection: RecentsSelection
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \TodayAimEntity.date, ascending: false)]) private var aims: FetchedResults<TodayAimEntity>
    
    var accomplishedColor: Color {
        if colorScheme == .light {
            return .green
        } else {
            return .green.opacity(0.75)
        }
    }
    
    var filteredResults: [TodayAimEntity] {
        var aims: [TodayAimEntity] = aims.filter { aim in
            switch recentsSelection {
                case .all:
                    return true
                case .accomplished:
                    return aim.isAccomplished
                case .favorited:
                    return aim.isFavorited
            }
        }
        if aims.count > 15 {
            aims = Array(aims.prefix(upTo: 15))
        }
        return aims
    }

    var body: some View {
        ScrollView {
            VStack {
                ForEach(filteredResults) { aim in
                    VStack(alignment: .leading, spacing: 10) {
                        CardView(aim: aim, forCalendarView: false)
                            .padding(.horizontal)
                    }
                    .padding(.vertical, 12)
                    .background(aim.isAccomplished ? accomplishedColor : notAccomplishedColor(aim: aim))
                    .cornerRadius(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke((aim.isFavorited ? .yellow : .clear), lineWidth: 6)
                    )
                    .padding(3)
                    .animation(.easeInOut(duration: 0.4))
                    .contextMenu {
                        Button(role: .destructive) {
                            viewContext.delete(aim)
                            try? viewContext.save()
                        } label: {
                            Text("Delete")
                        }
                    }
                    .shadow(radius: 0.5)
                }
            }
            .padding()
        }
    }
}

func notAccomplishedColor(aim: TodayAimEntity) -> Color {
    if aim.wasNotAccomplished {
        return .red
    }
    return .gray
}
                         
struct CardView: View {
    @ObservedObject var aim: TodayAimEntity
    @State var isExpanded = false
    var forCalendarView: Bool
    
    var body: some View {
        HStack {
            Text(aim.dateFormatted())
                .font(.title2)
                .fontWeight(.bold)
            Spacer()
            if forCalendarView {
                if aim.timeAccomplished != nil {
                    Text(String(aim.timeAccomplished ?? ""))
                        .font(.caption2)
                } else if aim.wasNotAccomplished {
                    Text("Overdue")
                        .font(.caption2)
                }
            } else {
                Image(systemName: "chevron.compact.down")
                    .foregroundColor(.blue)
            }
        }
        .onTapGesture {
            withAnimation(.spring()) {
                isExpanded.toggle()
            }
        }
        .frame(maxWidth: .infinity)
        Text(aim.aimDescription ?? "")
            .font(.title2)
            .fontWeight(.thin)
            .multilineTextAlignment(.leading)
        if isExpanded && !forCalendarView {
            ExpandedCardView(aim: aim)
                .padding(.top)
        }
    }
}

struct ExpandedCardView: View {
    var aim: TodayAimEntity

    var body: some View {
        HStack {
            Spacer()
            AccomplishedView(aim: aim, forTodayView: false)
                .transition(.move(edge: .leading))
                .animation(.easeInOut(duration: 0.4))
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct AccomplishedView: View {
    @ObservedObject var aim: TodayAimEntity
    var forTodayView: Bool
    @Environment(\.managedObjectContext) private var viewContext
    @State var isAnimating = false

    var body: some View {
        HStack {
            if aim.timeAccomplished != nil {
                StarView(aim: aim, forTodayView: forTodayView)
                Spacer()
            }
            Button(action: {
                if aim.wasCreatedToday {
                    aim.isAccomplished = true
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "h:mm a"
                    aim.timeAccomplished = String(dateFormatter.string(from: Date()))
                }
                try? viewContext.save()
            }) {
                VStack {
                    if !aim.wasNotAccomplished {
                        Image(systemName: aim.isAccomplished ? "checkmark.square.fill" : "checkmark.square")
                            .resizable()
                            .frame(width: aim.isAccomplished  ? 25 : 65, height: aim.isAccomplished  ? 25 : 65)
                    } else {
                        Image(systemName: "multiply.square.fill")
                            .resizable()
                            .frame(width: 25 , height: 25)
                    }
                    Text("Accomplished")
                        .font(.caption)
                    if aim.timeAccomplished != nil {
                        Text(String(aim.timeAccomplished ?? ""))
                            .font(.caption2)
                    } else if aim.wasNotAccomplished {
                        Text("Overdue")
                            .font(.caption2)
                    }
                }
            }
            .font(.title)
            .buttonStyle(BorderlessButtonStyle())
            .disabled(aim.isAccomplished || aim.wasNotAccomplished) // Disables after accomplishing
        }
    }
}



struct StarView: View {
    @ObservedObject var aim: TodayAimEntity
    var forTodayView: Bool
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        Button(action: {
            aim.isFavorited.toggle()
            try? viewContext.save()
        }) {
            VStack {
                Image(systemName: aim.isFavorited ? "star.square.fill" : "star.square")
                    .resizable()
                    .frame(width: aim.isFavorited  ? 25 : 65, height: aim.isFavorited  ? 25 : 65)
                Text("Favorited")
                    .font(.caption)
            }
        }
        .font(.title)
        .tint(forTodayView ? Color(0x659AFF) : Color.blue)
        .buttonStyle(BorderlessButtonStyle())
    }
}

/*
struct AimGalleryView_Previews: PreviewProvider {
    static var previews: some View {
        AimGalleryView()
    }
}
*/
