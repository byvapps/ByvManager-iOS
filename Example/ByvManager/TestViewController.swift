//
//  TestViewController.swift
//  camionapp
//
//  Created by Adrian Apodaca on 23/2/17.
//  Copyright © 2017 CamionApp. All rights reserved.
//

import UIKit
import ByvManager
import SwiftyJSON

class PaginatedTestViewController: ByvPaginatedViewController {

    override func viewDidLoad() {
        
        self.emptyView = UINib(nibName: "EmptyView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as? UIView
        
        let url = "api/search"
        let section = ByvPaginatedSection()
        section.url = url
        section.limit = 10
        section.automaticallyLoadNextPage = true
//        section.loadingCellNib = UINib(nibName: "LoadingCell", bundle: nil)
//        section.loadMoreCellNib = UINib(nibName: "LoadMoreCell", bundle: nil)
//        section.params["latitude"] = NSNumber(value: 43.267783)
//        section.params["longitude"] = NSNumber(value: -2.924246)
//        section.deleteRowAnimation = .left
//        section.insertRowAnimation = .right
        self.sections.append(section)
//        for i in 0...10 {
//            print(i)
//            let url = "api/companies/42/users"
//            let section = ByvPaginatedSection()
//            section.url = url
//            section.limit = 1
//            if i % 2 == 0 {
//                section.automaticallyLoadNextPage = false
//            } else {
//                section.automaticallyLoadNextPage = false
//            }
//            section.loadingCellNib = UINib(nibName: "LoadingCell", bundle: nil)
//            section.loadMoreCellNib = UINib(nibName: "LoadMoreCell", bundle: nil)
//            //        section.params["latitude"] = NSNumber(value: 43.267783)
//            //        section.params["longitude"] = NSNumber(value: -2.924246)
//            self.sections.append(section)
//        }
        super.viewDidLoad()
//        self.tableView.estimatedRowHeight = 88.0
        
        let bi = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.reloadAllTable))
        self.navigationItem.rightBarButtonItem = bi
    }
    
    @objc func reloadAllTable() {
        super.reloadData()
    }
    
    override func cellIdentifierFor(indexPath: IndexPath, item: Any) -> String {
        return "cell"
    }
    
    // Override to filter elemnts if need
    override open func filterItems(_ newItems: [JSON], in sectionIndex:Int) -> Array<Any> {
        return newItems
    }
    
    // Override to customize cell
    override func updateCell(cell: UITableViewCell, with item: Any, at indexPath: IndexPath) {
        if let json:JSON = item as? JSON {
            cell.textLabel?.text = json["name"].stringValue
        }
        return
    }
    
    // Override to make select action
    override open func didSelect(item: Any, at indexPath:IndexPath) {
        print("item selected at index: \(indexPath.section)-\(indexPath.row)")
        self.tableView.deselectRow(at: indexPath, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
