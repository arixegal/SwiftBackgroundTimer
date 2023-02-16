//
//  ViewModel.swift
//  SwiftBackgroundTimer
//
//  Created by Arik Segal on 16/02/2023.
//

import SwiftUI

extension ContentView {
    @MainActor
    final class ViewModel: ObservableObject {
        @Published var delayAsString: String = "5"

    }
}
