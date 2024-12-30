//
//  ViewController.swift
//  Project21
//
//  Created by Антон Кашников on 15/06/2024.
//

import UserNotifications
import UIKit

final class ViewController: UIViewController {
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Register",
            style: .plain,
            target: self,
            action: #selector(registerLocal)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Schedule",
            style: .plain,
            target: self,
            action: #selector(initialSchedule)
        )
    }
    
    // MARK: - Private Methods
    
    private func registerCategories() {
        let userNotificationCenter = UNUserNotificationCenter.current()
        userNotificationCenter.delegate = self
        userNotificationCenter.setNotificationCategories(
            [
                .init(
                    identifier: "alarm",
                    actions: [
                        .init(
                            identifier: "show",
                            title: "Tell me more…",
                            options: .foreground
                        ),
                        .init(
                            identifier: "later",
                            title: "Remind me later",
                            options: .foreground
                        )
                    ],
                    intentIdentifiers: []
                )
            ]
        )
    }
    
    @objc private func registerLocal() {
        let userNotificationCenter = UNUserNotificationCenter.current()
        
        userNotificationCenter.requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, _ in
            print(granted ? "Yay!" : "D'oh")
        }
    }
    
    @objc private func initialSchedule() {
        scheduleLocal()
    }
    
    private func scheduleLocal(in timeInterval: TimeInterval = 5) {
        registerCategories()
        
        let userNotificationCenter = UNUserNotificationCenter.current()
        userNotificationCenter.removeAllPendingNotificationRequests()
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Title goes here"
        notificationContent.body = "Main text goes here"
        notificationContent.categoryIdentifier = "alarm"
        notificationContent.userInfo = ["customData": "fizzbuzz"]
        notificationContent.sound = .default
        
        userNotificationCenter.add(
            .init(
                identifier: UUID().uuidString,
                content: notificationContent,
                trigger: UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
            )
        )
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension ViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if
            let customData = response.notification.request.content.userInfo["customData"] as? String
        {
            print("Custom data received: \(customData)")
            
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                // the user swiped to unlock
                let alertController = UIAlertController(
                    title: "Default identifier",
                    message: "The user swiped to unlock",
                    preferredStyle: .alert
                )
                alertController.addAction(.init(title: "OK", style: .default))
                present(alertController, animated: true)
            case "show":
                // the user tapped our "show more info…" button
                let alertController = UIAlertController(
                    title: "Show more information…",
                    message: "The user tapped \"Show more info…\" button",
                    preferredStyle: .alert
                )
                alertController.addAction(.init(title: "OK", style: .default))
                present(alertController, animated: true)
            case "later":
                scheduleLocal(in: 86_400) // remind me in 24h
            default: break
            }
        }
        
        completionHandler() // you must call the completion handler when you're done
    }
}
