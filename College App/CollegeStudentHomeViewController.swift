//
//  CollegeStudentHomeViewController.swift
//  College App
//
//  Created by Jonathan Damico on 8/8/17.
//  Copyright © 2017 Jonathan Damico. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import Firebase

class CollegeStudentHomeViewController : UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
	
	var meetings : [[String : Any]] = []
	var emptyDataSetString: String = "Loading..."
	var selectedMeeting : [String : Any]? = nil
	
	@IBOutlet var meetingTableView: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
		
		tableView.delegate = self
		tableView.dataSource = self
		
		tableView.emptyDataSetSource = self
		tableView.emptyDataSetDelegate = self
		tableView.tableFooterView = UIView()
		
		let collegeMeetingRef = Database.database().reference().child("colleges").child(User.current.college!).child("meetings")
		let userMeetingRef = Database.database().reference().child("users").child(User.current.uid).child("meetings")
		let meetingRef = Database.database().reference().child("meetings")
		meetingRef.observeSingleEvent(of: .value, with: { (snapshot) in
			if let meetings = snapshot.value as? [String : Any] {
				collegeMeetingRef.observeSingleEvent(of: .value, with: { (snapshot) in
					if let arr = snapshot.value as? [String] {
						for meetingID in arr {
							var meetingConverted = meetings[meetingID] as! [String : Any]
							meetingConverted["meetingID"] = meetingID
							self.meetings.append(meetingConverted)
						}
					} else {
						self.emptyDataSetString = "No meeting requests for your school - check back later!"
					}
					self.tableView.reloadData()
				})
				userMeetingRef.observeSingleEvent(of: .value, with: { (snapshot) in
					if let arr = snapshot.value as? [String] {
						for meetingID in arr {
							self.meetings.append(meetings[meetingID] as! [String : Any])
						}
					} else {
						self.emptyDataSetString = "No meeting requests for your school - check back later!"
					}
					self.tableView.reloadData()
				})
			}
		})
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return meetings.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = meetingTableView.dequeueReusableCell(withIdentifier: "Meeting") as! CollegeStudentMeetingCell
		let meeting = meetings[indexPath.row]
		if let date = meeting["time"] as? Double {
			cell.date.text = Date(timeIntervalSince1970: date).description
			
		} else {
			if let times = meeting["possibleTimes"] as? [Double] {
				if times.count > 0 {
					cell.date.text = "Multiple Times Proposed"
				} else {
					cell.date.text = Date(timeIntervalSince1970: times[0]).description
				}
			}
			
		}
		if let status = meeting["status"] as? String {
			cell.status.text = status
			switch status {
			case "Cancelled":
				cell.status.textColor = UIColor.red
			case "Confirmed":
				cell.status.textColor = UIColor.green
			default:
				cell.status.textColor = UIColor.orange
			}
		} else {
			cell.status.text = ""
		}
		if let prospectiveStudentUID = meeting["prospectiveStudent"] as? String {
			let prospectiveStudentRef = Database.database().reference().child("users").child(prospectiveStudentUID)
			prospectiveStudentRef.observeSingleEvent(of: .value, with: { (snapshot) in
				if let data = snapshot.value as? [String:Any],
					let prospectiveStudentFirstName = data["firstName"] as? String,
					let prospectiveStudentLastName = data["lastName"] as? String {
					
					cell.name.text = prospectiveStudentFirstName + prospectiveStudentLastName
				} else {
					cell.name.text = "Pending"
				}
			})
		} else {
			cell.name.text = "Pending"
		}
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		selectedMeeting = meetings[indexPath.row]
		self.performSegue(withIdentifier: "collegeStudentMeetingMoreInfo", sender: self)
	}
	
	func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
		let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
		return NSAttributedString(string: emptyDataSetString, attributes: attrs)
	}
	
	@IBAction func unwindToCollegeStudentHomeViewController (_ segue: UIStoryboardSegue) {
		
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "collegeStudentMeetingMoreInfo" {
			if let dest = segue.destination as? CollegeStudentMeetingInfoViewController,
				let selectedMeeting = self.selectedMeeting {
				
				if let meetingUID = selectedMeeting["meetingID"] as? String {
					dest.meetingUID = meetingUID
				}
				
				var text = ""
				if let possibleTimes = selectedMeeting["possibleTimes"] as? [Double] {
					for time in possibleTimes {
						text += "\(Date(timeIntervalSince1970: time).description) "
					}
				}
				if text == "" {
					text = "Not available"
				}
				dest.date.text = text
			}
		}
	}
}
