//
//  BackgroundTimer.swift
//  SwiftBackgroundTimer
//
//  Created by Arik Segal on 10/01/2023.
//

import UIKit

final class BackgroundTimer {    
    func executeAfterDelay(delay: TimeInterval, completion: @escaping(()->Void)){
        var backgroundTaskId = UIBackgroundTaskIdentifier.invalid
        backgroundTaskId = UIApplication.shared.beginBackgroundTask {
            UIApplication.shared.endBackgroundTask(backgroundTaskId) // The expiration Handler
        }
        
        // -- The task itself: Wait and then execute --
        
        let startTime = Date()
        DispatchQueue.global(qos: .background).async {
            // Waiting
            while Date().timeIntervalSince(startTime) < delay {
                Thread.sleep(forTimeInterval: 0.01)
            }
            
            // Executing
            DispatchQueue.main.async {
                completion()
                UIApplication.shared.endBackgroundTask(backgroundTaskId) // Clearing
            }
        }
    }
}
