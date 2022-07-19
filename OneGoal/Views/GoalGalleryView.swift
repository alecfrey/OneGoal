//
//  GoalGallery.swift
//  OneGoal
//
//  Created by Alec Frey on 6/6/22.
//

import SwiftUI

struct GoalGalleryView: View {
    @StateObject var model: GoalManager
    var gallerySelection: GallerySelection
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \GoalEntity.date, ascending: false)]) private var goals: FetchedResults<GoalEntity>

    var accomplishedColor: Color {
        if colorScheme == .light {
            return .green
        } else {
            return .green.opacity(0.75)
        }
    }

    var filteredResults: [GoalEntity] {
        goals.filter { goal in
            switch gallerySelection {
                case .all:
                    return true
                case .accomplished:
                    return goal.isAccomplished
                case .favorited:
                    return goal.isFavorited
            }
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack() {
                ForEach(filteredResults) { goal in
                    VStack(alignment: .leading, spacing: 10) {
                        CardView(goal: goal, forCalendarView: false)
                            .padding(.horizontal)

                    }
                    .padding(.vertical, 12)
                    .background(goal.isAccomplished ? accomplishedColor : notAccomplishedColor(goal: goal))
                    .cornerRadius(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke((goal.isFavorited ? .yellow : .clear), lineWidth: 6)
                    )
                    .padding(3)
                    .contextMenu {
                        Button(role: .destructive) {
                            viewContext.delete(goal)
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

func notAccomplishedColor(goal: GoalEntity) -> Color {
    if goal.wasNotAccomplished {
        return .red
    }
    return .gray
}
                         
struct CardView: View {
    @ObservedObject var goal: GoalEntity
    @State var isExpanded = false
    var forCalendarView: Bool
    
    var body: some View {
        HStack {
            Text(goal.dateFormatted())
                .font(.title2)
                .fontWeight(.bold)
            Spacer()
            if forCalendarView {
                if goal.timeAccomplished != nil {
                    Text(String(goal.timeAccomplished ?? ""))
                        .font(.caption2)
                } else if goal.wasNotAccomplished {
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
        Text(goal.goalDescription ?? "")
            .font(.title2)
            .fontWeight(.thin)
            .multilineTextAlignment(.leading)
        if isExpanded && !forCalendarView {
            ExpandedCardView(goal: goal)
                .padding(.top)
        }
    }
}

struct ExpandedCardView: View {
    var goal: GoalEntity
    @State private var scale = 1.0


    var body: some View {
        HStack {
            Spacer()
            AccomplishedView(goal: goal, forTodayView: false)
                .transition(.move(edge: .leading))
               // .animation(.easeInOut(duration: 0.4))
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct AccomplishedView: View {
    @ObservedObject var goal: GoalEntity
    var forTodayView: Bool
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        HStack {
            if goal.timeAccomplished != nil {
                StarView(goal: goal, forTodayView: forTodayView)
                Spacer()
            }
            Button(action: {
                if goal.goalWasCreatedToday {
                    goal.isAccomplished = true
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "h:mm a"
                    goal.timeAccomplished = String(dateFormatter.string(from: Date()))
                }
                try? viewContext.save()
            }) {
                VStack {
                    if !goal.wasNotAccomplished {
                        Image(systemName: goal.isAccomplished ? "checkmark.square.fill" : "checkmark.square")
                            .resizable()
                            .frame(width: goal.isAccomplished  ? 25 : 65, height: goal.isAccomplished  ? 25 : 65)
                    } else {
                        Image(systemName: "multiply.square.fill")
                            .resizable()
                            .frame(width: 25 , height: 25)
                    }
                    Text("Accomplished")
                        .font(.caption)
                    if goal.timeAccomplished != nil {
                        Text(String(goal.timeAccomplished ?? ""))
                            .font(.caption2)
                    } else if goal.wasNotAccomplished {
                        Text("Overdue")
                            .font(.caption2)
                    }
                }
            }
            .font(.title)
            .buttonStyle(BorderlessButtonStyle())
            .disabled(goal.isAccomplished || goal.wasNotAccomplished) // Disables after accomplishing
        }
    }
}

struct StarView: View {
    @ObservedObject var goal: GoalEntity
    var forTodayView: Bool
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        Button(action: {
            goal.isFavorited.toggle()
            try? viewContext.save()
        }) {
            VStack {
                Image(systemName: goal.isFavorited ? "star.square.fill" : "star.square")
                    .resizable()
                    .frame(width: goal.isFavorited  ? 25 : 65, height: goal.isFavorited  ? 25 : 65)
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
struct GoalGalleryView_Previews: PreviewProvider {
    static var previews: some View {
        GoalGalleryView()
    }
}
*/
