//
//  PeopleListDataProviderTests.swift
//  BirthdaysTests
//
//  Created by Alexander Spirichev on 03/10/2017.
//  Copyright © 2017 Dominik Hauser. All rights reserved.
//

import XCTest
import Birthdays
import CoreData

class PeopleListDataProviderTests: XCTestCase {

	var storeCoordinator: NSPersistentStoreCoordinator!
	var managedObjectContext: NSManagedObjectContext!
	var managedObjectModel: NSManagedObjectModel!
	var store: NSPersistentStore!

	var dataProvider: PeopleListDataProvider!
	var tableView: UITableView!
	var testRecord: PersonInfo!

	override func setUp() {
		super.setUp()

		managedObjectModel = NSManagedObjectModel.mergedModel(from: nil)
		storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)

		do {
			try store = storeCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
		} catch let error {
			print(error)
		}

		managedObjectContext = NSManagedObjectContext()
		managedObjectContext.persistentStoreCoordinator = storeCoordinator

		dataProvider = PeopleListDataProvider()
		dataProvider.managedObjectContext = managedObjectContext

		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let viewController = storyboard.instantiateViewController(withIdentifier: "PeopleListViewController") as! PeopleListViewController
		viewController.dataProvider = dataProvider
		tableView = viewController.tableView
		testRecord = PersonInfo(firstName: "TestFirstName", lastName: "TestLastName", birthday: Date())
	}
    
	override func tearDown() {
		managedObjectContext = nil

		do {
			try storeCoordinator.remove(store)
		} catch let error {
			XCTAssertTrue(error.localizedDescription != "", "couldn't remove persistent store: \(error)")
		}

		super.tearDown()
	}

	func testThatStoreIsSetUp() {
		XCTAssertNotNil(store, "no persistent store")
	}

	func testOnePersonInThePersistantStoreResultsInOneRow() {
		dataProvider.addPerson(testRecord)

		XCTAssertEqual(tableView.dataSource?.tableView(tableView, numberOfRowsInSection: 0), 1, "After adding one person number of rows is not 1")
	}
    
}
