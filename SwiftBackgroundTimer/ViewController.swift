//
//  ViewController.swift
//  SwiftBackgroundTimer
//
//  Created by Arik Segal on 10/01/2023.
//

import UIKit

final class ViewController: UIViewController {
    @IBOutlet private var textField: UITextField!
    @IBOutlet private var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.becomeFirstResponder()
    }


    @IBAction private func textFieldEditingChanged(_ sender: UITextField) {
        guard let text = sender.text,
              !text.isEmpty,
              let _ = TimeInterval(text) else {
            button.isEnabled = false
            return
        }
    }
    
    
    @IBAction private func btnTap(_ sender: UIButton) {
        print("Starting countdown")
    }
}

