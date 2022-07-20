//
//  BottomBarView.swift
//  Today Aim
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
    @StateObject var viewModel = AimManager()
    @State private var gallerySelection = GallerySelection.all
    let sortOptions: [GallerySelection] = [.all, .accomplished, .favorited]
   
    var body: some View {
        TabView {
            NavigationView {
                TodayView(model: viewModel)
                    .navigationTitle("Today")
                    .ignoresSafeArea(.keyboard, edges: .bottom)
            }
            .tabItem {
                Image(systemName: "doc.text.image")
                Text("Today")
            }
            NavigationView {
                AimGalleryView(model: viewModel, gallerySelection: gallerySelection)
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
                CalendarTabView()
                    //.navigationTitle("Calendar")
                    .navigationBarHidden(true)
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

extension UINavigationBar {
    static func changeAppearance(clear: Bool) {
        let appearance = UINavigationBarAppearance()
        if clear {
            appearance.configureWithTransparentBackground()
        } else {
            appearance.configureWithDefaultBackground()
        }
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}

/*
struct BottomBarView_Previews: PreviewProvider {
    static var previews: some View {
        BottomBarView()
    }
}
*/
