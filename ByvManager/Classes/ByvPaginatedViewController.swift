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
    public var idStr: String = ""
    public var url: String = ""
    public var limit: Int = 10
    public var offset: Int = 0
    public var params: [String: Any] = ["offset" :  NSNumber(value:0), "limit" : NSNumber(value:10)]
    public var cellIdentifier: String = "cell"
    public var showLoadingCell: Bool = true
    public var automaticallyLoadNextPage: Bool = false
    public var loadingCellNib: UINib? = nil
    public var loadMoreCellNib: UINib? = nil
    
    public var insertRowAnimation: UITableViewRowAnimation = .none
    public var deleteRowAnimation: UITableViewRowAnimation = .fade
    
    public var items: [Any] = []
    
    public var isLoadingData:Bool = false
    public var startPage:Int = 0
    public var page:Int = 0
    public var pages:Int = 1
    public var isFullLoaded:Bool = false
    
    public init() {
        
    }
}

open class ByvPaginatedViewController: UIViewController {
    
    @IBOutlet weak public var tableView: UITableView!
    
    public var emptyView: UIView? = nil
    
    public let refreshControl: UIRefreshControl = UIRefreshControl()
    
    public var loadinCellId: String = "ByvPaginatedLoadingCellId"
    public var loadMoreCellId: String = "ByvPaginatedLoadMoreCellId"
    
    var isRefreshingInBackground: Bool = false
    public var sections: [ByvPaginatedSection] = []
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
        
        self.refreshTable()
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
    open func updateCell(cell: UITableViewCell, with item: Any, at indexPath: IndexPath) {
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
    
    @objc public func refreshTable(_ animated: Bool = false) {
        resetSections()
        self.tableView.reloadData()
        if animated == true {
            UIView.animate(withDuration: 0.3, animations: {
                self.tableView.contentOffset = CGPoint(x: 0, y: -self.refreshControl.bounds.size.height)
                self.tableView.layoutIfNeeded()
            }, completion: { (ended) in
                //                self.loadPage()
            })
        } else {
            //            loadPage()
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
                if !shouldLoadItems(at: section) {
                    return
                }
                var params = section.params
                params["offset"] = NSNumber(value: section.page * section.limit)
                params["limit"] = NSNumber(value: section.limit)
                
                ConManager.GET(section.url , params: params, auth: true, background: true, success: { (responseData) in
                    if self.isRefreshingInBackground {
                        self.tableView.reloadData()
                        self.isRefreshingInBackground = false
                    }
                    section.isLoadingData = false
                    var newItems:[Any] = []
                    if let data: Data = responseData?.data {
                        do {
                            let json = try JSON(data: data)
                            if let jsonArray = json.array {
                                section.page = section.page + 1
                                let newItemsCount = jsonArray.count
                                let sectionIndex = self.sectionIndex(section)
                                let lastIndex = section.items.count
                                let lastIndexPath = IndexPath(row: lastIndex, section: sectionIndex)
                                newItems = self.filterItems(jsonArray, in: self.sectionIndex(section))
                                self.tableView.beginUpdates()
                                self.tableView.deleteRows(at: [lastIndexPath], with: section.deleteRowAnimation)
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
                                self.checkEmptyView()
                            } else {
                                section.isLoadingData = false
                                section.isFullLoaded = true
                                self.tableView.reloadData()
                                self.checkEmptyView()
                            }
                        } catch {
                            print("JSON parse ERROR")
                        }
                    }
                    self.refreshControl.endRefreshing()
                    self.checkEmptyView()
                    self.didLoad(items: newItems, at: section)
                }, failed: { (error) in
                    section.isLoadingData = false
                    section.isFullLoaded = true
                    self.refreshControl.endRefreshing()
                    self.tableView.reloadData()
                    self.checkEmptyView()
                    self.didFailLoadingItems(at: section)
                })
            }
        }
    }
    
    /* To override */
    open func shouldLoadItems(at section:ByvPaginatedSection) -> Bool {
        return true
    }
    
    open func didLoad(items:[Any], at section:ByvPaginatedSection) {
        
    }
    
    open func didFailLoadingItems(at section:ByvPaginatedSection) {
        
    }
    /* END To override */
    
    func checkEmptyView() {
        for section in sections {
            if section.items.count > 0 {
                self.tableView.backgroundView = nil
                return
            }
            if !section.isFullLoaded {
                self.tableView.backgroundView = nil
                return
            }
        }
        
        self.tableView.backgroundView = self.emptyView
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
    
}


// MARK: UITableViewDataSource & UITableViewDelegate Methods
extension ByvPaginatedViewController: UITableViewDataSource, UITableViewDelegate {
    
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
                
                if self.toLoadSection() === section && section.automaticallyLoadNextPage && !section.isLoadingData {
                    if indexPath.row == section.items.count {
                        //                    self.perform(#selector(self.loadPage(_:)), with: nil, afterDelay: 0.1)
                        self.loadPage()
                    }
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
            
            updateCell(cell: cell, with: item, at:indexPath)
            
            return cell
        }
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
