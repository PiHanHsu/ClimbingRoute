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
    var routes = [Route]()
    var myRoutes = [Route]()
    let indicator = UIActivityIndicatorView()

    @IBOutlet var routeSegmentedControl: UISegmentedControl!
    
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
        //tableView.reloadData()
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadData), name: Notification.Name("FinishLoadingRouteData"), object: nil)

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FinishLoadingRouteData"), object: nil);
    }
    
    func reloadData() {
        routes = DataSource.shareInstance.selectField!.routes
        myRoutes = DataSource.shareInstance.selectField!.myRoutes
        indicator.stopAnimating()
        tableView.reloadData()
        print("routes: \(routes.count)")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch routeSegmentedControl.selectedSegmentIndex {
        case 0:
            return routes.count
        case 1:
            return myRoutes.count
        default:
            return 0
        }

    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RouteTableViewCell", for: indexPath) as! RouteTableViewCell
        
        switch routeSegmentedControl.selectedSegmentIndex {
        case 0:
            cell.createrLabel.text = routes[indexPath.row].creater
            cell.difficultyLabel.text = routes[indexPath.row].difficulty
            cell.ratingView.rating = routes[indexPath.row].rating
            cell.editButton.isHidden = true
        case 1:
            cell.createrLabel.text = myRoutes[indexPath.row].creater
            cell.difficultyLabel.text = myRoutes[indexPath.row].difficulty
            cell.ratingView.rating = myRoutes[indexPath.row].rating
            cell.editButton.isHidden = false
            cell.editButton.layer.borderWidth = 1.0
            cell.editButton.layer.borderColor = UIColor.blue.cgColor
            cell.editButton.layer.cornerRadius = 5.0

        default:
            break
        }
       
        
        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //DataSource.shareInstance.selectRoute = routes?[indexPath.row]
    }
    
    
    @IBAction func selectRouteSegement(_ sender: AnyObject) {
        
        switch routeSegmentedControl.selectedSegmentIndex {
        case 0:
            tableView.reloadData()
        case 1:
            tableView.reloadData()
        default:
            break
        }
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
            
            vc.route = routes[(tableView.indexPathForSelectedRow?.row)!]
        }else if segue.identifier == "CreateRoute" {
            let nav = segue.destination as! LandscapeNavigationController
            let vc = nav.topViewController as! ShowRouteViewController
            vc.isEditMode = true
        }
    }
    

}
