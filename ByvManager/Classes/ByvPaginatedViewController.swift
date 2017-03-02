//
//  ByvPaginatedViewController.swift
//  camionapp
//
//  Created by Adrian Apodaca on 23/2/17.
//  Copyright © 2017 CamionApp. All rights reserved.
//

import UIKit
import SwiftyJSON

public class ByvPaginatedSection {
    public var url:String = ""
    public var limit: Int = 10
    public var offset: Int = 0
    public var params:Dictionary<String, Any> = ["offset" :  NSNumber(value:0), "limit" : NSNumber(value:10)]
    public var cellIdentifier:String = "cell"
    public var showLoadingCell:Bool = true
    public var automaticallyLoadNextPage:Bool = false
    public var loadingCellNib: UINib? = nil
    public var loadMoreCellNib: UINib? = nil
    
    public var insertRowAnimation: UITableViewRowAnimation = .none
    public var deleteRowAnimation: UITableViewRowAnimation = .fade
    
    public var items:Array<Any> = []
    
    public var isLoadingData:Bool = false
    public var startPage:Int = 0
    public var page:Int = 0
    public var pages:Int = 1
    public var isFullLoaded:Bool = false
    
    public init() {
        
    }
}

open class ByvPaginatedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let refreshControl: UIRefreshControl = UIRefreshControl()
    
    public var loadinCellId:String = "ByvPaginatedLoadingCellId"
    public var loadMoreCellId:String = "ByvPaginatedLoadMoreCellId"
    
    var isRefreshingInBackground:Bool = false
    public var sections:Array<ByvPaginatedSection> = []
    public var allowPullToRefresh: Bool = true
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 44.00
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        for i in 0...sections.count - 1 {
            let section = sections[i]
            var identifier = "loadingCell_\(i)"
            if let nib = section.loadingCellNib {
                self.tableView.register(nib, forCellReuseIdentifier: identifier)
            } else {
                self.tableView.register(ByvPaginatedLoadingCell.classForCoder(), forCellReuseIdentifier: identifier)
            }
            
            identifier = "loadMoreCell_\(i)"
            if let nib = section.loadMoreCellNib {
                self.tableView.register(nib, forCellReuseIdentifier: identifier)
            } else {
                self.tableView.register(ByvPagintedLoadMoreCell.classForCoder(), forCellReuseIdentifier: identifier)
            }
        }
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: loadinCellId)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: loadMoreCellId)
        
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        
        // IOS 10 TintColor Bug 23-02-2017
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        // Tint color bug fixx START
        self.refreshControl.beginRefreshing()
        UIView.animate(withDuration: 0.3, animations: {
            self.tableView.contentOffset = CGPoint(x: 0, y: -self.refreshControl.bounds.size.height)
            self.tableView.layoutIfNeeded()
        }, completion: { (ended) in
            self.refreshControl.endRefreshing()
            self.tableView.layoutIfNeeded()
            self.tableView.reloadData()
            self.refreshTable(false)
        })
        
        self.refreshControl.endRefreshing()
        // Tint color bug fixx END
        // else self.refreshTable(true)
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Override if custom cell for custom index is needed
    open func cellIdentifierFor(indexPath: IndexPath, item: Any) -> String {
        return sections[indexPath.section].cellIdentifier
    }
    
    // Override to customize cell
    open func updateCell(cell: UITableViewCell, with item: Any) {
        if let ip = self.tableView.indexPath(for: cell) {
            cell.textLabel?.text = "section: \(ip.section) - row: \(ip.row)"
        }
        return
    }
    
    // Override to filter elemnts if need
    open func filterItems(_ newItems: [JSON], in sectionIndex:Int) -> Array<Any> {
        return newItems
    }
    
    // Override to make select action
    open func didSelect(item: Any, at indexPath:IndexPath) {
        print("item selected at index: \(indexPath.section)-\(indexPath.row)")
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // tableview delegate & data source
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("section: \(indexPath.section) - row: \(indexPath.row)")
        let section = sections[indexPath.section]
        if indexPath.row >= section.items.count {
            if section.automaticallyLoadNextPage {
                let identifier = "loadingCell_\(indexPath.section)"
                let cell  : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier, for:indexPath)
                if let aiv = cell.viewWithTag(310584) as? UIActivityIndicatorView {
                    aiv.startAnimating()
                }
                return cell
            } else {
                let identifier = "loadMoreCell_\(indexPath.section)"
                let cell  : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier, for:indexPath)
                return cell
            }
        } else {
            let item = section.items[indexPath.row]
            let cell  : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifierFor(indexPath: indexPath, item: item), for:indexPath)
            
            updateCell(cell: cell, with: item)
            
            if self.toLoadSection() === section && section.automaticallyLoadNextPage && !section.isLoadingData {
                if indexPath.row == section.items.count - 1 {
//                    self.perform(#selector(self.loadPage(_:)), with: nil, afterDelay: 0.1)
                    self.loadPage()
                }
            }
            
            return cell
        }
    }
    
    public func refreshTable(_ animated: Bool = false) {
        resetSections()
        self.tableView.reloadData()
        if animated == true {
            UIView.animate(withDuration: 0.3, animations: {
                self.tableView.contentOffset = CGPoint(x: 0, y: -self.refreshControl.bounds.size.height)
                self.tableView.layoutIfNeeded()
            }, completion: { (ended) in
                self.loadPage()
            })
        } else {
            loadPage()
        }
        
    }
    
    public func reloadData() {
        resetSections()
        
        isRefreshingInBackground = true
        loadPage()
    }
    
    func resetSections() {
        for section in sections {
            section.isFullLoaded = false
            section.isLoadingData = false
            section.page = section.startPage
            section.items = []
            section.offset = 0
            section.params["offset"] = NSNumber(value: section.page * section.limit)
            section.params["limit"] = NSNumber(value: section.limit)
        }
    }
    
    public func loadPage() {
        if let section = toLoadSection() {
            if !section.isLoadingData {
                section.isLoadingData = true
                var params = section.params
                params["offset"] = NSNumber(value: section.page * section.limit)
                params["limit"] = NSNumber(value: section.limit)
                print(params)
                
                ConManager.GET(section.url , params: params, auth: true, background: true, success: { (responseData) in
                    if self.isRefreshingInBackground {
                        self.tableView.reloadData()
                    }
                    section.page = section.page + 1
                    section.isLoadingData = false
                    if let data: Data = responseData?.data {
                        let json = JSON(data: data)
                        if let jsonArray = json.array {
                            let newItemsCount = jsonArray.count
                            let sectionIndex = self.sectionIndex(section)
                            let lastIndex = section.items.count
                            let lastIndexPath = IndexPath(row: lastIndex, section: sectionIndex)
                            self.tableView.beginUpdates()
                            self.tableView.deleteRows(at: [lastIndexPath], with: section.deleteRowAnimation)
                            let newItems = self.filterItems(jsonArray, in: self.sectionIndex(section))
                            if newItems.count > 0 {
                                var indexes: Array<IndexPath> = []
                                for i in lastIndex...lastIndex+newItems.count - 1 {
                                    indexes.append(IndexPath(row: i, section: sectionIndex))
                                }
                                section.items += newItems
                                self.tableView.insertRows(at: indexes, with: section.insertRowAnimation)
                            }
                            if (newItemsCount < section.limit) {
                                section.isFullLoaded = true
                                if sectionIndex + 1 < self.sections.count {
                                    //More sections
                                    let newSection = self.sections[sectionIndex + 1]
                                    if newSection.showLoadingCell || !newSection.automaticallyLoadNextPage {
                                        self.tableView.insertSections([sectionIndex + 1], with: newSection.insertRowAnimation)
                                        let indexPath = IndexPath(row: 0, section: sectionIndex + 1)
                                        self.tableView.insertRows(at: [indexPath], with: newSection.insertRowAnimation)
                                    }
                                    self.loadPage()
                                }
                            } else {
                                if section.showLoadingCell || !section.automaticallyLoadNextPage {
                                    let indexPath = IndexPath(row: section.items.count, section: sectionIndex)
                                    self.tableView.insertRows(at: [indexPath], with: section.insertRowAnimation)
                                }
                            }
                            
                            self.tableView.endUpdates()
                        } else {
                            section.isLoadingData = false
                            self.tableView.reloadData()
                        }
                        self.isRefreshingInBackground = false
                        self.refreshControl.endRefreshing()
                    }
                }, failed: { (error) in
                    section.isLoadingData = false
                    self.refreshControl.endRefreshing()
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    func sectionIndex(_ section: ByvPaginatedSection) -> Int {
        var response = 0
        for sec in sections {
            if section === sec {
                return response
            }
            response += 1
        }
        return -1
    }
    
    public func toLoadSection() -> ByvPaginatedSection? {
        for section in sections {
            if !section.isFullLoaded {
                return section
            }
        }
        return nil
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        var response:Int = 0
        
        for section in sections {
            response += 1
            if !section.isFullLoaded {
                break
            }
        }
        
        return response
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection sectionIndex: Int) -> Int {
        let section = sections[sectionIndex]
        let selectedSection = toLoadSection()
        if selectedSection === section && !section.isFullLoaded && (!section.automaticallyLoadNextPage || section.showLoadingCell) {
            return section.items.count + 1
            
        }
        return section.items.count
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section < sections.count {
            let section = sections[indexPath.section]
            if indexPath.row >= section.items.count {
                if section.isLoadingData && section.showLoadingCell {
                    return
                } else {
                    self.tableView.deselectRow(at: indexPath, animated: true)
                    self.loadPage()
                    return
                }
            }
            if indexPath.row < section.items.count {
                let item = section.items[indexPath.row]
                self.didSelect(item: item, at: indexPath)
            }
        }
    }

}
