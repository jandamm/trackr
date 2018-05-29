//
//  AppDelegate.swift
//  Trackr
//
//  Created by Jan Dammshäuser on 21.05.18.
//  Copyright © 2018 Jan Dammshäuser. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?

	func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.

		try! SQLiteWrapper.setup()
		LocationManager.shared.start()
		requestNotificationAllowance()

		resetNotifications()

		addLocations()
		showErrors()

		return true
	}

	func applicationWillResignActive(_: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
		reloadTable()
	}

	func applicationWillTerminate(_: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}

	private func reloadTable() {
		guard let list = window?.rootViewController as? ListViewController else { return }
		try? list.reloadData()
	}

	private func addLocations() {
		do {
			try Defaults.getLocations()
				.forEach(SQLiteWrapper.add)
			Defaults.deleteLocations()
			reloadTable()
		} catch {
			print(error)
		}
	}

	private func showErrors() {
		let errors = Defaults.getErrors()

		guard errors.count > 0 else { return }
		let message = errors
			.map(String.init(describing:))
			.joined(separator: "\n")

		let alert = UIAlertController(title: "There have been errors:", message: message, preferredStyle: .alert)
		let action = UIAlertAction(title: "Ok", style: .default, handler: match(Defaults.deleteErrors))
		alert.addAction(action)
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
			guard let `self` = self else { return }
			self.window?.rootViewController?.present(alert, animated: true, completion: nil)
		}
	}
}
