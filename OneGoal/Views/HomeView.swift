//
//  ContentView.swift
//  OneGoal
//
//  Created by Alec Frey on 6/6/22.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var model: OneGoalViewModel
    
    var body: some View {
        ZStack {
            HomeGradient()
            WriteGoalView(model: model)
        }
    }
}

struct WriteGoalView: View {
    @ObservedObject var model: OneGoalViewModel
    @State private var isPresented: Bool = false
    @State private var text: String = ""
    
    var body: some View {
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 25)
                .foregroundColor(.mint)
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
                if model.isTodaysGoalCreated() {
                    HomeGoalView(goal: $model.goalArray[model.goalArray.count - 1])
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
                var newGoalArray = self.model.goalArray
                newGoalArray.append(Goal(description: text))
                self.model.goalArray = newGoalArray
                model.printNewGoal()
            })
        }
        .padding()
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
        .frame(width: 320, height: 420)
    }
}

struct HomeGoalView: View {
    @Binding var goal: Goal

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .frame(width: 225, height: 275)
                //.foregroundColor(.gray).opacity(0.65)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke((goal.isFavorited ? .yellow : .clear), lineWidth: 5)
                )
                .animation(.easeInOut(duration: 1))
            VStack {
                ScrollView {
                    Text(goal.description)
                        .font(.title3)
                        .foregroundColor(.black)
                }
                Spacer()
                AccomplishedView(goal: $goal)
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
