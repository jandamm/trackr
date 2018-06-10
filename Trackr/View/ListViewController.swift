//
//  ViewController.swift
//  Trackr
//
//  Created by Jan Dammshäuser on 21.05.18.
//  Copyright © 2018 Jan Dammshäuser. All rights reserved.
//

import CoreLocation
import Overture
import UIKit

class ListViewController: UIViewController {
	private var sections: [Track.Index] = []
	private var data: [Track.Index: [Track]] = [:] {
		didSet { sections = data.keys.sorted(by: greater(^\.base)) }
	}

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
		let rawData = try SQLiteWrapper.getLocations().sorted(by: >)
		data = groupLocations(rawData)
		tableView?.reloadData()
		tableView?.refreshControl?.endRefreshing()
	}
}

extension ListViewController: UITableViewDataSource {
	func numberOfSections(in _: UITableView) -> Int {
		return sections.count
	}

	func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
		let section = sections[section]
		return data[section]?.count ?? 0
	}

	func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
		return sections[section].label
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "List.Cell", for: indexPath)

		let section = sections[indexPath.section]
		guard let sectionData = data[section] else { return cell }

		cell.textLabel?.text = String(describing: sectionData[indexPath.row])
		return cell
	}
}

extension ListViewController: UITableViewDelegate {
}
