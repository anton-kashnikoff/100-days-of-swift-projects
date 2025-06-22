//
//  AppDelegate.swift
//  Project30
//
//  Created by TwoStraws on 20/08/2016.
//  Copyright (c) 2016 TwoStraws. All rights reserved.
//

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            window = UIWindow(frame: scene.screen.bounds)
        }
		
		window?.rootViewController = UINavigationController(rootViewController: SelectionViewController(style: .plain))
		window?.makeKeyAndVisible()

		return true
	}
}
