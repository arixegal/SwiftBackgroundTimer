//
//  BackgroundTimer.swift
//  SwiftBackgroundTimer
//
//  Created by Arik Segal on 10/01/2023.
//

import UIKit

final class BackgroundTimer {    
    func executeAfterDelay(delay: TimeInterval, repeating: Bool, completion: @escaping(()->Void)) {
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
    }
    
    private func wait(delay: TimeInterval, repeating: Bool, backgroundTaskId: UIBackgroundTaskIdentifier, completion: @escaping(()->Void)) {
        let startTime = Date()
        DispatchQueue.global(qos: .background).async {
            // Waiting
            while Date().timeIntervalSince(startTime) < delay {
                Thread.sleep(forTimeInterval: 0.01)
            }
            
            // Executing
            DispatchQueue.main.async { [weak self] in
                completion()
                if repeating {
                    if let self {
                        self.wait(delay: delay,
                             repeating: repeating,
                             backgroundTaskId: backgroundTaskId,
                             completion: completion
                        )
                    } else {
                        print("Failed to repeat")
                        UIApplication.shared.endBackgroundTask(backgroundTaskId) // Clearing
                    }
                } else {
                    UIApplication.shared.endBackgroundTask(backgroundTaskId) // Clearing
                }
            }
        }
    }
}
