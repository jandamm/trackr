//
//  Notifications.swift
//  Trackr
//
//  Created by Jan Dammshäuser on 27.05.18.
//  Copyright © 2018 Jan Dammshäuser. All rights reserved.
//

import Foundation
import UserNotifications

func sendNotification(_ title: String, body: String) {
	let notificationCenter = UNUserNotificationCenter.current()
	let content = UNMutableNotificationContent()
	content.title = title
	content.body = body
	let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
	let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
	notificationCenter.add(request) { error in
		guard let error = error else { return }
		print(error)
	}
}

func requestNotificationAllowance() {
	UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
		defer { print("User has given access to notifications: \(success)") }
		guard let error = error else { return }
		print(error)
	}
}
