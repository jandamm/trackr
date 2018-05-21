//
//  ViewController.swift
//  Trackr
//
//  Created by Jan Dammshäuser on 21.05.18.
//  Copyright © 2018 Jan Dammshäuser. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {
	let data: [String] = ["arst"]
}

extension ListViewController: UITableViewDataSource {
	func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
		return data.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "List.Cell", for: indexPath)
		cell.textLabel?.text = data[indexPath.row]
		return cell
	}
}

extension ListViewController: UITableViewDelegate {
}
