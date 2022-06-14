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
    var title: String = "Enter Today's Goal"
    var onDone: (String) -> Void = { _ in }
    var onCancel: () -> Void =  { }
    @State private var current: Int?
    @EnvironmentObject var goal: OneGoalViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            Text(title)
                .animation(.easeInOut)
            TextField("One Goal", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            HStack {
                Button("Cancel") {
                    self.isShown = false
                    self.onCancel()
                    UIApplication.shared.endEditing()
                }
                Spacer()
                Button("Done") {
                    if (!text.isEmpty) {
                        self.isShown = false
                        self.onDone(self.text)
                        self.current = 1
                        UIApplication.shared.endEditing()
                    }
                }
            }
            .padding()
        }
        .padding()
        .frame(width: screenSize.width * 0.7, height: screenSize.height * 0.2)
        
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
        NewGoalAlert(isShown: .constant(true), text: .constant(""))
    }
}
