//
//  ContentView.swift
//  SwiftBackgroundTimer
//
//  Created by Arik Segal on 08/02/2023.
//

import SwiftUI

struct ContentView: View {
    @State private var delayAsString: String = "5"
    @State private var isInputValid = true
    @FocusState private var isFocused

    var body: some View {
        VStack() {
            HStack() {
                Text("Delay in seconds:")
                
                TextField(
                    "",
                    text: $delayAsString
                )
                .padding(EdgeInsets(top: 3, leading: 3, bottom: 3, trailing: 3))
                .border(.tertiary)
                .keyboardType(.numberPad)
                .focused($isFocused)
                .onChange(of: delayAsString) { newValue in
                    isInputValid = TimeInterval(delayAsString) != nil
                }

                Button("Go") {
                    print("Button tapped!")
                }
                .disabled(isInputValid == false)
            }
            .padding(40)
        }
        .onAppear {
                isFocused = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
