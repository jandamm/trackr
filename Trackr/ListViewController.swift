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
	private var data: [Location] = []

	private var observer: NSObjectProtocol!
	@IBOutlet private var tableView: UITableView!

	override func viewDidLoad() {
		super.viewDidLoad()

		let refreshControl = UIRefreshControl(frame: .zero)
		refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
		tableView.refreshControl = refreshControl

		observer = NotificationCenter.default.addObserver(forName: NSNotification.Name("Update"), object: nil, queue: .main, using: { [unowned self] _ in
			try? self.reloadData()
		})

		do {
			try reloadData()
		} catch {
			print(error)
		}
	}

	@objc func reloadData() throws {
		data = try SQLiteWrapper.getLocations().sorted(by: >)
		tableView?.reloadData()
		tableView?.refreshControl?.endRefreshing()
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
