//
//  ProspectiveStudentHomeViewController.swift
//  College App
//
//  Created by Jonathan Damico on 7/31/17.
//  Copyright © 2017 Jonathan Damico. All rights reserved.
//

import GoogleMaps
import GooglePlaces

class ProspectiveStudentHomeViewController : UIViewController {
	
	@IBOutlet weak var googleMapsView: GMSMapView!
	@IBOutlet weak var currentCollegeNameLabel: UILabel!
	@IBOutlet weak var currentCollegeLocationLabel: UILabel!
	@IBOutlet weak var currentCollegeView: UIView!
	@IBOutlet weak var bookAMeetingButton: UIButton!
	
	var currentSchool : School? = nil
	
	var placesClient : GMSPlacesClient?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		placesClient = GMSPlacesClient.shared()
		
		initGoogleMap()
		
		bookAMeetingButton.isHidden = true
		currentCollegeLocationLabel.isHidden = true
		currentCollegeNameLabel.text = "Tap to Search for a College"
		
		let currentCollegeViewGesture = UITapGestureRecognizer(target: self, action: #selector (self.segueToCollegeTableView (_:)))
		
		self.currentCollegeView.addGestureRecognizer(currentCollegeViewGesture)
		
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	func initGoogleMap() {
		let camera = GMSCameraPosition.camera(withLatitude: 39.8283, longitude: -98.5795, zoom: 3.0)
		googleMapsView.camera = camera
		googleMapsView.isIndoorEnabled = true
	}
	
	func segueToCollegeTableView (_ sender:UITapGestureRecognizer) {
		self.performSegue(withIdentifier: "Search", sender: self)
	}
	
	override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
		if identifier == "PickDateAndTime" {
			if let _ = currentSchool {
				return true
			} else {
				return false
			}
		} else {
			return true
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)
		if segue.identifier == "PickDateAndTime" {
			let destination = segue.destination as! DatePickerViewController
			if let currentSchool = currentSchool {
				destination.currentSchool = currentSchool
			}
		}
	}
	
	@IBAction func unwindToProspectiveStudentHomeViewController(_ segue: UIStoryboardSegue) {
		if segue.identifier == "unwindToProspectiveStudentHomeViewController" {
			if let school = currentSchool {
				
				let neBoundsCorner = CLLocationCoordinate2D(latitude: 49.774170,
				                                            longitude: -52.734375)
				let swBoundsCorner = CLLocationCoordinate2D(latitude: 13.020614,
				                                            longitude: -168.574219)
				let bounds = GMSCoordinateBounds(coordinate: neBoundsCorner,
				                                 coordinate: swBoundsCorner)
				
				let filter = GMSAutocompleteFilter()
				filter.type = GMSPlacesAutocompleteTypeFilter.noFilter
				
				
				let placename = "\(school.name), \(school.city), \(school.state)"
				if let placesClient = self.placesClient {
					placesClient.autocompleteQuery(placename, bounds: bounds, filter: filter) { (results, error) in
						if let error = error {
							print(error)
						} else if let results = results {
							if results.count == 0 {
								let camera = GMSCameraPosition.camera(withLatitude: 39.8283, longitude: -98.5795, zoom: 3.0)
								self.googleMapsView.camera = camera
							} else {
								placesClient.lookUpPlaceID(results[0].placeID!, callback: { (place: GMSPlace?, error: Error?) in
									if let error = error {
										print(error)
									} else if let place = place {
										let marker = GMSMarker()
										marker.position = place.coordinate
										marker.title = place.name
										marker.map = self.googleMapsView
										
										let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 14.0)
										
										self.googleMapsView.camera = camera
									}
								})
							}
						}
					}
				}
				
				currentCollegeNameLabel.text = school.name
				currentCollegeLocationLabel.text = "\(school.city), \(school.state)"
				currentCollegeLocationLabel.isHidden = false
				bookAMeetingButton.isHidden = false
			}
		}
	}
}
