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
    private var tasksToCancel: Set<UIBackgroundTaskIdentifier> = [] // Not thread safe, access with care
    
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
        guard Thread.isMainThread else {
            return assertionFailure()
        }
        
        tasks.forEach {
            tasksToCancel.insert($0)
        }
    }
    
    private func wait(delay: TimeInterval, repeating: Bool, backgroundTaskId: UIBackgroundTaskIdentifier, completion: @escaping(()->Void)) {
        guard Thread.isMainThread else {
            return assertionFailure()
        }

        guard !tasksToCancel.contains(backgroundTaskId) else {
            return cancel(backgroundTaskId: backgroundTaskId)
        }

        let startTime = Date()

        DispatchQueue.global(qos: .background).async { [weak self] in
            // Waiting
            while Date().timeIntervalSince(startTime) < delay {
                Thread.sleep(forTimeInterval: 0.1)
            }
            
            // Executing
            DispatchQueue.main.async { [weak self] in
                guard !(self?.tasksToCancel ?? []).contains(backgroundTaskId) else {
                    self?.cancel(backgroundTaskId: backgroundTaskId)
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
    
    private func cancel(backgroundTaskId: UIBackgroundTaskIdentifier) {
        guard Thread.isMainThread else {
            return assertionFailure()
        }
        print("Aborting task \(backgroundTaskId)")
        UIApplication.shared.endBackgroundTask(backgroundTaskId)
        delegate?.backgroundTimerTaskCanceled(task: backgroundTaskId)
        tasksToCancel.remove(backgroundTaskId)
    }
}
