//
//  MasterViewController.swift
//  Project
//
//  Created by Mostak Khan W1622449 on 22/06/2019.
//  Copyright © 2019 Swift. All rights reserved.
//

import UIKit
import CoreData


class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {


    var detail: DetailViewController? = nil

    
    var getResultsController: NSFetchedResultsController<Project> {
        if _getResultsController != nil {
            return _getResultsController!
        }

        let fetchRequest: NSFetchRequest<Project> = Project.fetchRequest()
        fetchRequest.fetchBatchSize = 20
        fetchRequest.sortDescriptors = []

        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: showContext, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        _getResultsController = aFetchedResultsController

        do {
            try _getResultsController!.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }

        return _getResultsController!
    }
    var _getResultsController: NSFetchedResultsController<Project>? = nil


    var getProjects: [Project]?


    override func viewDidLoad() {
        super.viewDidLoad()

        editButtonItem.tintColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        navigationItem.leftBarButtonItem = editButtonItem

        let addBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        addBtn.tintColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        navigationItem.rightBarButtonItem = addBtn
        if let splitView = splitViewController {
            let controllers = splitView.viewControllers
            detail = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }

        getProjects = fetchProjects()

        tableView.register(UINib(nibName: "ProjectCell", bundle: nil), forCellReuseIdentifier: "ProjectCell")

        
        tableView.reloadData()

      
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadData), name: NSNotification.Name(rawValue: reloadMasterNotificationKey), object: nil)

        if let lastSeenProjectID = previousProjectID {
            do {
                let fetchRequest = NSFetchRequest<Project>(entityName: "Project")
                fetchRequest.predicate = NSPredicate(format: "projectID == %d", lastSeenProjectID)
                let fetchedMatchingProject = try showContext.fetch(fetchRequest)

                
                if let project = fetchedMatchingProject.first {

                    performSegue(withIdentifier: "showDetail", sender: project)

                    
                    let rowC = getProjects?.firstIndex(of: project)
                
                    tableView.cellForRow(at: IndexPath(row: rowC!, section: 0))?.setSelected(true, animated: true)
                }

            } catch let error {
                print(error.localizedDescription)
            }
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    @objc func reloadData() {
        getProjects = fetchProjects()
        tableView.reloadData()
    }


    
    @objc func insertNewObject(_ sender: Any) {
        modifyVC = false
        performSegue(withIdentifier: "addProject", sender: self)
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "showDetail" {
            
            if let project = sender as? Project {
                let controllerc = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controllerc.myItems = project
                controllerc.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controllerc.navigationItem.leftItemsSupplementBackButton = true
                controllerc.title = project.projectName!
            }
           
            else if let indexPath = tableView.indexPathForSelectedRow, let object = getProjects?[indexPath.row] {
                let controllerc = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controllerc.myItems = object
                controllerc.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controllerc.navigationItem.leftItemsSupplementBackButton = true
                controllerc.title = object.projectName!
            }
        }

        else if segue.identifier == "addProject" {
            let destination = (segue.destination as! UINavigationController).viewControllers.first as! NewProjectViewController
            
            destination.VC = self
        }
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getProjects != nil ? getProjects!.count : 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellt = tableView.dequeueReusableCell(withIdentifier: "ProjectCell", for: indexPath) as? ProjectCell
        if let object = getProjects?[indexPath.row] {
            cellt?.setUp(with: object)
        }
        return cellt!
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            showContext.delete((getProjects?[indexPath.row])!)
            do {
                try showContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
            getProjects = fetchProjects()
            tableView.reloadData()
            performSegue(withIdentifier: "showDetail", sender: self)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetail", sender: self)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 99.0
    }



    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                let cellu = tableView.cellForRow(at: indexPath!) as! ProjectCell
                cellu.setUp(with: (getProjects?[(indexPath?.row)!])!)
            case .move:
                let cellm = tableView.cellForRow(at: indexPath!) as! ProjectCell
                cellm.setUp(with: (getProjects?[(indexPath?.row)!])!)
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default:
            fatalError()
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        getProjects = fetchProjects()
    }


    func fetchProjects() -> [Project]? {
        do {
            return try showContext.fetch(Project.fetchRequest()) as? [Project]
        } catch let error {
            print(error.localizedDescription)
        }
        return nil
    }

}

