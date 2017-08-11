//
//  CollegeSearchTableViewController.swift
//  College App
//
//  Created by Jonathan Damico on 8/2/17.
//  Copyright © 2017 Jonathan Damico. All rights reserved.
//

import UIKit

class CollegeSearchTableViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
	@IBOutlet weak var collegeSearchBar: UISearchBar!
	@IBOutlet weak var collegeSearchResultsTableView: UITableView!

	
	var searchActive : Bool = false
	var schools: [School] = []
	var filtered: [School] = []
	var currentSchool: School? = nil
	
	var destinationIsAccountSetup = false
	
	override func viewDidLoad() {
		super.viewDidLoad();
		
		collegeSearchBar.scopeButtonTitles = nil
		
		collegeSearchBar.delegate = self
		
		collegeSearchResultsTableView.delegate = self
		collegeSearchResultsTableView.dataSource = self
		
		
		initCollegeList(filename: "DC_InstGroup_731402")
	}
	
	func initCollegeList(filename: String) {
		let path = Bundle.main.path(forResource: filename, ofType: "uid")
		do {
			let fileContent = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
			let rows = fileContent.components(separatedBy: "\r\n")
			schools = Array(repeating: School(), count: rows.count-1)
			for (i, row) in rows.enumerated() {
				if(i>=rows.count-1) {
					break
				}
				var cols = row.components(separatedBy: "|")
				schools[i] = School(UID: cols[0], name: cols[1], city: cols[2], state: cols[3])
			}
			collegeSearchResultsTableView.reloadData();
		} catch let error as NSError {
			print("\(error)")
		}
	}
	
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		searchActive = true
	}
	
	func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
		searchActive = false
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchActive = false
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		
		filtered = schools.filter({ (school) -> Bool in
			let tmp: NSString = school.name as NSString
			let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
			return range.location != NSNotFound
		})
		if(filtered.count == 0){
			searchActive = false
		} else {
			searchActive = true
		}
		collegeSearchResultsTableView.reloadData()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if(searchActive) {
			return filtered.count
		}
		return schools.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = collegeSearchResultsTableView.dequeueReusableCell(withIdentifier: "College") as! CollegeSearchTableViewCell
		if(filtered.count > 0){
			cell.collegeNameLabel.text = filtered[indexPath.row].name
			cell.collegeLocationLabel.text = "\(filtered[indexPath.row].city), \(filtered[indexPath.row].state)"
		} else {
			cell.collegeNameLabel.text = schools[indexPath.row].name
			cell.collegeLocationLabel.text = "\(schools[indexPath.row].city), \(schools[indexPath.row].state)"
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if filtered.count == 0 {
			currentSchool = schools[indexPath.row]
		} else {
			currentSchool = filtered[indexPath.row]
		}
		
		searchActive = false;
		
		if destinationIsAccountSetup {
			self.performSegue(withIdentifier:
				"unwindToProfileSetupController", sender: self)
		} else {
			self.performSegue(withIdentifier: "unwindToProspectiveStudentHomeViewController", sender: self)
		}
		
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "unwindToProfileSetupController" {
			let profileSetupViewController = segue.destination as! ProfileSetupController
			profileSetupViewController.currentSchool = currentSchool;
		} else {
			let displayNoteViewController = segue.destination as! ProspectiveStudentHomeViewController
			displayNoteViewController.currentSchool = currentSchool;
		}
	}
	
}
