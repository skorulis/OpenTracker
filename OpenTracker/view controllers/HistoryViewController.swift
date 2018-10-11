//
//  HistoryViewController.swift
//  OpenTracker
//
//  Created by Alexander Skorulis on 11/10/18.
//  Copyright © 2018 Alexander Skorulis. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    private var fetchedResultsController:NSFetchedResultsController<TrackLoc>?
    private let services = ServiceLocator.instance
    private var reloadBehaviour:FetchResultsChangeBehaviour<TrackLoc>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib(nibName: "HistoryCell", bundle: nil), forCellReuseIdentifier: "HistoryCell")
        
        let request = services.history.getHistory()
        let ctx = services.db.mainContext
        
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: ctx, sectionNameKeyPath: nil, cacheName: nil)
        
        reloadBehaviour = FetchResultsChangeBehaviour(tableView: self.tableView, fetchController: self.fetchedResultsController!)
        try! self.fetchedResultsController?.performFetch()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController?.sections?.first?.numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryCell
        
        guard let point = self.fetchedResultsController?.object(at: indexPath) else { return cell }
        
        cell.textLabel?.text = "History \(point.lat) \(point.lng)"

        return cell
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.reloadData()
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let point = self.fetchedResultsController?.object(at: indexPath) else { return }
            services.db.mainContext.delete(point)
            services.db.mainContext.saveRecursively(completion: nil)
            
            //tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
}
