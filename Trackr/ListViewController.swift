//
//  ViewController.swift
//  Trackr
//
//  Created by Jan Dammshäuser on 21.05.18.
//  Copyright © 2018 Jan Dammshäuser. All rights reserved.
//

import CoreLocation
import UIKit

class ListViewController: UIViewController {
	var data: [Location] = []

	@IBOutlet private var tableView: UITableView!

	override func viewDidLoad() {
		super.viewDidLoad()

		let c = CLLocationCoordinate2D(latitude: 199, longitude: 22)
		let l = Location(date: Date(), location: c)
		do {
			try SQLiteWrapper.add(l)
		} catch {
			print(error)
		}

		DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
			do {
				self.data = try SQLiteWrapper.getLocations()
				self.tableView.reloadData()
			} catch {
				print(error)
			}
		}
	}
}

extension ListViewController: UITableViewDataSource {
	func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
		return data.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "List.Cell", for: indexPath)
		cell.textLabel?.text = String(describing: data[indexPath.row])
		return cell
	}
}

extension ListViewController: UITableViewDelegate {
}
