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
    @IBOutlet private var repeatingSwitch: UISwitch!
    @IBOutlet private var constTVHeight: NSLayoutConstraint!
    @IBOutlet private var tableView: UITableView!
    
    private var tasks: [UIBackgroundTaskIdentifier] = []
    private lazy var timer = BackgroundTimer(delegate: self)
    private var interval: TimeInterval? {
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

    override func viewWillLayoutSubviews() {
        constTVHeight.constant = tableView.contentSize.height
        super.viewWillLayoutSubviews()
    }
    
    @IBAction private func textFieldEditingChanged(_ sender: UITextField) {
            button.isEnabled = interval != nil
    }
    
    
    @IBAction private func btnTap(_ sender: UIButton) {
        guard let interval else {
            print("Invalid timer interval value")
            return
        }
        
        let taskID = timer.executeAfterDelay(delay: interval, repeating: repeatingSwitch.isOn) {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
        tasks += [taskID]
        tableView.performBatchUpdates {
            tableView.insertRows(
                at: [IndexPath(row: tableView.numberOfRows(inSection: 0), section: 0)],
                with: .automatic
            )
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        timer.cancelExecution(tasks: [tasks[indexPath.row]])
        tasks.remove(at: indexPath.row)
        tableView.performBatchUpdates {
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        return nil
    }
}

extension ViewController: BackgroundTimerDelegate {
    func backgroundTimerTaskExecuted(task: UIBackgroundTaskIdentifier, willRepeat: Bool) {
        guard !willRepeat else {
            return
        }
        
        guard let row = tasks.firstIndex(of: task) else {
            return assertionFailure()
        }
        
        tasks.remove(at: row)
        tableView.performBatchUpdates {
            tableView.deleteRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
        }
    }
    
    func backgroundTimerTaskCanceled(task: UIBackgroundTaskIdentifier) {
    }
}
