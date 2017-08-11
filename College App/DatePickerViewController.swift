//
//  DatePickerViewController.swift
//  College App
//
//  Created by Jonathan Damico on 8/3/17.
//  Copyright © 2017 Jonathan Damico. All rights reserved.
//

import UIKit
import FSCalendar
import Firebase

class DatePickerViewController : UIViewController, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
	
	fileprivate let formatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		return formatter
	}()
	
	var selectedDates : [String] = []
	var currentSchool: School? = nil
	
	@IBOutlet weak var calendar: FSCalendar!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		calendar.dataSource = self
		calendar.delegate = self
		calendar.swipeToChooseGesture.isEnabled = true
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
		selectedDates.append(date.timeIntervalSince1970.description)
		print(selectedDates)
	}
	
	func calendar(_ calendar: FSCalendar, didDeselect date: Date) {
		for (index, element) in selectedDates.enumerated() {
			if(element == date.timeIntervalSince1970.description) {
				selectedDates.remove(at: index)
			}
		}
		print(selectedDates)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "ToFindingStudentInterstitialFromCalendarPicker" {
			let meetingUID : String = UUID().uuidString
			let meetingRef = Database.database().reference().child("meetings").child(meetingUID)
			let userRef = Database.database().reference().child("users").child(User.current.uid).child("meetings")
			let collegeRef = Database.database().reference().child("colleges").child(currentSchool!.UID).child("meetings")
			let meeting : [String : Any] = ["possibleTimes": selectedDates,
			               "college": currentSchool!.UID,
			               "prospectiveStudent": User.current.uid,
			               "status": "Proposed",
			               "collegeName": currentSchool!.name]
			meetingRef.setValue(meeting)
			userRef.observeSingleEvent(of: .value, with: { (snapshot) in
				var arr : [String]
				if let snapshot : [String] = snapshot.value as? [String] {
					arr = snapshot
				} else {
					arr = []
				}
				arr.append(meetingUID)
				userRef.setValue(arr)
			})
			collegeRef.observeSingleEvent(of: .value, with: { (snapshot) in
				var arr : [String]
				if let snapshot : [String] = snapshot.value as? [String] {
					arr = snapshot
				} else {
					arr = []
				}
				arr.append(meetingUID)
				collegeRef.setValue(arr)
			})
		}
	}
}
