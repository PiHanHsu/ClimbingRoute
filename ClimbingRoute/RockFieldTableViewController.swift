//
//  RockFieldTableViewController.swift
//  ClimbingRoute
//
//  Created by PiHan Hsu on 26/10/2016.
//  Copyright © 2016 PiHan Hsu. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON

class RockFieldTableViewController: UITableViewController {
    
    @IBOutlet var addFieldBarButton: UIBarButtonItem!

    var fields = [Field]()
    var firebaseUser: FIRUser?
    let ref = FIRDatabase.database().reference()
        
    override func viewDidLoad() {
        super.viewDidLoad()

        fields = DataSource.shareInstance.Fields
        firebaseUser = DataSource.shareInstance.firebaseUser
        self.navigationItem.rightBarButtonItem = nil
        
        if let user = firebaseUser {
            print(user.uid)
            if user.uid == "eY77TbUZgaO0L17lDyqi1vQHpU12" {
               self.navigationItem.rightBarButtonItem = addFieldBarButton
            }
        }
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    
    @IBAction func addFieldButtonPressed(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "新增岩場", message: nil, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            
            let textField = alertController.textFields![0] as UITextField
            let name = textField.text!
            let newField = self.ref.child("Field").childByAutoId()
            let fieldInfo = ["name": name] as [String : Any]
            newField.setValue(fieldInfo)
            
            self.ref.child("Field").observeSingleEvent(of: .value, with: { (snapshot) in
                for child in snapshot.children {
                    let childSnapshot = snapshot.childSnapshot(forPath: (child as AnyObject).key)
                    let fieldId = childSnapshot.key
                    let value = childSnapshot.value as? NSDictionary
                    let name = value?["name"] as! String
                    
                    let field = Field(name: name)
                    DataSource.shareInstance.Fields.append(field)
                }
                self.fields = DataSource.shareInstance.Fields
                self.tableView.reloadData()
            })
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "輸入岩場名稱"
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return fields.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RockFieldTableViewCell", for: indexPath) as! RockFieldTableViewCell

        cell.nameLabel.text = fields[indexPath.row].name
        if let routeNumber = fields[indexPath.row].routes?.count {
            cell.routesLabel.text = "\(routeNumber)條路線"
        }else {
            cell.routesLabel.text = "0 條路線"
        }
                return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowRoutes" {
            let vc = segue.destination as! RoutesTableViewController
            vc.index = (tableView.indexPathForSelectedRow?.row)!
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
