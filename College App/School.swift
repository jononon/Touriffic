//
//  School.swift
//  College App
//
//  Created by Jonathan Damico on 7/31/17.
//  Copyright © 2017 Jonathan Damico. All rights reserved.
//

class School {
	var UID : String
	var name : String
	var city : String
	var state : String
	
	init(UID: String, name: String, city: String, state: String) {
		self.UID = UID
		self.name = name
		self.city = city
		self.state = state
	}
	
	convenience init() {
		self.init(UID: "", name: "", city: "", state: "")
	}
}
