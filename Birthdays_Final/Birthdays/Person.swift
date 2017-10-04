//
//  Person.swift
//  Birthdays
//
//  Created by dasdom on 27.03.15.
//  Copyright (c) 2015 Dominik Hauser. All rights reserved.
//

import Foundation
import CoreData

public class Person: NSManagedObject {
  
  @NSManaged var firstName: String
  @NSManaged var lastName: String
  @NSManaged var birthday: Date
  
  var fullname: String {
    return "\(firstName) \(lastName)"
  }
}
