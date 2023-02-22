//
//  ViewModel.swift
//  SwiftBackgroundTimer
//
//  Created by Arik Segal on 16/02/2023.
//

import AudioToolbox
import SwiftUI

struct TaskItem: Identifiable {
    let task: UIBackgroundTaskIdentifier
    let id = UUID()
}

extension ContentView {
    @MainActor
    final class ViewModel: ObservableObject {
        @Published var delayAsString: String = "5"
        @Published var shouldRepeat = false
        @Published var isInputValid = true
        @Published private(set) var tasks: [TaskItem] = []
        lazy private var timer = BackgroundTimer(delegate: self)

        private var interval: TimeInterval? {
            TimeInterval(delayAsString)
        }

        func addTask() {
            guard let interval else {
                print("Invalid timer interval value")
                return
            }
            
            let taskID = timer.executeAfterDelay(delay: interval, repeating: shouldRepeat) {
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
            tasks += [TaskItem(task: taskID)]
            // Update UI
        }
    }
}

extension ContentView.ViewModel: BackgroundTimerDelegate {
    func backgroundTimerTaskExecuted(task: UIBackgroundTaskIdentifier, willRepeat: Bool) {
        guard !willRepeat else {
            return
        }
        
        guard let row = tasks.firstIndex(where: {$0.task == task}) else {
            return assertionFailure()
        }
        
        tasks.remove(at: row)
        // Update UI
    }
    
    func backgroundTimerTaskCanceled(task: UIBackgroundTaskIdentifier) {
    }
}
