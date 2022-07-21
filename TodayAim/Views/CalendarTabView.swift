//
//  CalendarView.swift
//  Today Aim
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
    @State var focusDate: YearMonthDay? = nil
    @State var focusInfo: [TodayAimEntity]? = nil
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \TodayAimEntity.date, ascending: false)]) private var aims: FetchedResults<TodayAimEntity>
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) var colorScheme
    @State private var recentsSelection = RecentsSelection.all
    let sortOptions: [RecentsSelection] = [.all, .accomplished, .favorited]

    var accomplishedColor: Color {
        if colorScheme == .light {
            return .green
        } else {
            return .green.opacity(0.75)
        }
    }
    
    var informations: [YearMonthDay: [TodayAimEntity]] {
        var info = [YearMonthDay: [TodayAimEntity]]()
        for aim in filteredResults {
            var date = YearMonthDay.current
            date = date.addDay(value: aim.offsetFromCurrentDay)
            info[date] = []
            info[date]?.append(aim)
        }
        return info
    }
    
    var filteredResults: [TodayAimEntity] {
        aims.filter { aim in
            switch recentsSelection {
                case .all:
                    return true
                case .accomplished:
                    return aim.isAccomplished
                case .favorited:
                    return aim.isFavorited
            }
        }
    }

    var body: some View {
        GeometryReader { reader in
            VStack {
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
                                    .font(.caption)
                                    .padding(2)
                                    .foregroundColor(.white)
                                    .background(Color.purple.opacity(0.85))
                                    .cornerRadius(14)
                            } else {
                                Text("\(date.day)")
                                    .font(.caption)
                                    .opacity(date.isFocusYearMonth == true ? 1 : 0.4)
                                    .padding(2)
                            }
                            if let infos = informations[date] {
                                ForEach(infos) { aim in
                                    if focusInfo != nil {
                                        Rectangle()
                                            .fill((aim.isAccomplished ? accomplishedColor : notAccomplishedColor(aim: aim)).opacity(0.75))
                                            .frame(width: geometry.size.width, height: 4, alignment: .center)
                                            .cornerRadius(2)
                                            .opacity(date.isFocusYearMonth == true ? 1 : 0.4)
                                    } else {
                                        Text(aim.aimDescription!)
                                            .lineLimit(1)
                                            .foregroundColor(.white)
                                            .font(.system(size: 8, weight: .bold, design: .default))
                                            .padding(EdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4))
                                            .frame(width: geometry.size.width, alignment: .center)
                                            .background((aim.isAccomplished ? accomplishedColor : notAccomplishedColor(aim: aim)).opacity(0.75))
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
                            withAnimation(.easeInOut(duration: 0.3)) {
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
                            ForEach(infos) { aim in
                                VStack(alignment: .leading, spacing: 10) {
                                    CardView(aim: aim, forCalendarView: true)
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
                                .contextMenu {
                                    if aim.isAccomplished {
                                        Button("Toggle Favorited") {
                                            aim.isFavorited.toggle()
                                            try? viewContext.save()
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                // If favorited is selected and then toggled on aim, this closes the view
                                                if (recentsSelection == RecentsSelection.favorited) && !aim.isFavorited {
                                                    focusInfo = nil
                                                }
                                            }
                                        }
                                    }
                                    Button(role: .destructive) {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            focusInfo = nil
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            viewContext.delete(aim)
                                            try? viewContext.save()
                                        }
                                    } label: {
                                        Text("Delete")
                                    }
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
                    .frame(width: reader.size.width, height: 180, alignment: .center)
                }
            }
        }
        .navigationBarTitle("\(controller.yearMonth.monthShortString) \(String(controller.yearMonth.year))")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    controller.scrollTo(controller.yearMonth.addMonth(value: -1), isAnimate: true)
                }label : {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                }
                .padding(8)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    if focusInfo == nil {
                        Menu(content: {
                            Picker("Filter", selection: $recentsSelection, content: {
                                ForEach(sortOptions, id: \.self) {
                                    Text($0.displayString)
                                }
                            })
                        }, label: {
                            Image(systemName: recentsSelection == RecentsSelection.all ? "line.horizontal.3.decrease.circle" : "line.horizontal.3.decrease.circle.fill")
                                .font(.headline)
                        })
                        //.pickerStyle(.menu)
                    }
                    Spacer()
                    Button {
                        controller.scrollTo(controller.yearMonth.addMonth(value: 1), isAnimate: true)
                    }label : {
                        Image(systemName: "chevron.right")
                            .font(.headline)
                    }
                    .padding(8)
                }
            }
        }
        .onDisappear() {
            focusInfo = nil
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
