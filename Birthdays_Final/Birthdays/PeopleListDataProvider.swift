//
//  PeopleListDataProvider.swift
//  Birthdays
//
//  Created by dasdom on 27.03.15.
//  Copyright (c) 2015 Dominik Hauser. All rights reserved.
//

import UIKit
import CoreData

public class PeopleListDataProvider: NSObject, PeopleListDataProviderProtocol {
  
  public var managedObjectContext: NSManagedObjectContext?
  weak public var tableView: UITableView!
  var _fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? = nil
  
	let dateFormatter: DateFormatter
  
  override public init() {
		dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .none
    
    super.init()
  }
  
	public func addPerson(_ personInfo: PersonInfo) {
    let context = self.fetchedResultsController.managedObjectContext
    let entity = self.fetchedResultsController.fetchRequest.entity!
		let person = NSEntityDescription.insertNewObject(forEntityName: entity.name!, into: context) as! Person
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    person.firstName = personInfo.firstName
    person.lastName = personInfo.lastName
    person.birthday = personInfo.birthday
    
    // Save the context.
		do {
			try context.save()
		} catch let error {
			print("Unresolved error  \(String(describing: error)), \(String(describing: error.localizedDescription))")
			abort()
		}
  }
  
  func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
		let person = self.fetchedResultsController.object(at: indexPath) as! Person
    cell.textLabel!.text = person.fullname
		cell.detailTextLabel!.text = dateFormatter.string(from: person.birthday as Date)
  }
  
//  public func personForIndexPath(indexPath: NSIndexPath) -> Person? {
//    return fetchedResultsController.objectAtIndexPath(indexPath) as? Person
//  }
//  
  public func fetch() {
		let sortKey = UserDefaults.standard.integer(forKey: "sort") == 0 ? "lastName" : "firstName"

    let sortDescriptor = NSSortDescriptor(key: sortKey, ascending: true)
    let sortDescriptors = [sortDescriptor]
    
    fetchedResultsController.fetchRequest.sortDescriptors = sortDescriptors

		do {
			try fetchedResultsController.performFetch()
		} catch let error {
			print("error: \(String(describing: error))")
		}

    tableView.reloadData()
  }
}

// MARK: UITableViewDataSource
extension PeopleListDataProvider: UITableViewDataSource {
  
  public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return self.fetchedResultsController.sections?.count ?? 0
  }
  
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let sectionInfo = self.fetchedResultsController.sections![section]
    return sectionInfo.numberOfObjects
  }
  
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		self.configureCell(cell, atIndexPath: indexPath)
    return cell
  }
  
	public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
  }
  
	public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
      let context = self.fetchedResultsController.managedObjectContext
			context.delete(self.fetchedResultsController.object(at: indexPath) as! NSManagedObject)

			do {
				try context.save()
			} catch let error {
				print("Unresolved error  \(String(describing: error)), \(String(describing: error.localizedDescription))")
				abort()
			}
    }
  }
  
}

// MARK: NSFetchedResultsControllerDelegate
extension PeopleListDataProvider: NSFetchedResultsControllerDelegate {
  
	var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
    if _fetchedResultsController != nil {
      return _fetchedResultsController!
    }
    
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
    // Edit the entity name as appropriate.
		let entity = NSEntityDescription.entity(forEntityName: "Person", in: self.managedObjectContext!)
    fetchRequest.entity = entity
    
    // Set the batch size to a suitable number.
    fetchRequest.fetchBatchSize = 20
    
    // Edit the sort key as appropriate.
    let sortDescriptor = NSSortDescriptor(key: "lastName", ascending: true)
    let sortDescriptors = [sortDescriptor]
    
    fetchRequest.sortDescriptors = [sortDescriptor]
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
    aFetchedResultsController.delegate = self
    _fetchedResultsController = aFetchedResultsController
    
		do {
			try _fetchedResultsController?.performFetch()
		} catch let error {
			print("Unresolved error \(error), \(error.localizedDescription)")
			abort()
		}

    return _fetchedResultsController!
  }
  
	public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    self.tableView.beginUpdates()
  }
  
	public func controller(controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
    switch type {
    case .insert:
			self.tableView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
    case .delete:
			self.tableView.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
    default:
      return
    }
  }
  
	public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    switch type {
    case .insert:
			tableView.insertRows(at: [newIndexPath!], with: .fade)
    case .delete:
			tableView.deleteRows(at: [indexPath!], with: .fade)
    case .update:
			self.configureCell(tableView.cellForRow(at: indexPath!)!, atIndexPath: indexPath!)
    case .move:
			tableView.deleteRows(at: [indexPath!], with: .fade)
			tableView.insertRows(at: [newIndexPath!], with: .fade)
    }
  }
  
	public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    self.tableView.endUpdates()
  }

}
