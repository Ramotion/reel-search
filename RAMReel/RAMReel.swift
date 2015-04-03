//
//  RAMReel.swift
//  RAMReel
//
//  Created by Mikhail Stepkin on 4/2/15.
//  Copyright (c) 2015 Ramotion. All rights reserved.
//

import Foundation
import UIKit

// 1. Subscribe to textfield text change
// 2. Query DataSourse for this string

public final class TextFieldReactor
    <
    DS: FlowDataSource,
    DD: FlowDataDestination
    where DS.ResultType == DD.DataType, DS.QueryType == String
    >
{
    
    let textField : UITextField
    let dataFlow  : DataFlow<DS, DD>
    
    private let target:Target
    
    init(textField: UITextField, dataFlow: DataFlow<DS, DD>) {
        self.textField  = textField
        self.dataFlow   = dataFlow
        
        self.target     = Target(hook: dataFlow.transport)
        
        textField.addTarget(target, action: Target.actionSelector, forControlEvents: Target.controlEvents)
    }
    
    deinit {
        textField.removeTarget(target, action: Target.actionSelector, forControlEvents: Target.controlEvents)
    }
}

final class Target: NSObject {
    
    static let actionSelector = Selector("editingChanged:")
    static let controlEvents  = UIControlEvents.EditingChanged
    
    typealias HookType = (String) -> ()
    
    let hook: HookType
    init(hook: HookType) {
        self.hook = hook
        
        super.init()
    }
    
    func editingChanged(textField: UITextField) {
        hook(textField.text)
    }
    
}

protocol CellProtocol {
    
    typealias DataType
    
    func configureCell(data: (DataType) -> ())
    
}

class TableViewDataWrapper <CellClass: UITableViewCell> {
    
//    let dataSource: TableViewDataSource
    init(tableView: UITableView, cellId: String) {
        tableView.registerClass(CellClass.self, forCellReuseIdentifier: cellId)
        
//        dataSource = TableViewDataSource { tv, ip in
//            let cell = tv.dequeueReusableCellWithIdentifier(cellId, forIndexPath: ip) as! CellClass
//            
//            cell.configureCell({ (d) -> () in
//                println(d)
//            })
//            
//            return cell as UITableViewCell
//        }
//        tableView.dataSource = dataSource
    }

}

//class TableViewDataSource: NSObject, UITableViewDataSource {
//    
//    typealias CellCallback = (UITableView, NSIndexPath) -> UITableViewCell
//    let cellCallback: CellCallback
//    
//    init(callback: CellCallback) {
//        self.cellCallback = callback
//        
//        super.init()
//    }
//    
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 0
//    }
//    
//     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 0
//    }
//    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        
//    }
//}