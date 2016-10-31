//
//  RoutesTableViewController.swift
//  ClimbingRoute
//
//  Created by PiHan Hsu on 26/10/2016.
//  Copyright © 2016 PiHan Hsu. All rights reserved.
//

import UIKit

class RoutesTableViewController: UITableViewController {

    var index: Int = 0
    var routes: [Route]?
    let indicator = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DataSource.shareInstance.loadingRouteFromFirebase(filedId: DataSource.shareInstance.fields[index].fieldId)
        
        // set up indicator
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        indicator.color = UIColor.gray
        indicator.center = view.center
        indicator.startAnimating()
        view.addSubview(indicator)
        
        //add footerView
        tableView.tableFooterView = UIView(frame: .zero)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadData), name: Notification.Name("FinishLoadingRouteData"), object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FinishLoadingRouteData"), object: nil);
    }
    
    func reloadData() {
        routes = DataSource.shareInstance.fields[index].routes
        indicator.stopAnimating()
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let rows = routes?.count {
            return rows
        }else{
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RouteTableViewCell", for: indexPath) as! RouteTableViewCell
        
        cell.createrLabel.text = routes?[indexPath.row].creater
        cell.difficultyLabel.text = routes?[indexPath.row].difficulty
    
        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //DataSource.shareInstance.selectRoute = routes?[indexPath.row]
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
        
        if segue.identifier == "StartClimbing" {
            let nav = segue.destination as! LandscapeNavigationController
            let vc = nav.topViewController as! ShowRouteViewController
            
            vc.route = routes![(tableView.indexPathForSelectedRow?.row)!]
        }else if segue.identifier == "CreateRoute" {
            let nav = segue.destination as! LandscapeNavigationController
            let vc = nav.topViewController as! ShowRouteViewController
            vc.isEditMode = true
        }
    }
    

}
