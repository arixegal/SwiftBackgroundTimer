//
//  ContentView.swift
//  SwiftBackgroundTimer
//
//  Created by Arik Segal on 08/02/2023.
//

import SwiftUI

struct ContentView: View {
    @State private var delayAsString: String = "5"

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

            }
            .padding(40)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
