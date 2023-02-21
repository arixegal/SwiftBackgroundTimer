//
//  ViewModel.swift
//  SwiftBackgroundTimer
//
//  Created by Arik Segal on 16/02/2023.
//

import AudioToolbox
import SwiftUI

extension ContentView {
    @MainActor
    final class ViewModel: ObservableObject {
        @Published var delayAsString: String = "5"
        @Published var shouldRepeat = false
        @Published var isInputValid = true
        private var tasks: [UIBackgroundTaskIdentifier] = []
        lazy private var timer = BackgroundTimer(delegate: self)

        private var interval: TimeInterval? {
            return TimeInterval(delayAsString)
        }

        func addTask() {
            guard let interval else {
                print("Invalid timer interval value")
                return
            }
            
            let taskID = timer.executeAfterDelay(delay: interval, repeating: shouldRepeat) {
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
            tasks += [taskID]
            // Update UI
        }
    }
}

extension ContentView.ViewModel: BackgroundTimerDelegate {
    func backgroundTimerTaskExecuted(task: UIBackgroundTaskIdentifier, willRepeat: Bool) {
        guard !willRepeat else {
            return
        }
        
        guard let row = tasks.firstIndex(of: task) else {
            return assertionFailure()
        }
        
        tasks.remove(at: row)
        // Update UI
    }
    
    func backgroundTimerTaskCanceled(task: UIBackgroundTaskIdentifier) {
    }
}
