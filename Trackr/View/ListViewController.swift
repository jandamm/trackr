//
//  ViewController.swift
//  Trackr
//
//  Created by Jan Dammshäuser on 21.05.18.
//  Copyright © 2018 Jan Dammshäuser. All rights reserved.
//

import CoreLocation
import MapKit
import Overture
import UIKit

class ListViewController: UIViewController {
	private var sections: [Track.Index] = []
	private var data: [Track.Index: [Track]] = [:] {
		didSet { sections = data.keys.sorted(by: greater(^\.base)) }
	}

	private var observer: NSObjectProtocol!
	private var annotations: [IndexPath: MKAnnotation] = [:]
	@IBOutlet private var mapView: MKMapView!
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
	func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
		let section = sections[indexPath.section]
		let selection = data[section]![indexPath.row]

		guard annotations[indexPath] == nil else { return }
		let annotation = MKPointAnnotation()
		annotations[indexPath] = annotation
		mapView.addAnnotation(annotation)
		annotation.coordinate = selection.location

		let camera = MKMapCamera(lookingAtCenter: selection.location, fromDistance: 200, pitch: 1, heading: 0)
		mapView.setCamera(camera, animated: true)
	}

	func tableView(_: UITableView, didDeselectRowAt indexPath: IndexPath) {
		guard let annotation = annotations[indexPath] else { return }
		mapView.removeAnnotation(annotation)
		annotations[indexPath] = nil
	}
}

extension ListViewController: MKMapViewDelegate {}
