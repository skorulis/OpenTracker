//
//  FetchResultsChangeManager.swift
//  OpenTracker
//
//  Created by Alexander Skorulis on 12/10/18.
//  Copyright © 2018 Alexander Skorulis. All rights reserved.
//

import UIKit
import CoreData

class FetchResultsChangeBehaviour<ResultType:NSFetchRequestResult>: NSObject, NSFetchedResultsControllerDelegate {

    private let tableView:UITableView
    private let fetchController:NSFetchedResultsController<ResultType>
    
    var alwaysReload:Bool = false
    
    init(tableView:UITableView,fetchController:NSFetchedResultsController<ResultType>) {
        self.tableView = tableView
        self.fetchController = fetchController
        super.init()
        self.fetchController.delegate = self
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if !self.alwaysReload { return }
        self.tableView.reloadData()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if self.alwaysReload { return }
        
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .fade)
        case .move:
            tableView.reloadData()
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        if self.alwaysReload { return }
        
        switch type {
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
    }
    
}
