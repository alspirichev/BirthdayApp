//
//  PeopleListViewControllerTests.swift
//  BirthdaysTests
//
//  Created by Alexander Spirichev on 03/10/2017.
//  Copyright © 2017 Dominik Hauser. All rights reserved.
//

import XCTest
@testable import Birthdays
import CoreData
import AddressBookUI

class PeopleListViewControllerTests: XCTestCase {

	var viewController: PeopleListViewController!

	override func setUp() {
		super.setUp()

		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		viewController = storyboard.instantiateViewController(withIdentifier: "PeopleListViewController") as! PeopleListViewController
	}
    
	override func tearDown() {
			// Put teardown code here. This method is called after the invocation of each test method in the class.
			super.tearDown()
	}

	func testDataProviderHasTableViewPropertySetAfterLoading() {
		// given
		let mockDataProvider = MockDataProvider()
		viewController.dataProvider = mockDataProvider

		// when
		XCTAssertNil(mockDataProvider.tableView, "Before loading the table view should be nil")

		let _ = viewController.view

		// then
		XCTAssertTrue(mockDataProvider.tableView != nil, "The table view should be set")
		XCTAssert(mockDataProvider.tableView === viewController.tableView, "The table view should be set to the table view of the data source")
	}

	func testCallsAddPersonOfThePeopleDataSourceAfterAddingAPersion() {
		// given
		let mockDataProvider = MockDataProvider()
		viewController.dataProvider = mockDataProvider

		// when
		let record: ABRecord = ABPersonCreate().takeRetainedValue()
		ABRecordSetValue(record, kABPersonFirstNameProperty, "TestFirstname" as CFTypeRef, nil)
		ABRecordSetValue(record, kABPersonLastNameProperty, "TestLastname" as CFTypeRef, nil)
		ABRecordSetValue(record, kABPersonBirthdayProperty, Date() as CFTypeRef, nil)

		viewController.peoplePickerNavigationController(ABPeoplePickerNavigationController(), didSelectPerson: record)

		// then
		XCTAssert(mockDataProvider.addPersonGotCalled, "addPerson should have been called")
	}

	func testSortingCanBeChanged() {
		// given
		let mockUserDefaults = MockUserDefaults(suiteName: "testing")!
		viewController.userDefaults = mockUserDefaults

		// when
		let segmentedControl = UISegmentedControl()
		segmentedControl.selectedSegmentIndex = 0
		segmentedControl.addTarget(viewController, action: #selector(viewController.changeSorting(_:)), for: .valueChanged)
		segmentedControl.sendActions(for: .valueChanged)

		// then
		XCTAssertTrue(mockUserDefaults.sortWasChanged, "Sort value in user defaults should be altered")
	}

	func testFetchingPeopleFromAPICallsAddPeople() {
		// given
		let mockDataProvider = MockDataProvider()
		viewController.dataProvider = mockDataProvider

		let mockCommunicator = MockAPICommunicator()
		mockCommunicator.allPersonInfo = [PersonInfo(firstName: "firstname", lastName: "lastname", birthday: Date())]
		viewController.communicator = mockCommunicator

		// when
		viewController.fetchPeopleFromAPI()

		// then
		XCTAssert(mockDataProvider.addPersonGotCalled, "addPerson should have been called")
	}
    
}

class MockAPICommunicator: APICommunicatorProtocol {
	var allPersonInfo = [PersonInfo]()
	var postPersonGotCalled = false

	func getPeople() -> (Error?, [PersonInfo]?) {
		return (nil, allPersonInfo)
	}

	func postPerson(_ personInfo: PersonInfo) -> Error? {
		postPersonGotCalled = false
		return nil
	}

}

class MockDataProvider: NSObject, PeopleListDataProviderProtocol {
	var managedObjectContext: NSManagedObjectContext?
	weak var tableView: UITableView!
	var addPersonGotCalled = false

	func addPerson(_ personInfo: PersonInfo) { addPersonGotCalled = true }
	func fetch() { }

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 1 }
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return UITableViewCell()
	}
}

class MockUserDefaults: UserDefaults {
	var sortWasChanged = false

	override func set(_ value: Int, forKey defaultName: String) {
		if defaultName == "sort" {
			sortWasChanged = true
		}
	}
}
