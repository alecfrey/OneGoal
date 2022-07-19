//
//  CalendarView.swift
//  OneGoal
//
//  Created by Alec Frey on 6/14/22.
//

import SwiftUI
import SwiftUICalendar

extension YearMonthDay: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.year)
        hasher.combine(self.month)
        hasher.combine(self.day)
    }
}

struct CalendarTabView: View {
    @ObservedObject var controller = CalendarController()
    var isFavorited: Bool = true
    @State var focusDate: YearMonthDay? = nil
    @State var focusInfo: [GoalEntity]? = nil
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \GoalEntity.date, ascending: false)]) private var goals: FetchedResults<GoalEntity>
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) var colorScheme
    
    var accomplishedColor: Color {
        if colorScheme == .light {
            return .green
        } else {
            return .green.opacity(0.75)
        }
    }
    
    var informations: [YearMonthDay: [GoalEntity]] {
        var info = [YearMonthDay: [GoalEntity]]()
        for goal in goals {
            var date = YearMonthDay.current
            date = date.addDay(value: goal.offsetFromCurrentDay)
            info[date] = []
            info[date]?.append(goal)
        }
        return info
    }

    var body: some View {
        GeometryReader { reader in
            VStack {
                HStack(alignment: .center, spacing: 0) {
                    Button {
                        controller.scrollTo(controller.yearMonth.addMonth(value: -1), isAnimate: true)
                    }label : {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                    }
                    .padding(8)
                    Spacer()
                    Text("\(controller.yearMonth.monthShortString) \(String(controller.yearMonth.year))")
                        .font(.title3)
                        .fontWeight(.medium)
                        .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                    Spacer()
                    Button {
                        controller.scrollTo(controller.yearMonth.addMonth(value: 1), isAnimate: true)
                    }label : {
                        Image(systemName: "chevron.right")
                            .font(.headline)
                    }
                    .padding(8)
                }
                .padding([.top, .leading, .trailing])
                CalendarView(controller, header: { week in
                    GeometryReader { geometry in
                        Text(week.shortString)
                            .font(.subheadline)
                            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                    }
                }, component: { date in
                    Divider()
                    GeometryReader { geometry in
                        VStack(alignment: .leading, spacing: 2) {
                            if date.isToday {
                                Text("\(date.day)")
                                    .font(.footnote)
                                    .padding(2)
                                    .foregroundColor(.white)
                                    .background(Color.purple.opacity(0.85))
                                    .cornerRadius(14)
                            } else {
                                Text("\(date.day)")
                                    .font(.footnote)
                                    .opacity(date.isFocusYearMonth == true ? 1 : 0.4)
                                    .padding(2)
                            }
                            if let infos = informations[date] {
                                ForEach(infos) { goal in
                                    if focusInfo != nil {
                                        Rectangle()
                                            .fill((goal.isAccomplished ? accomplishedColor : notAccomplishedColor(goal: goal)).opacity(0.75))
                                            .frame(width: geometry.size.width, height: 4, alignment: .center)
                                            .cornerRadius(2)
                                            .opacity(date.isFocusYearMonth == true ? 1 : 0.4)
                                    } else {
                                        Text(goal.goalDescription!)
                                            .lineLimit(1)
                                            .foregroundColor(.white)
                                            .font(.system(size: 8, weight: .bold, design: .default))
                                            .padding(EdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4))
                                            .frame(width: geometry.size.width, alignment: .center)
                                            .background((goal.isAccomplished ? accomplishedColor : notAccomplishedColor(goal: goal)).opacity(0.75))
                                            .cornerRadius(4)
                                            .opacity(date.isFocusYearMonth == true ? 1 : 0.4)
                                    }
                                }
                            }
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topLeading)
                        .border(.purple.opacity(0.8), width: (focusDate == date ? 1 : 0))
                        .cornerRadius(2)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                if focusDate == date {
                                    focusDate = nil
                                    focusInfo = nil
                                } else {
                                    focusDate = date
                                    focusInfo = informations[date]
                                }
                            }
                        }
                    }
                    .padding()
                })
                if let infos = focusInfo {
                    ScrollView {
                        LazyVStack() {
                            ForEach(infos) { goal in
                                VStack(alignment: .leading, spacing: 10) {
                                    CardView(goal: goal, forCalendarView: true)
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
                                    if goal.isAccomplished {
                                        Button("Toggle Favorited") {
                                            goal.isFavorited.toggle()
                                            try? viewContext.save()
                                        }
                                    }
//                                    Button(role: .destructive) {
//                                        viewContext.delete(goal)
//                                        try? viewContext.save()
//                                    } label: {
//                                        Text("Delete")
//                                    }
                                }
                                .shadow(radius: 0.5)
                            }
                            .padding()
                        }
//                        .gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
//                            .onEnded { value in
//                                print(value.translation)
//                                switch(value.translation.width, value.translation.height) {
//                                    case (...0, -30...30): controller.scrollTo(controller.yearMonth.addMonth(value: 1), isAnimate: true)
//                                    case (0..., -30...30): controller.scrollTo(controller.yearMonth.addMonth(value: -1), isAnimate: true)
//                                    default: ()
//                                }
//                            }
//                        )
                    }
                    .frame(width: reader.size.width, height: 160, alignment: .center)
                }
            }
        }
    }
}

/*
struct CalendarTabView: View {
    var body: some View {
        CalendarView() { date in
            Text("\(date.day)")
        }
        .padding()
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarTabView()
    }
}
*/
