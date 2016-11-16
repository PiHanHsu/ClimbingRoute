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
    var finishRoutes = [Route]()
    var unfinishRoutes = [Route]()
    let indicator = UIActivityIndicatorView()
    var hasTempRoute = false
    var tempRoute: Route?

    @IBOutlet var routeSegmentedControl: UISegmentedControl!
    @IBOutlet var createNewRouteBarButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DataSource.shareInstance.loadingRouteFromFirebase(fieldId: DataSource.shareInstance.fields[index].fieldId)
        
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
        
        createNewRouteBarButton.title = ""
        reloadData()
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadData), name: Notification.Name("FinishLoadingRouteData"), object: nil)

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FinishLoadingRouteData"), object: nil);
    }
    
    func reloadData() {
        
        routes = DataSource.shareInstance.selectField!.routes
        tempRoute = DataSource.shareInstance.selectField!.tempRoute
        if tempRoute != nil {
            hasTempRoute = true
            createNewRouteBarButton.title = "編輯暫存路線"
        }else{
            hasTempRoute = false
            createNewRouteBarButton.title = "新增路線"
        }
        myRoutes = DataSource.shareInstance.selectField!.myRoutes
        let finishRoutesArray = DataSource.shareInstance.finishRoutes
        
        finishRoutes.removeAll()
        unfinishRoutes.removeAll()
        for route in routes {
            if finishRoutesArray.contains(route.routeId!) {
                route.finished = true
                finishRoutes.append(route)
            }else {
                unfinishRoutes.append(route)
            }
        }
        
        indicator.stopAnimating()
        tableView.reloadData()
        
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
            return unfinishRoutes.count
        case 2:
            return finishRoutes.count
        default:
            return 0
        }

    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RouteTableViewCell", for: indexPath) as! RouteTableViewCell
        
        let checkImageView = UIImageView(frame: CGRect(x: 4, y: (cell.frame.height - 16) / 2, width: 16, height: 16))
        
        if finishRoutes.count > 0 {
            cell.accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: cell.frame.height))
            cell.accessoryView?.addSubview(checkImageView)
        }else {
            cell.accessoryView = UIView(frame: CGRect.zero)
        }
        
        
        switch routeSegmentedControl.selectedSegmentIndex {
        case 0:
            cell.nameLabel.text = routes[indexPath.row].name
            cell.createrLabel.text = routes[indexPath.row].creater
            cell.difficultyLabel.text = routes[indexPath.row].difficulty
            cell.ratingView.rating = routes[indexPath.row].rating
            
            if routes[indexPath.row].finished {
                checkImageView.image = UIImage(named: "checkmark")
            }else {
                checkImageView.image = UIImage(named: "")
            }
            
        case 1:
            cell.nameLabel.text = unfinishRoutes[indexPath.row].name
            cell.createrLabel.text = unfinishRoutes[indexPath.row].creater
            cell.difficultyLabel.text = unfinishRoutes[indexPath.row].difficulty
            cell.ratingView.rating = unfinishRoutes[indexPath.row].rating
        
            checkImageView.image = UIImage(named: "")
            
        case 2:
            cell.nameLabel.text = finishRoutes[indexPath.row].name
            cell.createrLabel.text = finishRoutes[indexPath.row].creater
            cell.difficultyLabel.text = finishRoutes[indexPath.row].difficulty
            cell.ratingView.rating = finishRoutes[indexPath.row].rating
            checkImageView.image = UIImage(named: "checkmark")

        default:
            break
        }
       
        
        return cell
    }
    

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    @IBAction func selectRouteSegement(_ sender: AnyObject) {
        
        tableView.reloadData()
        
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
        
        let nav = segue.destination as! LandscapeNavigationController
        let vc = nav.topViewController as! ShowRouteViewController
    
        if segue.identifier == "StartClimbing" {
            vc.route = routes[(tableView.indexPathForSelectedRow?.row)!]
            vc.isPlayingMode = true
        }else if segue.identifier == "CreateRoute" {
            if hasTempRoute {
                vc.isEditMode = true
                vc.hasTempRoute = hasTempRoute
                vc.route = tempRoute
            }else{
               vc.isCreateMode = true
            }
        }
    }
    

}
