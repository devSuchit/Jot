//
//  notesTblVC.swift
//  Jot.
//
//  Created by Suchit on 15/07/17.
//  Copyright © 2017 Suchit. All rights reserved.
//

import UIKit
import CoreData

class notesTblVC: UIViewController,UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backBtn: UIButton!
    var controller:  NSFetchedResultsController<Note>!
    
    @IBOutlet weak var segment: UISegmentedControl!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
   
        tableView.delegate = self
        tableView.dataSource = self
        attempFetch()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true )
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = controller.sections{
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = controller.sections{
            return sections.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as! noteCell
        let item = controller.object(at: indexPath as IndexPath)
        cell.configureCell(item: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let obj = controller.fetchedObjects , obj.count > 0 {
            
            let item = obj[indexPath.row]
            performSegue(withIdentifier: "editView", sender: item)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Trash") { action, index in
            context.delete(self.controller.object(at: editActionsForRowAt as IndexPath))
            do {
                ad.saveContext()
                try context.save()
                tableView.reloadData()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
        delete.backgroundColor = .red
        
        let share = UITableViewRowAction(style: .normal, title: "Share") { action, index in
            // text to share
            let obj = self.controller.object(at: editActionsForRowAt as IndexPath)
            let text = obj.field
            // set up activity view controller
            let activityViewController = UIActivityViewController(activityItems: [text!], applicationActivities: nil)
            
            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
            
            
            
            // present the view controller
            self.present(activityViewController, animated: true, completion: nil)

        }
        share.backgroundColor = .blue
        
        return [delete,share]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editView"{
            if let destination = segue.destination as? noteDetailsVC {
                if let item = sender as? Note {
                    destination.itemToEdit = item
                }
            }
        }
    }
    
    func attempFetch(){
        
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest() //describes which data to be fetched
        let dateSort = NSSortDescriptor(key: "created", ascending: false) //describes sorting method
        let tagSort = NSSortDescriptor(key: "tagName", ascending: true)
        let titleSort = NSSortDescriptor(key: "titleName", ascending: true)
        if segment.selectedSegmentIndex == 0 {
        fetchRequest.sortDescriptors = [dateSort]
        }//adds sorting fetch
        else if segment.selectedSegmentIndex == 1 {
            fetchRequest.sortDescriptors = [tagSort]
        }
        else if segment.selectedSegmentIndex == 2 {
            fetchRequest.sortDescriptors = [titleSort]
        }
        //creating a controller to manage fetch
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        self.controller = controller
        //performing fetch
        do{
            try controller.performFetch()
        }catch{
            let error = error as NSError
            print("\(String(describing: error))")
        }
        
    }
    
    
    @IBAction func segmentPressed(_ sender: Any) {
        attempFetch()
        tableView.reloadData()
    }
    
    //to update cells with deletions insertions etc. using coreData
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        tableView.beginUpdates()
        
    }
    //to end updates
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    //to manage changes
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch(type){
            
        case.insert:
            if let indexPath = newIndexPath{
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break
        case.delete:
            if let indexPath = indexPath{
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break
        case.update:
            if let indexPath = indexPath {
                let cell = tableView.cellForRow(at: indexPath) as! noteCell
                let item = controller.object(at: indexPath as IndexPath)
                cell.configureCell(item: item as! Note)
                
            }
            break
        case.move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
                
            }
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break
            
            
        }
        
    }
    
    @IBAction func addPressed(_ sender: Any) {
        segment.selectedSegmentIndex = 0
        attempFetch()
        tableView.reloadData()
        
    }
    

}
