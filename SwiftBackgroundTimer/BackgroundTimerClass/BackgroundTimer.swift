//
//  BackgroundTimer.swift
//  SwiftBackgroundTimer
//
//  Created by Arik Segal on 10/01/2023.
//

import UIKit

protocol BackgroundTimerDelegate: AnyObject {
    func backgroundTimerTaskExecuted(task: UIBackgroundTaskIdentifier, willRepeat: Bool)
    func backgroundTimerTaskCanceled(task: UIBackgroundTaskIdentifier)
}

final class BackgroundTimer {    
    weak var delegate: BackgroundTimerDelegate?
    private var tasksToCancel: Set<UIBackgroundTaskIdentifier> = [] // To do: thread safety, will think about it later
    
    init(delegate: BackgroundTimerDelegate?) {
        self.delegate = delegate
    }
    
    func executeAfterDelay(delay: TimeInterval, repeating: Bool, completion: @escaping(()->Void)) -> UIBackgroundTaskIdentifier {
        var backgroundTaskId = UIBackgroundTaskIdentifier.invalid
        backgroundTaskId = UIApplication.shared.beginBackgroundTask {
            UIApplication.shared.endBackgroundTask(backgroundTaskId) // The expiration Handler
        }
        
        // -- The task itself: Wait and then execute --
        wait(delay: delay,
             repeating: repeating,
             backgroundTaskId: backgroundTaskId,
             completion: completion
        )
        return backgroundTaskId
    }
    
    func cancelExecution(tasks: [UIBackgroundTaskIdentifier]) {
        tasks.forEach {
            tasksToCancel.insert($0)
        }
    }
    
    private func wait(delay: TimeInterval, repeating: Bool, backgroundTaskId: UIBackgroundTaskIdentifier, completion: @escaping(()->Void)) {
        guard !tasksToCancel.contains(backgroundTaskId) else {
            print("Aborting task \(backgroundTaskId)")
            delegate?.backgroundTimerTaskCanceled(task: backgroundTaskId)
            return
        }

        let startTime = Date()

        DispatchQueue.global(qos: .background).async {
            // Waiting
            while Date().timeIntervalSince(startTime) < delay {
                Thread.sleep(forTimeInterval: 0.1)
            }
            
            // Executing
            DispatchQueue.main.async { [weak self] in
                let tasksToCancel = self?.tasksToCancel ?? []
                guard !tasksToCancel.contains(backgroundTaskId) else {
                    print("Aborting task \(backgroundTaskId)")
                    UIApplication.shared.endBackgroundTask(backgroundTaskId) // Clearing
                    self?.delegate?.backgroundTimerTaskCanceled(task: backgroundTaskId)
                    return
                }

                completion()
                self?.delegate?.backgroundTimerTaskExecuted(task: backgroundTaskId, willRepeat: repeating)
                if repeating {
                    if let self {
                        self.wait(delay: delay,
                             repeating: repeating,
                             backgroundTaskId: backgroundTaskId,
                             completion: completion
                        )
                    } else {
                        print("Failed to repeat, most probably because the BackgroundTimer instance is de-allocated. Make sure you keep a reference to the BackgroundTimer instance in memory.")
                        UIApplication.shared.endBackgroundTask(backgroundTaskId) // Clearing
                    }
                } else {
                    UIApplication.shared.endBackgroundTask(backgroundTaskId) // Clearing
                }
            }
        }
    }
}
