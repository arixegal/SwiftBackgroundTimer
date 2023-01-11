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
    lazy private var tasksToCancel: Set<UIBackgroundTaskIdentifier> = [] // All access to this set should be on timerQueue
    
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
        DispatchQueue.performOnTimerQueue { [weak self] in
            if var tasksToCancel = self?.tasksToCancel {
                tasks.forEach {
                    tasksToCancel.insert($0)
                }
            }
        }
    }
    
    private func wait(delay: TimeInterval, repeating: Bool, backgroundTaskId: UIBackgroundTaskIdentifier, completion: @escaping(()->Void)) {
        let startTime = Date()
        
        DispatchQueue.performOnTimerQueue { [weak self] in
            // Waiting
            while Date().timeIntervalSince(startTime) < delay {
                Thread.sleep(forTimeInterval: 0.1)
                if var tasksToCancel = self?.tasksToCancel {
                    if tasksToCancel.contains(backgroundTaskId) {
                        print("Aborting task \(backgroundTaskId)")
                        // To do: remove task from tasksToCancel after is is canceled
                        DispatchQueue.main.async { [weak self] in
                            self?.delegate?.backgroundTimerTaskCanceled(task: backgroundTaskId)
                        }
                        return
                    }
                }
            }
            
            // Executing
            DispatchQueue.main.async { [weak self] in
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

extension DispatchQueue {
    private static let timerQueue = DispatchQueue(label: "BackgroundTimerCancelationQueue", attributes: .concurrent)
    
    static func performOnTimerQueue(work: @escaping @convention(block) () -> Void) {
        DispatchQueue.timerQueue.async(flags: .barrier, execute: work)
    }
}
