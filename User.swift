//
//  User.swift
//  College App
//
//  Created by Jonathan Damico on 8/10/17.
//  Copyright © 2017 Jonathan Damico. All rights reserved.
//

import UIKit
import FirebaseDatabase.FIRDataSnapshot

class User : NSObject {
	
	let uid: String
	let college: String?
	let firstName: String
	let lastName: String
	
	private static var _current: User?
	
	static var current: User {
		// 3
		guard let currentUser = _current else {
			fatalError("Error: current user doesn't exist")
		}
		
		// 4
		return currentUser
	}
	
	static func setCurrent(_ user: User, writeToUserDefaults: Bool = false) {
		if writeToUserDefaults {
			let data = NSKeyedArchiver.archivedData(withRootObject: user)
			
			UserDefaults.standard.set(data, forKey: "currentUser")
		}
		
		_current = user
	}
	
	init(uid: String, firstName: String, lastName: String, college: String?) {
		self.uid = uid
		self.firstName = firstName
		self.lastName = lastName
		self.college = college
		super.init()
	}
	
	init?(snapshot: DataSnapshot) {
		self.uid = snapshot.key
		guard let dict = snapshot.value as? [String : Any],
			let firstName = dict["firstName"] as? String,
			let lastName = dict["lastName"] as? String
			else { return nil }
		
		self.firstName = firstName
		self.lastName = lastName
		self.college = dict["college"] as! String?
		
		super.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		guard let uid = aDecoder.decodeObject(forKey: "uid") as? String,
			let firstName = aDecoder.decodeObject(forKey: "firstName") as? String,
			let lastName = aDecoder.decodeObject(forKey: "lastName") as? String,
			let college = aDecoder.decodeObject(forKey: "college") as? String
			else { return nil }
		
		self.uid = uid
		self.firstName = firstName
		self.lastName = lastName
		if college == "nil" {
			self.college = nil
		} else {
			self.college = college
		}
		
		super.init()
	}
}

extension User: NSCoding {
	func encode(with aCoder: NSCoder) {
		aCoder.encode(uid, forKey: "uid")
		aCoder.encode(firstName, forKey: "firstName")
		aCoder.encode(lastName, forKey: "lastName")
		if let college = college {
			aCoder.encode(college, forKey: "college")
		} else {
			aCoder.encode("nil", forKey: "college")
		}
	}
}
