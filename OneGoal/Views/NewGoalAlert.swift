//
//  NewGoalAlert.swift
//  OneGoal
//
//  Created by Alec Frey on 6/6/22.
//

import SwiftUI

struct NewGoalAlert: View {
    let screenSize = UIScreen.main.bounds
    @Binding var isShown: Bool
    @Binding var text: String
    var title: String
    var onDone: (String) -> Void = { _ in }
    var onCancel: () -> Void =  { }
    @State private var current: Int?
    @EnvironmentObject var goal: GoalManager
    @Environment(\.colorScheme) var colorScheme
    //@FocusState var keyboardFocused: Bool
    
    enum FocusField: Hashable {
        case field
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .animation(.easeInOut)
            TextField("Go to the gym…", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                //.focused($keyboardFocused)
                .keyboardType(.alphabet)
               // .disableAutocorrection(true)
            HStack {
                Button("Cancel") {
                    self.isShown = false
                    self.onCancel()
                    UIApplication.shared.endEditing()
                }
                Spacer()
                Button {
                    if (!text.trimmingCharacters(in: .whitespaces).isEmpty ) {
                        self.isShown = false
                        self.onDone(self.text)
                        self.current = 1
                        UIApplication.shared.endEditing()
                    } else {
                        text = text.trimmingCharacters(in: .whitespaces)
                    }
                } label: {
                    Text("Done")
                        .fontWeight(.semibold)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 2)
        }
        .padding()
        .frame(width: screenSize.width * 0.7)
        .background(colorScheme == .light ? .white : .black)
        .clipShape(RoundedRectangle(cornerRadius: 20.0, style: .continuous))
        .offset(y: isShown ? 0 : screenSize.height)
        .animation(.spring())
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct NewGoalAlert_Previews: PreviewProvider {
    static var previews: some View {
        NewGoalAlert(isShown: .constant(true), text: .constant(""), title: "Title")
    }
}
