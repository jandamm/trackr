//
//  ViewController.swift
//  Trackr
//
//  Created by Jan Dammshäuser on 21.05.18.
//  Copyright © 2018 Jan Dammshäuser. All rights reserved.
//

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

		tableView.allowsMultipleSelection = true
		mapView.showsUserLocation = true

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
		let track = sectionData[indexPath.row]

		cell.textLabel?.text = String(describing: track)
		switch track.source {
		case .change:
			cell.backgroundColor = .white
		default:
			cell.backgroundColor = .lightGray
		}
		return cell
	}
}

extension ListViewController: UITableViewDelegate {
	func tableView(_: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let section = sections[indexPath.section]
		guard var data = self.data[section] else { return nil }

		let track = data[indexPath.row]
		let action: (UITableViewRowAction, IndexPath) -> Void = { _, _ in
			guard (try? SQLiteWrapper.remove(track)) != nil else { return }
			data.remove(at: indexPath.row)
			if data.isEmpty {
				self.data[section] = nil
				self.sections.remove(at: indexPath.section)
			} else {
				self.data[section] = data
			}
			self.tableView(self.tableView, didDeselectRowAt: indexPath)
			self.tableView.reloadSections(IndexSet(integer: indexPath.section), with: .fade)
		}
		return [UITableViewRowAction(style: .destructive, title: "Delete", handler: action)]
	}

	func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
		let section = sections[indexPath.section]
		let selection = data[section]![indexPath.row]

		guard annotations[indexPath] == nil else { return }
		let annotation = MKPointAnnotation()
		annotations[indexPath] = annotation
		mapView.addAnnotation(annotation)
		annotation.coordinate = selection.location

		setCamera()
	}

	func tableView(_: UITableView, didDeselectRowAt indexPath: IndexPath) {
		guard let annotation = annotations[indexPath] else { return }
		mapView.removeAnnotation(annotation)
		annotations[indexPath] = nil

		setCamera()
	}

	private func setCamera() {
		let annotations = mapView.annotations.filter(!isA(MKUserLocation.self))

		guard !annotations.isEmpty else {
			setRegion(to: mapView?.userLocation.coordinate)
			return
		}

		var minLat: Double = 90
		var minLon: Double = 180
		var maxLat: Double = -90
		var maxLon: Double = -180

		for annotation in annotations {
			let coordinate = annotation.coordinate
			if coordinate.latitude < minLat { minLat = coordinate.latitude }
			if coordinate.latitude > maxLat { maxLat = coordinate.latitude }
			if coordinate.longitude < minLon { minLon = coordinate.longitude }
			if coordinate.longitude > maxLon { maxLon = coordinate.longitude }
		}

		let deltaLat = maxLat - minLat
		let deltaLon = maxLon - minLon

		let center = Coordinate(latitude: minLat + deltaLat / 2, longitude: minLon + deltaLon / 2)
		setRegion(to: center, deltaLat: deltaLat, deltaLon: deltaLon)
	}

	private func setRegion(to center: Coordinate?, deltaLat: Double = 0.1, deltaLon: Double = 0.1) {
		guard let center = center else { return }

		let span = MKCoordinateSpan(latitudeDelta: deltaLat * 1.3, longitudeDelta: deltaLon * 1.3)
		let region = MKCoordinateRegion(center: center, span: span)

		mapView.setRegion(region, animated: true)
	}
}

extension ListViewController: MKMapViewDelegate {}
