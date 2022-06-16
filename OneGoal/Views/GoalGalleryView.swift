//
//  GoalGallery.swift
//  OneGoal
//
//  Created by Alec Frey on 6/6/22.
//

import SwiftUI

struct GoalGalleryView: View {
    @ObservedObject var model: GoalManager
    var gallerySelection: GallerySelection
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: []) private var goals: FetchedResults<GoalEntity>

    var accomplishedColor: Color {
        if colorScheme == .light {
            return .green
        } else {
            return .green.opacity(0.65)
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
        List(filteredResults) { goal in
            Section {
                CardView(goal: goal)
            }
            .listRowBackground(goal.isAccomplished ? accomplishedColor : Color.red).animation(.easeIn(duration: 0.5))
            .shadow(radius: 0.5)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(action: {
                    viewContext.delete(goal)
                    try? viewContext.save()
                }, label: {
                    Text("Delete")
                })
            }
        }
    }
}
                         
struct CardView: View {
    @ObservedObject var goal: GoalEntity
    @State var isExpanded = false
    
    var body: some View {
        HStack {
            Text(goal.dateFormatted())
                .font(.title)
                .fontWeight(.bold)
            Spacer()
            Image(systemName: "chevron.compact.down")
                .foregroundColor(.blue)
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.5)) {
                isExpanded.toggle()
            }
        }
        .frame(maxWidth: .infinity)
        .transition(.move(edge: .bottom))
        .cornerRadius(10)
        Text(goal.goalDescription ?? "")
            .font(.title2)
            .fontWeight(.thin)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.leading)
        if isExpanded {
            ExpandedCardView(goal: goal)
        }
    }
}

struct ExpandedCardView: View {
    var goal: GoalEntity

    var body: some View {
        HStack {
            Spacer()
            AccomplishedView(goal: goal)
                .transition(.move(edge: .leading))
                .animation(.easeInOut(duration: 1))
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct AccomplishedView: View {
    @ObservedObject var goal: GoalEntity
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        HStack {
            // Favorite always or just on accomplished
            // if goal.goalArray[index].timeAccomplished != nil || goal.goalArray[index].wasNotAccomplished {
            if goal.timeAccomplished != nil {
                StarView(goal: goal)
                Spacer()
            }
            Button(action: {
                if goal.goalWasCreatedToday {
                    goal.isAccomplished = true
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "h:mm a"
                    goal.timeAccomplished = String(dateFormatter.string(from: Date()))
                } else {
                    goal.wasNotAccomplished = true
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
