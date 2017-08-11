//
//  CollegeStudentMeetingInfoViewController.swift
//  College App
//
//  Created by Jonathan Damico on 8/11/17.
//  Copyright © 2017 Jonathan Damico. All rights reserved.
//

import UIKit
import Firebase

class CollegeStudentMeetingInfoViewController : UIViewController {
	@IBOutlet weak var studentName: UILabel!
	@IBOutlet weak var date: UILabel!
	@IBOutlet weak var acceptButton: UIButton!
	
	var meetingUID: String? = nil
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	@IBAction func acceptButtonSelected(_ sender: Any) {
		if let meetingUID = self.meetingUID {
			let meetingRef = Database.database().reference().child("meetings").child(meetingUID)
			let userRef = Database.database().reference().child("users").child(User.current.uid).child("meetings")
			meetingRef.observeSingleEvent(of: .value, with: { (snapshot) in
				if var dict = snapshot.value as? [String:Any] {
					dict["status"] = "Confirmed"
					dict["collegeStudent"] = User.current.uid
					meetingRef.setValue(dict)
				}
			})
			userRef.observeSingleEvent(of: .value, with: { (snapshot) in
				if var arr = snapshot.value as? [String] {
					arr.append(meetingUID)
					userRef.setValue(arr)
				}
			})
			self.performSegue(withIdentifier: "unwindToCollegeStudentHomeViewController", sender: self)
		}
	}
}
