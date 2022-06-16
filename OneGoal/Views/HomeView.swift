//
//  ContentView.swift
//  OneGoal
//
//  Created by Alec Frey on 6/6/22.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var model: GoalManager
    
    var body: some View {
        ZStack {
            HomeGradient()
            WriteGoalView(model: model)
        }
    }
}

struct WriteGoalView: View {
    @ObservedObject var model: GoalManager
    @State private var isPresented: Bool = false
    @State private var text: String = ""
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \GoalEntity.date, ascending: false)]) private var goals: FetchedResults<GoalEntity>
    var todayGoal: GoalEntity? {
        guard let goal = goals.first, let date = goal.date else {
            return nil
        }
        if (Calendar.current.isDateInToday(date)) {
            return goal
        }
        return nil
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 25)
                .foregroundColor(.secondary)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke((todayGoal?.isFavorited ?? false ? .yellow : .clear), lineWidth: 5)
                )
            VStack {
                HStack {
                    Text("One Goal")
                        .font(.title2)
                        .fontWeight(.medium)
                    Spacer()
                    Text(Date(), style: .date)
                        .font(.subheadline)
                        .fontWeight(.thin)
                }
                .padding()
                Spacer()
                if let todayGoal = todayGoal {
                    HomeGoalView(goal: todayGoal)
                } else {
                    Button("Set Goal") {
                        self.text = ""
                        self.isPresented = true
                    }
                    .font(.title)
                }
                Spacer()
            }
            NewGoalAlert(isShown: $isPresented, text: $text, onDone: { text in
                _ = GoalEntity(goalDescription: text, context: viewContext)
                try? viewContext.save()
            })
        }
        .padding()
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
        .frame(width: 320, height: 420)
        .animation(.easeInOut(duration: 1))
    }
}

struct HomeGoalView: View {
    @ObservedObject var goal: GoalEntity

    var body: some View {
        ZStack {
            VStack {
                ScrollView {
                    Text(goal.goalDescription ?? "")
                        .font(.title3)
                       // .foregroundColor(.black)
                }
                Spacer()
                AccomplishedView(goal: goal)
                    .transition(.move(edge: .leading))
                    .animation(.easeInOut(duration: 1))
            }
            .padding()
            .frame(width: 225, height: 275, alignment: .top)
       }
    }
}

struct HomeGradient: View {
    @State private var switchBackground = Color(0xB45CEA)

    var body: some View {
        Rectangle()
            .ignoresSafeArea()
            .foregroundColor(switchBackground)
            .task {
                withAnimation(.easeIn(duration: 1).delay(1).repeatForever()) {
                    switchBackground = Color(0xBE73ED)
                }
                withAnimation(.easeIn(duration: 1).delay(2).repeatForever()) {
                    switchBackground = Color(0x8514CB)
                }
                withAnimation(.easeIn(duration: 1).delay(3).repeatForever()) {
                    switchBackground = Color(0xA945E7)
                }
            }
    }
}

extension Color {
  init(_ hex: UInt, alpha: Double = 1) {
    self.init(
      .sRGB,
      red: Double((hex >> 16) & 0xFF) / 255,
      green: Double((hex >> 8) & 0xFF) / 255,
      blue: Double(hex & 0xFF) / 255,
      opacity: alpha
    )
  }
}

/*
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        WriteGoalView()
    }
}
*/
