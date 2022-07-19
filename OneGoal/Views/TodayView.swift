//
//  ContentView.swift
//  OneGoal
//
//  Created by Alec Frey on 6/6/22.
//

import SwiftUI
import SwiftUICalendar

struct TodayView: View {
    @ObservedObject var model: GoalManager
    
    var body: some View {
        ZStack {
            TodayGradient()
            WriteGoalView(model: model)
                .padding(.horizontal, 32)
        }
    }
}

struct WriteGoalView: View {
    @ObservedObject var model: GoalManager
    @State private var isPresented: Bool = false
    @State private var isEdited: Bool = false
    @State private var text: String = ""
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) var colorScheme
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \GoalEntity.date, ascending: false)]) private var goals: FetchedResults<GoalEntity>
    
    var isLightMode: Bool {
        if colorScheme == .light {
            return true
        } else {
            return false
        }
    }
    
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
            VStack {
                HStack {
                    Text("Aim")
                        .font(.title2)
                        .fontWeight(.medium)
                    Spacer()
                    Text(Date(), style: .date)
                        .font(.subheadline)
                        .fontWeight(.light)
                }
                .padding(.horizontal, 2)
                .padding()
                .background(isLightMode ? .white.opacity(0.6) : .black.opacity(0.6))
                Spacer()
                if let todayGoal = todayGoal {
                    TodayGoalView(goal: todayGoal)
                } else {
                    Button("Set Aim") {
                        self.text = ""
                        self.isPresented = true
                    }
                    .font(.title)
                    .tint(Color(0x659AFF))
                }
                Spacer()
            }
            .background(isLightMode ? .white.opacity(0.6) : .black.opacity(0.6))
            .cornerRadius(25)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .stroke((todayGoal?.isFavorited ?? false ? .yellow : .clear), lineWidth: 6)
            )
            NewGoalAlert(isShown: $isPresented, text: $text, title: "Enter Today's Aim", onDone: { text in
                _ = GoalEntity(goalDescription: text.trimmingCharacters(in: .whitespaces), context: viewContext)
                try? viewContext.save()
            })
            NewGoalAlert(isShown: $isEdited, text: $text, title: "Edit Aim Description", onDone: { text in
                todayGoal!.goalDescription = text.trimmingCharacters(in: .whitespaces)
                try? viewContext.save()
            })
        }
        .frame(height: 400)
        .animation(.easeInOut(duration: 0.4))
        .padding(6)
        .contextMenu {
            if !isEdited {
                if let todayGoal = todayGoal {
                    Button("Edit") {
                        self.text = todayGoal.goalDescription!
                        // Slight delay to allow context menu animation to finish
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            self.isEdited = true
                        }                    }
                    Button("Mark Not Accomplished") {
                        // Slight delay to allow context menu animation to finish
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            if todayGoal.isAccomplished {
                                todayGoal.isFavorited = false
                                todayGoal.isAccomplished = false
                                todayGoal.timeAccomplished = nil
                                try? viewContext.save()
                            }
                        }
                    }
                    Button(role: .destructive) {
                        viewContext.delete(todayGoal)
                        try? viewContext.save()
                    } label: {
                        Text("Delete")
                    }
                } else {
                    Button("Set Goal") {
                        self.text = ""
                        // Slight delay to allow context menu animation to finish
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            self.isPresented = true
                        }
                    }
                }
            }
        }
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
    }
}

struct TodayGoalView: View {
    @ObservedObject var goal: GoalEntity

    var body: some View {
        ZStack {
            VStack {
                ScrollView {
                    Text(goal.goalDescription ?? "")
                        .font(.title2)
                }
                Spacer()
                AccomplishedView(goal: goal, forTodayView: true)
                    .transition(.move(edge: .leading))
                    .padding(.top)
            }
            .frame(width: 225, height: 275, alignment: .top)
       }
    }
}

struct TodayGradient: View {
    @State private var switchBackground = Color(0xB661E1)

    var body: some View {
        Rectangle()
            .ignoresSafeArea()
            .foregroundColor(switchBackground)
            .task {
                withAnimation(.easeIn(duration: 1).delay(1).repeatForever()) {
                    switchBackground = Color(0xBE73ED)
                }
            }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        
        return Path(path.cgPath)
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
struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        WriteGoalView()
    }
}
*/
