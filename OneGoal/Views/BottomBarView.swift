//
//  TabView.swift
//  OneGoal
//
//  Created by Alec Frey on 6/10/22.
//

import SwiftUI

enum GallerySelection {
    case all
    case accomplished
    case favorited
    
    var displayString: String {
        switch self {
            case .all: return "All"
            case .accomplished: return "Accomplished"
            case .favorited: return "Favorited"
        }
    }
}

struct BottomBarView: View {
    @StateObject var viewModel = GoalManager()
    @State private var gallerySelection = GallerySelection.all
    let sortOptions: [GallerySelection] = [.all, .accomplished, .favorited]

    init() {
        //UITabBar.appearance().backgroundColor = .black
    }
    
    var body: some View {
        TabView {
            NavigationView {
                HomeView(model: viewModel)
                    .navigationTitle("Home")
            }
            .tabItem {
                Image(systemName: "house")
                Text("Home")
            }
            NavigationView {
                GoalGalleryView(model: viewModel, gallerySelection: gallerySelection)
                    .navigationTitle("Gallery")
                    .toolbar {
                        Picker("Sort", selection: $gallerySelection) {
                            ForEach(sortOptions, id: \.self) {
                                Text($0.displayString)
                            }
                        }
                        .pickerStyle(.menu)
                    }
            }
            .tabItem {
                Image(systemName: "square.stack.fill").padding()
                Text("Gallery")
            }
            NavigationView {
                CalendarView()
                    .navigationTitle("Calendar")
            }
            .tabItem {
                Image(systemName: "calendar")
                Text("Calendar")
            }
        }
        //.environmentObject(viewModel)
        .environment(\.managedObjectContext, viewModel.container.viewContext)
    }
}

/*
struct BottomBarView_Previews: PreviewProvider {
    static var previews: some View {
        BottomBarView()
    }
}
*/
