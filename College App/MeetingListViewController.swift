//
//  MeetingListViewController.swift
//  College App
//
//  Created by Jonathan Damico on 8/4/17.
//  Copyright © 2017 Jonathan Damico. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import Firebase

class MeetingListViewController : UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
	
	@IBOutlet var meetingTableView: UITableView!
	
	var meetings : [[String : Any]] = []
	var schools: [String:School] = [:]
	var emptyDataSetString: String = "Loading..."
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		initCollegeDict(filename: "DC_InstGroup_731402")
		
		tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
		
		tableView.delegate = self
		tableView.dataSource = self
		
		tableView.emptyDataSetSource = self
		tableView.emptyDataSetDelegate = self
		tableView.tableFooterView = UIView()
		
		let userMeetingRef = Database.database().reference().child("users").child(User.current.uid).child("meetings")
		let meetingRef = Database.database().reference().child("meetings")
		meetingRef.observeSingleEvent(of: .value, with: { (snapshot) in
			if let meetings = snapshot.value as? [String : Any] {
				userMeetingRef.observeSingleEvent(of: .value, with: { (snapshot) in
					if let arr = snapshot.value as? [String] {
						for meetingID in arr {
							self.meetings.append(meetings[meetingID] as! [String : Any])
						}
					} else {
						self.emptyDataSetString = "No meetings scheduled."
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
		let cell = meetingTableView.dequeueReusableCell(withIdentifier: "Meeting") as! MeetingCell
		let meeting = meetings[indexPath.row]
		if let collegeUID = meeting["college"] as? String {
			cell.collegeName.text = schools[collegeUID]?.name
		} else {
			cell.collegeName.text = ""
		}
		if let date = meeting["time"] as? Double {
			cell.date.text = Date(timeIntervalSince1970: date).description
			
		} else {
			cell.date.text = "Pending"
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
		if let collegeStudentUID = meeting["collegeStudent"] as? String {
			let collegeStudentRef = Database.database().reference().child("users").child(collegeStudentUID)
			collegeStudentRef.observeSingleEvent(of: .value, with: { (snapshot) in
				if let data = snapshot.value as? [String:Any],
					let collegeStudentFirstName = data["firstName"] as? String,
					let collegeStudentLastName = data["lastName"] as? String {
					
					cell.studentName.text = collegeStudentFirstName + collegeStudentLastName
				} else {
					cell.studentName.text = "Pending"
				}
			})
		} else {
			cell.studentName.text = "Pending"
		}
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
	}
	
	func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
		let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
		return NSAttributedString(string: emptyDataSetString, attributes: attrs)
	}
	
	func initCollegeDict(filename: String) {
		let path = Bundle.main.path(forResource: filename, ofType: "uid")
		do {
			let fileContent = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
			let rows = fileContent.components(separatedBy: "\r\n")
			for (i, row) in rows.enumerated() {
				if(i>=rows.count-1) {
					break
				}
				var cols = row.components(separatedBy: "|")
				schools[cols[0]] = School(UID: cols[0], name: cols[1], city: cols[2], state: cols[3])
			}
		} catch let error as NSError {
			print("\(error)")
		}
	}
}
