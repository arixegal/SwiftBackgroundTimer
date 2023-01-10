//
//  ViewController.swift
//  SwiftBackgroundTimer
//
//  Created by Arik Segal on 10/01/2023.
//

import AudioToolbox
import UIKit

final class ViewController: UIViewController {
    @IBOutlet private var textField: UITextField!
    @IBOutlet private var button: UIButton!
    
    var interval: TimeInterval? {
        guard let text = textField.text,
              !text.isEmpty else {
            return nil
        }
        return TimeInterval(text)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.becomeFirstResponder()
    }


    @IBAction private func textFieldEditingChanged(_ sender: UITextField) {
            button.isEnabled = interval != nil
    }
    
    
    @IBAction private func btnTap(_ sender: UIButton) {
        guard let interval else {
            print("Invalid timer value")
            return
        }
        print("Starting \(interval) seconds countdown.")
        BackgroundTimer().executeAfterDelay(delay: interval) {
            print("\(interval) seconds have passed, executing code block.")
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
}

